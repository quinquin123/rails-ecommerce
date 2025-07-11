class ProductImportsController < ApplicationController
  before_action :authenticate_user!

  def create
    @import = current_user.product_imports.build(product_import_params.merge(seller_id: current_user.id))
    authorize @import
    if @import.save
      ProcessProductImportJob.perform_later(@import)
      redirect_to root_path, notice: 'Product import started.'
    else
      redirect_to root_path, alert: 'Product import failed.'
    end
  end
  private

  def product_import_params
    params.require(:product_import).permit(:file_name)
  end
end
