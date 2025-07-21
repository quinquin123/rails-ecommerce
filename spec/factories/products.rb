FactoryBot.define do
  factory :product do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 0..100.0) }
    status { "active" }
    reviews_count { 0 }
    
    association :seller, factory: [:user, :seller]
    association :category
  end
end