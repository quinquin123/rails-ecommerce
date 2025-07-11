class ApplicationController < ActionController::Base
    include Pundit::Authorization
    before_action :authenticate_user!, except: [:index, :show], if: :products_controller?
    after_action :verify_authorized, unless: -> { devise_controller? || action_name == 'index' }
    after_action :verify_policy_scoped, if: -> { action_name == 'index' && !devise_controller? }

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
        flash[:alert] = "You are not authorized to perform this action." 
        redirect_to(request.referrer || root_path) 
    end

    def products_controller?
        controller_name == 'products'
    end
end