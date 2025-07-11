class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :approve, :block]

  def index
    @users = policy_scope(User)
    authorize User
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

  def block
    authorize @user, :block?
    @user.update(status: 'blocked')
    redirect_to users_path, notice: 'User blocked successfully.'
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    redirect_to root_path, alert: 'User not found' unless @user
  end

  def user_params
    return {} unless params[:user]
    if current_user.admin?
      params.require(:user).permit(:name, :email, :role, :status)
    else
      params.require(:user).permit(:name, :email)
    end
  end

end
