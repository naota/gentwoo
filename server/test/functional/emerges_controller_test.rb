require 'test_helper'

class EmergesControllerTest < ActionController::TestCase
  setup do
    @emerge = emerges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:emerges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create emerge" do
    assert_difference('Emerge.count') do
      post :create, :emerge => @emerge.attributes
    end

    assert_redirected_to emerge_path(assigns(:emerge))
  end

  test "should show emerge" do
    get :show, :id => @emerge.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @emerge.to_param
    assert_response :success
  end

  test "should update emerge" do
    put :update, :id => @emerge.to_param, :emerge => @emerge.attributes
    assert_redirected_to emerge_path(assigns(:emerge))
  end

  test "should destroy emerge" do
    assert_difference('Emerge.count', -1) do
      delete :destroy, :id => @emerge.to_param
    end

    assert_redirected_to emerges_path
  end
end
