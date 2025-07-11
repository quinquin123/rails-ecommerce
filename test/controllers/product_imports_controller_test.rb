require "test_helper"

class ProductImportsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get product_imports_create_url
    assert_response :success
  end
end
