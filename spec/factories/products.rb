FactoryBot.define do
  factory :product do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 0..100.0) }
    status { Product.statuses[:active] }
    reviews_count { 0 }
    seller { create(:user, :seller) }
    category { create(:category) }
  end
end