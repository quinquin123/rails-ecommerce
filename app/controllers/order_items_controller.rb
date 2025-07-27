class OrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order_item

  def download
    authorize @order_item
    if @order_item.product.downloadable_asset.attached?
      DownloadLog.create!(
        user: current_user,
        product: @order_item.product,
        order: @order_item.order,
        downloaded_at: Time.current
      )
      redirect_to rails_blob_path(@order_item.product.downloadable_asset, disposition: 'attachment')
    else
      redirect_to order_path(@order_item.order), alert: 'Downloadable asset not available'
    end
  end

  private
  def set_order_item
    @order_item = OrderItem.find(params[:id])
  end
end