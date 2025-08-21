class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :approve, :block]

  def index
    @users = policy_scope(User)
    authorize User
    @users = @users.page(params[:page]).per(10)
  end

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to @user, notice: 'User updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    authorize @user, :approve?
    @user.update(status: 'active')
    redirect_to users_path, notice: 'User approved successfully.'
  end

  def refuse
    authorize @user, :refuse?
    @user.update(status: 'inactive')
    redirect_to users_path, notice: 'User refused successfully'
  end

  def block
    authorize @user, :block?
    @user.update(status: 'blocked')
    redirect_to users_path, notice: 'User blocked successfully.'
  end

  private

  def set_user
    if params[:id] == 'current'
      @user = current_user
    else
      @user = User.find_by(id: params[:id])
      redirect_to root_path, alert: 'User not found' unless @user
    end
  end

  def user_params
    return {} unless params[:user]
    if current_user.admin?
      params.require(:user).permit(:name, :email, :role, :status, :password)
    else
      params.require(:user).permit(:name, :email, :password)
    end
  end

end
