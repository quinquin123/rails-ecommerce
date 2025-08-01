class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  
  def index
    @products = policy_scope(Product)
  end

  def show
    authorize @product
  end

  def new
    @product = Product.new
    authorize @product
  end

  def create
    @product = Product.new(product_params.merge(
      seller_id: current_user.id,
      status: 'active'
    ))
    authorize @product

    begin
      if @product.save
        handle_new_attachments
        redirect_to @product, notice: 'Product created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Create error: #{e.message}"
      @product.errors.add(:base, "An error occurred while creating the product.")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product
    begin
      handle_media_removal
      if @product.update(product_params)
        handle_new_attachments
        redirect_to @product, notice: 'Product updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    rescue Aws::S3::Errors::XAmzContentChecksumMismatch => e
      Rails.logger.error "Checksum error: #{e.message}"
      @product.errors.add(:base, "File upload failed. Please try again.")
      render :edit, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Update error: #{e.message}"
      @product.errors.add(:base, "An error occurred while updating the product.")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    @product.destroy 
    redirect_to products_path, notice: 'Product deleted successfully.'
  end

  def search
    @products = if user_signed_in?
                  policy_scope(Product).search_by(params[:query])
                else
                  Product.where(status: 'active').search_by_title_and_description(params[:query])
                end
    authorize Product, :index?
    render json: @products
  end

  def download
    @product = Product.find(params[:id])
    authorize @product

    unless @product.downloadable_asset.attached?
      redirect_to @product, alert: 'No downloadable asset available' and return
    end

    if @product.downloadable_by?(current_user)
      DownloadLog.create!(user: current_user, product: @product)

      if @product.price.zero?
        redirect_to @product.download_url, allow_other_host: true
      else
        redirect_to rails_blob_path(@product.downloadable_asset, disposition: 'attachment')
      end
    else
      redirect_to @product, alert: 'You need to purchase this product before downloading'
    end
  end

  private

  def handle_media_removal
    if params[:product][:remove_preview_image] == '1' && @product.preview_image.attached?
      @product.preview_image.purge_later
    end
    
    if params[:product][:remove_downloadable_asset] == '1' && @product.downloadable_asset.attached?
      @product.downloadable_asset.purge_later
    end
    
    if params[:product][:remove_video] == '1' && @product.video.attached?
      @product.video.purge_later
    end
  end

  def handle_new_attachments
    if params[:product][:preview_image].present?
      @product.preview_image.attach(params[:product][:preview_image])
    end
    
    if params[:product][:downloadable_asset].present?
      @product.downloadable_asset.attach(params[:product][:downloadable_asset])
    end
    
    if params[:product][:video].present?
      @product.video.attach(params[:product][:video])
    end
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :category_id, :preview_image, :downloadable_asset, :video, :remove_preview_image, :remove_downloadable_asset,:remove_video, tags: []).tap do |whitelisted|
      if params[:product][:tags].is_a?(String)
        whitelisted[:tags] = params[:product][:tags].split(',').map(&:strip)
      end
    end  
  end

end