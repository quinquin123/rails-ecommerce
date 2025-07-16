require 'rails_helper'

RSpec.describe "Products", type: :request do
    let(:admin) { create(:user, :admin) }
    let(:seller) { create(:user, :seller) }
    let(:category) { create(:category) }
    let(:product) { create(:product, seller: seller, category: category) }
    
    describe "GET /products" do
        it "shows active products for guest user" do
            product = create(:product, title: "Đèn thần kỳ", status: "active")
            get "/products"
            expect(response.body).to include(product.title)
            expect(response.body).to include("Đèn thần kỳ")
        end
    end
    describe "POST #create" do
        before { sign_in seller }

        it "creates product with valid params" do
            post products_path, params: {
                product: {
                    title: "New Product",
                    description: "Some description",
                    price: 10.0,
                    category_id: category.id,
                    status: "active"
                }
            }
            expect(Product.last.title).to eq("New Product")
            expect(response).to redirect_to(Product.last)
        end
    end
    describe "PATCH #update" do
        before { sign_in seller }

        it "updates own product" do
            patch product_path(product), params: {
                id: product.id,
                product: { title: "Updated Name" }
            }
            expect(product.reload.title).to eq("Updated Name")
            expect(response).to redirect_to(product)
        end
    end

    describe "DELETE /products/:id" do
        before { sign_in seller }

        it "marks product as deleted" do
            delete product_path(product)

            expect(product.reload.status).to eq("deleted")
            expect(response).to redirect_to(products_path)
        end
    end

    describe "GET #search" do
        it "returns filtered products for guest" do
            product 
            get search_products_path, params: { query: product.title }
            puts "STATUS: #{response.status}"
            puts "BODY: #{response.body}"
            json = JSON.parse(response.body)
            titles = json.map { |p| p["title"] }
            expect(titles).to include(product.title)
        end
    end
end
