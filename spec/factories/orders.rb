FactoryBot.define do
  factory :order do
    status {"success"}
    association :buyer, factory: :user
  end
end