class CurationTaskPolicy < ApplicationPolicy
  # copied from user_policy, each function needs to be defined

  def index?
    true
  end

  def show?
    # Anyone (not even logged in) can see users' pages, with restrictions in view
    # that owners and admins only can see their authentication token and email
    true
  end

  def new?
    #only admin role can create users, TODO: Does this restrict API creation?
    @user && @user.is_admin?
  end

end