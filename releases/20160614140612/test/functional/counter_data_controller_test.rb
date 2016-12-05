require 'test_helper'

class CounterDataControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => CounterDatum.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    CounterDatum.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    CounterDatum.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to counter_datum_url(assigns(:counter_datum))
  end

  def test_edit
    get :edit, :id => CounterDatum.first
    assert_template 'edit'
  end

  def test_update_invalid
    CounterDatum.any_instance.stubs(:valid?).returns(false)
    put :update, :id => CounterDatum.first
    assert_template 'edit'
  end

  def test_update_valid
    CounterDatum.any_instance.stubs(:valid?).returns(true)
    put :update, :id => CounterDatum.first
    assert_redirected_to counter_datum_url(assigns(:counter_datum))
  end

  def test_destroy
    counter_datum = CounterDatum.first
    delete :destroy, :id => counter_datum
    assert_redirected_to counter_data_url
    assert !CounterDatum.exists?(counter_datum.id)
  end
end
