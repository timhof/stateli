require 'test_helper'

class PocketsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pockets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pocket" do
    assert_difference('Pocket.count') do
      post :create, :pocket => { }
    end

    assert_redirected_to pocket_path(assigns(:pocket))
  end

  test "should show pocket" do
    get :show, :id => pockets(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pockets(:one).to_param
    assert_response :success
  end

  test "should update pocket" do
    put :update, :id => pockets(:one).to_param, :pocket => { }
    assert_redirected_to pocket_path(assigns(:pocket))
  end

  test "should destroy pocket" do
    assert_difference('Pocket.count', -1) do
      delete :destroy, :id => pockets(:one).to_param
    end

    assert_redirected_to pockets_path
  end
end
