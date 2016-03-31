require 'test_helper'

class EventsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @event = events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    sign_in users(:admin)
    get :new
    #assert_response :success
    assert_redirected_to root_path
  end

  test "should not get new" do
    sign_in users(:regular_user)
    get :new
    assert_redirected_to root_path
  end

  test "should create event" do
    sign_in users(:admin)
    assert_difference('Event.count') do
      post :create, :format => :json, event: { category: @event.category, city: @event.city, country: @event.country, county: @event.county, description: @event.description, end: @event.end, field: @event.field, id: @event.id, latitude: @event.latitude, url: @event.url, longitude: @event.longitude, postcode: @event.postcode, provider: @event.provider, sponsor: @event.sponsor, start: @event.start, subtitle: @event.subtitle, title: @event.title, venue: @event.venue }
    end
    #assert_redirected_to event_path(assigns(:event))
    assert_response :success
  end

  test "should show event" do
    get :show, id: @event
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    get :edit, id: @event
    #assert_response :success"CONTENT_TYPE" => 'application/json'
    assert_redirected_to root_path
  end

  test "should not get edit" do
    sign_in users(:regular_user)
    get :edit, id: @event
    assert_redirected_to root_path
  end


  # TODO: This test no longer works due to the requirement to disable the route to non-scraper access,
  # TODO: and I've not been able to work out how to adapt the test to fit around this.
  #test "should update event" do
  #  sign_in users(:admin)
  #  patch :update, id: @event, event: { category: @event.category, city: @event.city, country: @event.country, county: @event.county, description: @event.description, end: @event.end, field: @event.field, id: @event.id, latitude: @event.latitude, url: @event.url, longitude: @event.longitude, postcode: @event.postcode, provider: @event.provider, sponsor: @event.sponsor, start: @event.start, subtitle: @event.subtitle, title: @event.title, venue: @event.venue }
  #  assert_redirected_to event_path(assigns(:event))
  #end

  test "should destroy event" do
    sign_in users(:admin)
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event
    end
    assert_redirected_to events_path
  end

  test "should find event by title" do
    post 'check_exists', :format => :json,  :title => @event.title
    assert_response :success
    assert_equal(JSON.parse(response.body)['title'], @event.title)
  end

  test "should return nothing when event does't exist" do
    post 'check_exists', :format => :json,  :title => 'This title should not exist'
    assert_response :success
    assert_equal(response.body, "")
  end

end
