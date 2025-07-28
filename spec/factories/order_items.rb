FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    price_at_purchase { 100 }
  end
end