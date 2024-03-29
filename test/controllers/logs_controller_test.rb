require 'test_helper'

class LogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @log = logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create log" do
    assert_difference('Log.count') do
      post :create, log: { device_id: @log.device_id, message: @log.message, tech_id: @log.tech_id }
    end

    assert_redirected_to log_path(assigns(:log))
  end

  test "should show log" do
    get log_url(@log)
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @log
    assert_response :success
  end

  test "should update log" do
    patch :update, id: @log, log: { device_id: @log.device_id, message: @log.message, technician_id: @log.tech_id }
    assert_redirected_to log_path(assigns(:log))
  end

  test "should destroy log" do
    assert_difference('Log.count', -1) do
      delete log_url(@log)
    end

    assert_redirected_to logs_path
  end
end
