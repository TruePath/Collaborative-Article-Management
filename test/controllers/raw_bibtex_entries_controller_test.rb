require 'test_helper'

class RawBibtexEntriesControllerTest < ActionController::TestCase
  setup do
    @raw_bibtex_entry = raw_bibtex_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:raw_bibtex_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create raw_bibtex_entry" do
    assert_difference('RawBibtexEntry.count') do
      post :create, raw_bibtex_entry: {  }
    end

    assert_redirected_to raw_bibtex_entry_path(assigns(:raw_bibtex_entry))
  end

  test "should show raw_bibtex_entry" do
    get :show, id: @raw_bibtex_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @raw_bibtex_entry
    assert_response :success
  end

  test "should update raw_bibtex_entry" do
    patch :update, id: @raw_bibtex_entry, raw_bibtex_entry: {  }
    assert_redirected_to raw_bibtex_entry_path(assigns(:raw_bibtex_entry))
  end

  test "should destroy raw_bibtex_entry" do
    assert_difference('RawBibtexEntry.count', -1) do
      delete :destroy, id: @raw_bibtex_entry
    end

    assert_redirected_to raw_bibtex_entries_path
  end
end
