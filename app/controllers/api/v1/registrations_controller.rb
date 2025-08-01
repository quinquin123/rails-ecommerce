class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  def create
    user = User.new(sign_up_params)

    if user.save
      sign_in(user) 

      render json: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role
        },
        message: 'Registered successfully'
      }, status: :created
    else
      render json: {
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:registration).permit(:email, :password, :password_confirmation, :name, :role)
  end
end
