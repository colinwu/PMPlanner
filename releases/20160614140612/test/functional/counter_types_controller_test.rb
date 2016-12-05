require 'test_helper'

class CounterTypesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => CounterType.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    CounterType.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    CounterType.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to counter_type_url(assigns(:counter_type))
  end

  def test_edit
    get :edit, :id => CounterType.first
    assert_template 'edit'
  end

  def test_update_invalid
    CounterType.any_instance.stubs(:valid?).returns(false)
    put :update, :id => CounterType.first
    assert_template 'edit'
  end

  def test_update_valid
    CounterType.any_instance.stubs(:valid?).returns(true)
    put :update, :id => CounterType.first
    assert_redirected_to counter_type_url(assigns(:counter_type))
  end

  def test_destroy
    counter_type = CounterType.first
    delete :destroy, :id => counter_type
    assert_redirected_to counter_types_url
    assert !CounterType.exists?(counter_type.id)
  end
end
