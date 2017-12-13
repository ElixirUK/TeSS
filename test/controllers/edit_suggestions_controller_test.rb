require 'test_helper'

class EditSuggestionsControllerTest < ActionController::TestCase

  include Devise::Test::ControllerHelpers

  def setup
    @material = materials(:good_material)
  end

  test 'please log in first' do
    post :create,  type: 'Material', id: @material.id, material: {}
    assert :forbidden
  end

  test 'should create suggestion' do
    sign_in users(:another_regular_user)
    assert_difference('EditSuggestion.count') do
      post :create, type: 'Material',
                    id: @material.id,
                    material:
                    {
                      title: 'Training Material Example Updated',
                      content_provider_id: 15,
                      authors: ['First Author', 'Second Author']
                    }
      assert_redirected_to @material
    end
    suggestion = EditSuggestion.last
    assert_equal(suggestion.data_fields['authors'].count, 2)
  end


end
