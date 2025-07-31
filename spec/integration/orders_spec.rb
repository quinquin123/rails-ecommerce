require 'swagger_helper'

RSpec.describe 'api/v1/orders', type: :request do

  path '/api/v1/orders' do
    get 'List Orders' do
      tags 'Orders'
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :status, in: :query, type: :string, description: 'Filter by status'
      parameter name: :page, in: :query, type: :integer
      parameter name: :per_page, in: :query, type: :integer

      response '200', 'Order list returned' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let!(:orders) { create_list(:order, 3, user: user) }

        run_test!
      end
    end

    post 'Create Order from Cart' do
      tags 'Orders'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order, in: :body, required: true, schema: {
        type: :object,
        properties: {
          shipping_address: { type: :string },
          payment_method: { type: :string }
        },
        required: %w[shipping_address payment_method]
      }

      response '201', 'Order created successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        before do
          cart = create(:cart, user: user)
          create(:cart_item, cart: cart)
        end

        let(:order) do
          {
            shipping_address: "123 Sample Street",
            payment_method: "credit_card"
          }
        end

        run_test!
      end

      response '422', 'Cart is empty' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let(:order) { { shipping_address: "", payment_method: "" } }

        run_test!
      end
    end
  end

  path '/api/v1/orders/{id}' do
    get 'View Order Detail' do
      tags 'Orders'
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'Order found' do
        let(:user) { create(:user) }
        let(:order) { create(:order, user: user) }
        let(:id) { order.id }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        run_test!
      end

      response '404', 'Order not found' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: create(:user).id)}" }
        let(:id) { 'non-existent-id' }

        run_test!
      end
    end

    put 'Update Order Shipping Address' do
      tags 'Orders'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          shipping_address: { type: :string }
        }
      }

      response '200', 'Order updated' do
        let(:user) { create(:user) }
        let(:order) { create(:order, user: user) }
        let(:id) { order.id }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        let(:order) do
          { shipping_address: "New Updated Address" }
        end

        run_test!
      end
    end
  end

  path '/api/v1/orders/{id}/retry_payment' do
    post 'Retry Order Payment' do
      tags 'Orders'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'Retry initiated' do
        let(:user) { create(:user) }
        let(:order) { create(:order, :failed_payment, user: user) } # assuming trait exists
        let(:id) { order.id }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        run_test!
      end

      response '422', 'Order cannot be retried' do
        let(:user) { create(:user) }
        let(:order) { create(:order, :success, user: user) }
        let(:id) { order.id }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        run_test!
      end
    end
  end

  path '/api/v1/orders/{id}/refund' do
    post 'Refund Order' do
      tags 'Orders'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'Order refunded' do
        let(:user) { create(:user) }
        let(:order) { create(:order, :refundable, user: user) }
        let(:id) { order.id }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        run_test!
      end

      response '422', 'Refund denied' do
        let(:user) { create(:user) }
        let(:order) { create(:order, :success, user: user) }
        let(:id) { order.id }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        run_test!
      end
    end
  end
end
