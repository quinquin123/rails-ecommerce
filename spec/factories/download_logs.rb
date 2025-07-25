FactoryBot.define do
  factory :download_log do
    user { nil }
    product { nil }
    ip_address { "MyString" }
    user_agent { "MyString" }
  end
end
