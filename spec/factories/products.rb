FactoryBot.define do
  factory :product do
    association :seller, factory: :user, role: :seller
    title { "Sample Product" }
    description { "Sample product description" }
    price { 100 }
    status { "active" }
    association :category

    after(:build) do |product|
      unless product.preview_image.attached?
        image_path = Rails.root.join('spec/fixtures/files/image.jpg')
        product.preview_image.attach(
          io: File.open(image_path),
          filename: 'image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
