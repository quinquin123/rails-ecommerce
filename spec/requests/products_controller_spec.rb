require 'rails_helper'

RSpec.describe "ProductsController", type: :request do
  let(:category) { create(:category) }

  let(:seller) { create(:user, role: 'seller') }
  let(:admin) { create(:user, role: 'admin') }
  let(:buyer) { create(:user, role: 'buyer') }

  let(:product) { create(:product, seller: seller, category: category, status: 'active') }
  let(:deleted_product) { create(:product, status: 'deleted') }

  describe "GET /products" do
    it "shows the product list" do
      get products_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(product.title)
    end
  end

  describe "GET /products/:id" do
    context "as guest" do
      it "shows active product" do
        get product_path(product)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(product.title)
      end

      it "denies access to deleted product" do
        expect {
          get product_path(deleted_product)
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "POST /products" do
    let(:valid_params) do
      {
        product: {
          title: "Test Product",
          description: "Desc",
          price: 10.0,
          category_id: category.id,
          preview_url: "http://example.com",
          download_url: "http://example.com",
          tags: []
        }
      }
    end

    let(:invalid_params) do
      {
        product: {
          title: "",
          price: -5,
          category_id: nil
        }
      }
    end

    context "as seller" do
      before { sign_in seller }

      it "creates product successfully" do
        post products_path, params: valid_params
        expect(response).to redirect_to(Product.last)
        follow_redirect!
        expect(response.body).to include("Product created successfully.")
      end

      it "fails with invalid params" do
        post products_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("can't be blank")
      end
    end
  end

  describe "PATCH /products/:id" do
    before { sign_in seller }

    it "updates product successfully" do
      patch product_path(product), params: {
        product: { title: "Updated Title" }
      }
      expect(response).to redirect_to(product)
      follow_redirect!
      expect(response.body).to include("Product updated successfully.")
    end

    it "fails with invalid params" do
      patch product_path(product), params: {
        product: { price: -100 }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("must be greater than or equal to 0")
    end
  end

  describe "DELETE /products/:id" do
    before { sign_in seller }

    it "marks product as deleted" do
      delete product_path(product)
      expect(response).to redirect_to(products_path)
      follow_redirect!
      expect(response.body).to include("Product deleted successfully.")
      expect(product.reload.status).to eq("deleted")
    end
  end

  describe "GET /products/search" do
    let!(:active_product) { create(:product, title: "Ruby Book", status: 'active') }
    let!(:deleted_product) { create(:product, title: "Hidden Book", status: 'deleted') }

    context "as guest" do
      it "shows only active products" do
        get search_products_path, params: { query: "Book" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Ruby Book")
        expect(response.body).not_to include("Hidden Book")
      end
    end

    context "as signed in seller" do
      before { sign_in seller }

      it "uses policy scope" do
        get search_products_path, params: { query: "Book" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Ruby Book")
      end
    end
  end
end
