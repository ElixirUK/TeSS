require 'test_helper'

class EditSuggestionsControllerTest < ActionController::TestCase

  include Devise::Test::ControllerHelpers

  def setup
    @material = materials(:good_material)
    @event = events(:one)
  end

  test 'material please log in first' do
    post :create,  type: 'Material', id: @material.id, material: {}
    assert :forbidden
  end

  test 'event please log in first' do
    post :create,  type: 'Event', id: @event.id, event: {}
    assert :forbidden
  end

  test 'material should create suggestion' do
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

  test 'event should create suggestion' do
    sign_in users(:another_regular_user)
    assert_difference('EditSuggestion.count') do
      post :create, type: 'Event',
                    id: @event.id,
                    event:
                    {
                      title: 'A proper title',
                      event_types: ['meetings_and_conferences'],
                      keywords: ['One', 'Two']
                    }
      assert_redirected_to @event
    end
    suggestion = EditSuggestion.last
    assert_equal(suggestion.data_fields['keywords'].count, 2)
    assert_equal(suggestion.data_fields['event_types'].count, 1)
    assert_equal(suggestion.data_fields['event_types'][0], 'meetings_and_conferences')
  end

end
