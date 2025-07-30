FactoryBot.define do
  factory :download_log do
    user_id { "" }
    product { nil }
    ip_address { "MyString" }
    user_agent { "MyString" }
    downloaded_at { "2025-07-26 15:00:34" }
  end
end