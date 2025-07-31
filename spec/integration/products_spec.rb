require 'swagger_helper'

RSpec.describe 'API::V1::Products', type: :request do
  path '/api/v1/products' do
    get 'List products with pagination' do
      tags 'Products'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, description: 'Products per page'

      response '200', 'successful' do
        schema type: :object,
          properties: {
            products: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  price: { type: :number },
                  description: { type: :string },
                  preview_image_url: { type: :string, nullable: true },
                  seller_name: { type: :string, nullable: true },
                  category: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string }
                    }
                  }
                }
              }
            },
            meta: {
              type: :object,
              properties: {
                current_page: { type: :integer },
                total_pages: { type: :integer },
                total_count: { type: :integer }
              }
            }
          }

        let!(:category) { create(:category) }
        let!(:user) { create(:user, role: :seller) }
        let!(:products) do
          create_list(:product, 3, user: user, category: category)
        end

        run_test!
      end
    end
  end
end
