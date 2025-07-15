FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { "#{Faker::Internet.username}@gmail.com" }
    password { 'password123' }
    role { 'buyer' }
    status { 'active' }
  end
end
