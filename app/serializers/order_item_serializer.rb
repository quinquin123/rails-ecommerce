class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :price_at_purchase, :download_expires_at, :downloadable, :created_at
  
  belongs_to :product, serializer: ProductSerializer
  belongs_to :order, serializer: OrderSerializer, if: -> { instance_options[:include_order] }
  
  def downloadable
    object.downloadable?
  end
end