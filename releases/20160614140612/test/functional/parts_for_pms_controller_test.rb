require 'test_helper'

class PartsForPmsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => PartsForPm.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    PartsForPm.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    PartsForPm.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to parts_for_pm_url(assigns(:parts_for_pm))
  end

  def test_edit
    get :edit, :id => PartsForPm.first
    assert_template 'edit'
  end

  def test_update_invalid
    PartsForPm.any_instance.stubs(:valid?).returns(false)
    put :update, :id => PartsForPm.first
    assert_template 'edit'
  end

  def test_update_valid
    PartsForPm.any_instance.stubs(:valid?).returns(true)
    put :update, :id => PartsForPm.first
    assert_redirected_to parts_for_pm_url(assigns(:parts_for_pm))
  end

  def test_destroy
    parts_for_pm = PartsForPm.first
    delete :destroy, :id => parts_for_pm
    assert_redirected_to parts_for_pms_url
    assert !PartsForPm.exists?(parts_for_pm.id)
  end
end
