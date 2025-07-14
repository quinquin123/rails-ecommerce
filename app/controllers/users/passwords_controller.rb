class Users::PasswordsController < Devise::PasswordsController
  # GET /users/password/new
  def new
    super
  end

  # POST /users/password
  def create
    email = params[resource_name][:email]&.downcase
    Rails.logger.info "Attempting to send reset password email to: #{email}"
    unless email =~ Devise.email_regexp
      self.resource = resource_class.new(email: params[resource_name][:email])
      resource.errors.add(:email, "Please enter a valid email address.")
      flash.now[:alert] = "Invalid email address."
      render :new, status: :unprocessable_entity
      return
    end

    self.resource = resource_class.find_by(email: email)
    if resource
      Rails.logger.info "User found: #{resource.email}, sending reset instructions"
      resource.send_reset_password_instructions
      flash[:notice] = "Password reset instructions have been sent #{resource.email}. Please check your browser tab"
      redirect_to new_user_session_path
    else
      Rails.logger.info "Email not found: #{email}"
      self.resource = resource_class.new(email: params[resource_name][:email])
      resource.errors.add(:email, "Email not found in the system.")
      flash.now[:alert] = "Email not found in the system."
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /users/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash[:notice] = "Your password has been changed successfully. Please log in."
      redirect_to new_user_session_path
    else
      flash.now[:alert] = "Unable to reset password: #{resource.errors.full_messages.join(', ')}."
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  def resource_params
    params.require(resource_name).permit(:reset_password_token, :password, :password_confirmation)
  end
end