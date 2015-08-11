require 'test_helper'

class TechniciansControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Technician.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Technician.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Technician.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to technician_url(assigns(:technician))
  end

  def test_edit
    get :edit, :id => Technician.first
    assert_template 'edit'
  end

  def test_update_invalid
    Technician.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Technician.first
    assert_template 'edit'
  end

  def test_update_valid
    Technician.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Technician.first
    assert_redirected_to technician_url(assigns(:technician))
  end

  def test_destroy
    technician = Technician.first
    delete :destroy, :id => technician
    assert_redirected_to technicians_url
    assert !Technician.exists?(technician.id)
  end
end
