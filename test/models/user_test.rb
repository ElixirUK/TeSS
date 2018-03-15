require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    mock_images
    @user_data = users(:regular_user)
    @user_params = { username: 'new_user', password: '12345678', email: 'new-user@example.com' }
    User.get_default_user
  end

  test "should save new user" do
    user = User.new(@user_params)
    assert user.save, "Did not save user"
  end

  test "should set default role after saving new user" do
    user = User.new(@user_params)
    assert_not_instance_of Role, user.role
    user.save
    assert_instance_of Role, user.role
    assert_equal 'registered_user', user.role.name
  end

  test 'default role should be configurable' do
    default_role = TeSS::Config.default_role
    begin
      TeSS::Config.default_role = 'basic_user'
      user = User.create!(@user_params)
      assert_equal 'basic_user', user.role.name
    ensure
      TeSS::Config.default_role = default_role
    end
  end

  test "should set default profile after saving new user" do
    user = User.new(@user_params)
    assert_not_instance_of Profile, user.profile
    user.save
    assert_instance_of Profile, user.profile
    assert_equal user.profile.user, user
  end

  test "should not save user with nil email" do
    user = User.new(@user_params.merge(email: nil))
    assert_not user.save, 'Saved user with nil e-mail address field'
  end

  test "should not save user with empty email" do
    user = User.new(@user_params.merge(email: ''))
    assert_not user.save, 'Saved user with empty e-mail address field'
  end

  test "should not save user without valid email format" do
    user = User.new(@user_params.merge(email: 'horse'))
    assert_not user.save, 'Saved user with invalid e-mail address'
  end

  test "should not save with nil password" do
    user = User.new(@user_params.merge(password: nil))
    assert user.password_required?
    refute user.using_omniauth?
    assert_not user.save, 'Saved user with no password'
  end

  test "should save with nil password if using omniauth" do
    user = User.new(@user_params.merge(password: nil, provider: 'elixir_aai', uid: 'abcdefg'))
    refute user.password_required?
    assert user.using_omniauth?
    assert user.save
    assert user.reload.encrypted_password.blank?
  end

  test "should not save with password under 8 characters" do
    user = User.new(@user_params.merge(password: '1234567'))
    assert_not user.save, 'Allowed a user to have a password under 8 characters'
  end

  test "should not save two users with same username" do
    user1 = User.new(@user_params.merge(email: "#{@user_data.email}2"))
    user2 = User.new(@user_params.merge(email: "#{@user_data.email}1"))
    assert user1.save, 'Did not save the first user'
    assert_not user2.save, 'Saved the second user with same username as first'
  end

  test "should not save two users with same email" do
    user1 = User.new(@user_params.merge(username: "#{@user_data.username}2"))
    user2 = User.new(@user_params.merge(username: "#{@user_data.username}1"))
    assert user1.save, 'Did not save the first user'
    assert_not user2.save, 'Saved a second user with same e-mail address'
  end

  test 'should destroy user' do
    user = users(:regular_user)
    assert_difference('User.count', -1) do
      user.destroy
    end
  end

  test 'should get full name' do
    assert_equal 'Reginald User', users(:regular_user).full_name
    assert_equal 'Anthony', users(:another_regular_user).full_name
    assert_nil User.new.full_name
  end

  test 'check if banned' do
    refute users(:regular_user).banned?
    refute users(:regular_user).shadowbanned?

    assert users(:banned_user).banned?
    refute users(:banned_user).shadowbanned?

    assert users(:shadowbanned_user).banned?
    assert users(:shadowbanned_user).shadowbanned?
  end

  test 'shadowbanned scope' do
    assert_includes User.shadowbanned, users(:shadowbanned_user)
    assert_not_includes User.shadowbanned, users(:regular_user)
  end

  test 'change email' do
    user = users(:regular_user)
    user.email = 'new-email@example.com'
    assert user.save
  end
end
