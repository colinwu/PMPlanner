require 'test_helper'

class ReadingsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Reading.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Reading.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Reading.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to reading_url(assigns(:reading))
  end

  def test_edit
    get :edit, :id => Reading.first
    assert_template 'edit'
  end

  def test_update_invalid
    Reading.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Reading.first
    assert_template 'edit'
  end

  def test_update_valid
    Reading.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Reading.first
    assert_redirected_to reading_url(assigns(:reading))
  end

  def test_destroy
    reading = Reading.first
    delete :destroy, :id => reading
    assert_redirected_to readings_url
    assert !Reading.exists?(reading.id)
  end
end
