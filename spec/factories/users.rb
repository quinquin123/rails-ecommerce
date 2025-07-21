FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { "#{Faker::Internet.username}@gmail.com" }
    password { 'password123' }
    role { 'buyer' }
    status { 'active' }

    trait :seller do
      role { 'seller' }
    end

    trait :admin do
      role { 'admin' }
    end
    
  end
end
