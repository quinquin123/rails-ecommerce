class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  def create
    login_params = params.require(:user).permit(:email, :password)

    user = User.find_by(email: login_params[:email])

    if user && user.valid_password?(login_params[:password])
      self.resource = user
      sign_in(resource_name, resource)

      token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first rescue nil

      render json: {
        user: {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          role: resource.role,
          status: resource.status,
          created_at: resource.created_at,
          updated_at: resource.updated_at
        },
        message: 'Logged in.',
        token: token
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    if current_user
      render json: { message: 'Logged out.' }, status: :ok
    else
      render json: { message: 'User already logged out.' }, status: :unauthorized
    end
  end
end
