FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "#{Faker::Commerce.department} #{n}" } # Thêm số thứ tự để tên duy nhất
  end
end