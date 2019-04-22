require 'test_helper'

class ApartmentControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get apartment_new_url
    assert_response :success
  end

  test "should get edit" do
    get apartment_edit_url
    assert_response :success
  end

  test "should get show" do
    get apartment_show_url
    assert_response :success
  end

  test "should get index" do
    get apartment_index_url
    assert_response :success
  end

end
