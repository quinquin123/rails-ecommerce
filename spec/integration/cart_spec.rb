require 'swagger_helper'

RSpec.describe 'API::V1::Carts', type: :request do
  # GET api/v1/cart
  path '/api/v1/cart' do
    get 'View current cart' do
      tags 'Cart'
      security [ bearerAuth: [] ]

      response '200', 'OK' do
        let(:user) { create(:user, role: :buyer) }
        let(:Authorization) { "Bearer #{user_token(user)}" }

        run_test!
      end
      response '403', 'Forbidden for seller' do
        let(:seller) { create(:user, role: :seller) }
        let(:Authorization) { "Bearer #{user_token(seller)}" }

        run_test!
      end
      response '403', 'Forbidden for admin' do
        let(:admin) { create(:user, role: :admin) }
        let(:Authorization) { "Bearer #{user_token(seller)}" }

        run_test!
      end
    end
  end

  #POST /api/v1/cart/add_item
  path '/api/v1/cart/add_item' do
    post 'Add product to cart' do
      tags 'Cart'
      consumes 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :string, format: :uuid  }
        },
        required: ['product_id']
      }

      response '201', 'Added successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user_token(user)}" }
        let(:product) { create(:product) }
        let(:body) { { product_id: product.id } }

        run_test!
      end

      response '422', 'Product already in cart' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user_token(user)}" }
        let(:product) { create(:product) }
        before { create(:cart_item, cart: user.cart, product: product) }
        let(:body) { { product_id: product.id } }

        run_test!
      end
    end
  end

  # DELETE api/v1/cart/remove_item
  path '/api/v1/cart/remove_item' do
    delete 'Remove product from cart' do
      tags 'Cart'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :query, type: :string

      response '200', 'Removed successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user_token(user)}" }
        let(:product) { create(:product) }
        let!(:item) { create(:cart_item, cart: user.cart, product: product) }
        let(:id) { item.id }

        run_test!
      end
    end
  end
end
