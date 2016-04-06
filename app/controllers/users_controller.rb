class UsersController < ApplicationController

  prepend_before_action :set_user, only: [:show, :edit, :update, :destroy, :change_token]
  #
  # # Skip the parent's before_action, which is defined only on some methods
  # skip_before_action :authenticate_user!
  # # and define it on all methods
  # before_action :authenticate_user!

  include TeSS::BreadCrumbs

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    authorize User
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize @user
  end

  # POST /users
  # POST /users.json
  def create
    authorize User
    @user = User.new(user_params)
    logger.info "PARAMS: #{user_params}"
    logger.info "USER: #{@user.inspect}"

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  #THIS IS FOR UPDATING PROFILES
  def update
    authorize @user
    respond_to do |format|
      if @user.profile.update(profile_params)
        format.html { redirect_to @user, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize @user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def change_token
    authorize @user
    if @user.authentication_token.nil?
      flash[:alert] = "Authentication token cannot be set to nil - action not allowed (status code: 422 Unprocessable Entity)."
      handle_error(:unprocessable_entity) and return
    end
    @user.authentication_token = Devise.friendly_token
    if @user.save
      flash[:notice] = "Authentication token successfully regenerated."
      redirect_to @user
    else
      flash[:alert] = "Failed to regenerate Authentication token (status code: 422 Unprocessable Entity)."
      handle_error(:unprocessable_entity)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit!
  end
  def profile_params
    params.require(:user).require(:profile).permit!
  end

end
