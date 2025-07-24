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
    @product = Product.new(product_params.merge(seller_id: current_user.id, status: 'active'))
    authorize @product
    if @product.save
      if params[:product][:preview_image].present?
        @product.preview_image.attach(params[:product][:preview_image])
      end

      if params[:product][:downloadable_asset].present?
        @product.downloadable_asset.attach(params[:product][:downloadable_asset])
      end

      redirect_to @product, notice: 'Product created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product
    if params[:product][:remove_preview_image] == '1'
      @product.preview_image.purge if @product.preview_image.attached?
    end

    if params[:product][:remove_downloadable_asset] == '1'
      @product.downloadable_asset.purge if @product.downloadable_asset.attached?
    end
    if @product.update(product_params)
      if params[:product][:preview_image].present?
        @product.preview_image.attach(params[:product][:preview_image])
      end
      if params[:product][:downloadable_asset].present?
        @product.downloadable_asset.attach(params[:product][:downloadable_asset])
      end
      redirect_to @product, notice: 'Product updated successfully.'
    else
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
    if @product.downloadable_asset.attached?
      if @product.price > 0
        # Paid product 
        if current_user.orders.joins(:order_items)
                        .where(order_items: { product_id: @product.id })
                        .where(status: 'success').exists?
          redirect_to rails_blob_path(@product.downloadable_asset, disposition: 'attachment')
        else
          redirect_to @product, alert: 'You need to purchase this product before downloading'
        end
      else
        # Free product 
        redirect_to rails_blob_path(@product.downloadable_asset, disposition: 'attachment')
      end
    else
      redirect_to @product, alert: 'No downloadable asset available'
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :category_id, :preview_image, :downloadable_asset, :remove_preview_image, :remove_downloadable_asset, tags: [])  
  end

end
