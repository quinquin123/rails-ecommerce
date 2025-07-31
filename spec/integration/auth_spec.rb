require 'swagger_helper'

RSpec.describe 'Authentication', type: :request do
  path '/api/v1/login' do
    post 'User login' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }
      request_body_example value: {
        user: {
          email: "trickingquinquin@gmail.com",
          password: "123456"
        }
      }
      response '200', 'Login successfully' do
        header 'Authorization', type: :string, description: 'JWT token returned after successful login'
        run_test!
      end

      response '401', 'Incorrect login information' do
        run_test!
      end
    end
  end

  path '/api/v1/signup' do
    post 'User Register' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: ['name', 'email', 'password', 'password_confirmation']
      }

      response '201', 'Register successfully' do
        run_test!
      end

      response '422', 'Authentication error' do
        run_test!
      end
    end
  end

  path '/api/v1/logout' do
    delete 'Log out the user' do
      tags 'Auth'
      security [{ bearerAuth: [] }]

      response '200', 'Log out successfully' do
        run_test!
      end

      response '401', 'Not authentic' do
        run_test!
      end
    end
  end
end
