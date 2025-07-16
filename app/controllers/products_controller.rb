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
    if @product.update(product_params)
      redirect_to @product, notice: 'Product updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    @product.update(status: 'deleted')
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

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :category_id, :preview_url, :download_url, tags: [])
  end

end
