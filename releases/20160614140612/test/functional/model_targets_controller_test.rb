require 'test_helper'

class ModelTargetsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => ModelTarget.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    ModelTarget.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    ModelTarget.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to model_target_url(assigns(:model_target))
  end

  def test_edit
    get :edit, :id => ModelTarget.first
    assert_template 'edit'
  end

  def test_update_invalid
    ModelTarget.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ModelTarget.first
    assert_template 'edit'
  end

  def test_update_valid
    ModelTarget.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ModelTarget.first
    assert_redirected_to model_target_url(assigns(:model_target))
  end

  def test_destroy
    model_target = ModelTarget.first
    delete :destroy, :id => model_target
    assert_redirected_to model_targets_url
    assert !ModelTarget.exists?(model_target.id)
  end
end
