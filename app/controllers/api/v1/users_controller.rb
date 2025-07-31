class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :destroy, :approve, :block]
  skip_before_action :verify_authenticity_token

  def current_user
    User.find_by(email: 'admin@gmail.com') || User.first
  end
  #GET /api/v1/users
  def index
    @users = policy_scope(User)
    #Kaminari pagination
    #https://localhost:3000/users?page=2&per_page=20
    @users = @users.page(params[:page]).per(params[:per_page] || 10)
    render json: @users,
                each_serializer: UserSerializer,
                meta: pagination_meta(@users)
  end

  #GET /api/v1/users/:id
  def show
    authorize @user
    render json: @user, serializer: UserSerializer
  end

  #POST /api/v1/users
  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer),
        message: 'User created successfully'
      }, status: :created
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  #PATCH/PUT /api/v1/users/:id
  def update
    authorize @user
    if @user.update(user_params)
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer),
        message: 'User updated successfully'
      }
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  #DELETE /api/v1/users/:id
  def destroy
    authorize @user 
    if @user.destroy
      render json: { message: 'User deleted successfully' }
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  #PATCH /api/v1/users/:id/approve
  def approve
    authorize @user, :approve?
    if @user.update(status: 'active')
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer),
        message: 'User approved successfully'
      }
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  #PATCH /api/v1/users/:id/block
  def block
    authorize @user, :block?
    if @user.update(status: 'blocked')
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer),
        message: 'User blocked successfully'
      }
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
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
