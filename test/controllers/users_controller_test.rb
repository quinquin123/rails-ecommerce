require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_index_url
    assert_response :success
  end

  test "should get show" do
    get users_show_url
    assert_response :success
  end

  test "should get edit" do
    get users_edit_url
    assert_response :success
  end

  test "should get update" do
    get users_update_url
    assert_response :success
  end

  test "should get approve" do
    get users_approve_url
    assert_response :success
  end

  test "should get block" do
    get users_block_url
    assert_response :success
  end
end
