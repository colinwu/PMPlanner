require 'test_helper'

class PartsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Part.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Part.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Part.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to part_url(assigns(:part))
  end

  def test_edit
    get :edit, :id => Part.first
    assert_template 'edit'
  end

  def test_update_invalid
    Part.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Part.first
    assert_template 'edit'
  end

  def test_update_valid
    Part.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Part.first
    assert_redirected_to part_url(assigns(:part))
  end

  def test_destroy
    part = Part.first
    delete :destroy, :id => part
    assert_redirected_to parts_url
    assert !Part.exists?(part.id)
  end
end
