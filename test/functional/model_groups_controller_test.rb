require 'test_helper'

class ModelGroupsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => ModelGroup.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    ModelGroup.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    ModelGroup.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to model_group_url(assigns(:model_group))
  end

  def test_edit
    get :edit, :id => ModelGroup.first
    assert_template 'edit'
  end

  def test_update_invalid
    ModelGroup.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ModelGroup.first
    assert_template 'edit'
  end

  def test_update_valid
    ModelGroup.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ModelGroup.first
    assert_redirected_to model_group_url(assigns(:model_group))
  end

  def test_destroy
    model_group = ModelGroup.first
    delete :destroy, :id => model_group
    assert_redirected_to model_groups_url
    assert !ModelGroup.exists?(model_group.id)
  end
end
