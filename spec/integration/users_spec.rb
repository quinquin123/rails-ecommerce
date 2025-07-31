require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get 'Get list of users' do
      tags 'Users'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, description: 'Page'
      parameter name: :per_page, in: :query, type: :integer, description: 'Quantity per page'
      response '200', 'List of users' do
        run_test!
      end
    end
    post 'Create a new user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string, format: :email },
          password: { type: :string, minLength: 6 },
          role: { type: :string, enum: ['admin', 'seller', 'buyer'] },
          status: { type: :string, enum: ['active', 'blocked', 'pending_approval', 'inactive'] }
        },
        required: ['email', 'password', 'role']
      }
      request_body_example value: {
        user: {
          name: "quin",
          email: "trickingquinquin@gmail.com",
          password: "123456",
          role: "buyer",
          status: "active"
        }
      }
      response '201', 'Created successfully' do
        run_test!
      end

      response '422', 'Authentication error' do
        run_test!
      end
    end
  end
  path '/api/v1/users/{id}' do
    get 'View user details' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      response '200', 'User information' do
        run_test!
      end
    end
    put 'Update user information' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string, format: :email },
              role: { type: :string },
              status: { type: :string }
            }
          }
        },
        required: ['user']
      }

      response '200', 'Updated successfully' do
        run_test!
      end

      response '422', 'Authentication error' do
        run_test!
      end
    end
    delete 'Delete User' do
      tags 'Users'
      parameter name: :id, in: :path, type: :string

      response '200', 'Deleted successfully' do
        run_test!
      end
    end
  end

end
