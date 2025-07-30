FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "#{Faker::Commerce.department} #{n}" }
  end
end