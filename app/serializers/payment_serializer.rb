class PaymentSerializer < ActiveModel::Serializer
  attributes :id, :status, :amount, :created_at
end