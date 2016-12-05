require 'test_helper'

class PmCodesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => PMCode.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    PMCode.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    PMCode.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to pm_code_url(assigns(:pm_code))
  end

  def test_edit
    get :edit, :id => PMCode.first
    assert_template 'edit'
  end

  def test_update_invalid
    PMCode.any_instance.stubs(:valid?).returns(false)
    put :update, :id => PMCode.first
    assert_template 'edit'
  end

  def test_update_valid
    PMCode.any_instance.stubs(:valid?).returns(true)
    put :update, :id => PMCode.first
    assert_redirected_to pm_code_url(assigns(:pm_code))
  end

  def test_destroy
    pm_code = PMCode.first
    delete :destroy, :id => pm_code
    assert_redirected_to pm_codes_url
    assert !PMCode.exists?(pm_code.id)
  end
end
