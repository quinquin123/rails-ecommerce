class OrderSerializer < ActiveModel::Serializer
  attributes :id, :total_amount, :status, :payment_method,  
             :created_at, :updated_at, :can_be_retried, :downloadable
  
  belongs_to :buyer, serializer: UserSerializer
  has_many :payments, serializer: PaymentSerializer
  has_many :order_items, serializer: OrderItemSerializer

  
  def status
    object.aasm_state
  end
  
  def can_be_retried
    object.can_be_retried?
  end
  
  def downloadable
    object.downloadable?
  end
end