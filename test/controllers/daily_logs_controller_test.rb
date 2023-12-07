require "test_helper"

class DailyLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get daily_logs_index_url
    assert_response :success
  end

  test "should get show" do
    get daily_logs_show_url
    assert_response :success
  end

  test "should get new" do
    get daily_logs_new_url
    assert_response :success
  end

  test "should get confirm" do
    get daily_logs_confirm_url
    assert_response :success
  end

  test "should get create" do
    get daily_logs_create_url
    assert_response :success
  end

  test "should get edit" do
    get daily_logs_edit_url
    assert_response :success
  end

  test "should get update" do
    get daily_logs_update_url
    assert_response :success
  end

  test "should get destroy" do
    get daily_logs_destroy_url
    assert_response :success
  end
end
