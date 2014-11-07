require 'test_helper'

class AppDataControllerTest < ActionController::TestCase
  setup do
    @app_datum = app_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:app_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create app_datum" do
    assert_difference('AppDatum.count') do
      post :create, app_datum: {  }
    end

    assert_redirected_to app_datum_path(assigns(:app_datum))
  end

  test "should show app_datum" do
    get :show, id: @app_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @app_datum
    assert_response :success
  end

  test "should update app_datum" do
    patch :update, id: @app_datum, app_datum: {  }
    assert_redirected_to app_datum_path(assigns(:app_datum))
  end

  test "should destroy app_datum" do
    assert_difference('AppDatum.count', -1) do
      delete :destroy, id: @app_datum
    end

    assert_redirected_to app_data_path
  end
end
