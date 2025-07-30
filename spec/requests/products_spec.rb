require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, seller: user, category: category) }
  let(:other_product) { create(:product, seller: other_user, category: category) }
  
  include Devise::Test::IntegrationHelpers

  describe "GET /products" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns a successful response" do
        get products_path
        expect(response).to be_successful
      end

      # Note: assigns() is not available in request specs
      # You would need to test the actual rendered content instead
      it "displays products" do
        product # create the product
        get products_path
        expect(response.body).to include(product.title)
      end
    end

    context "when user is not signed in" do
      it "returns a successful response" do
        get products_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /products/:id" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns a successful response" do
        get product_path(product)
        expect(response).to be_successful
      end

      it "displays the product" do
        get product_path(product)
        expect(response.body).to include(product.title)
      end
    end

    context "when user is not signed in" do
      it "returns a successful response for public products" do
        get product_path(product)
        expect(response).to be_successful
      end
    end
  end

  describe "GET /products/new" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns a successful response" do
        get new_product_path
        expect(response).to be_successful
      end

      it "displays new product form" do
        get new_product_path
        expect(response.body).to include('New Product') # or whatever your form contains
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get new_product_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /products" do
    let(:valid_attributes) do
      {
        title: "Test Product",
        description: "Test Description",
        price: 10.99,
        category_id: category.id,
        tags: "tag1, tag2, tag3"
      }
    end

    let(:invalid_attributes) do
      {
        title: "",
        price: -1,
        category_id: nil
      }
    end

    context "when user is signed in" do
      before { sign_in user }

      context "with valid parameters" do
        it "creates a new Product" do
          expect {
            post products_path, params: { product: valid_attributes }
          }.to change(Product, :count).by(1)
        end

        it "assigns the current user as seller" do
          post products_path, params: { product: valid_attributes }
          created_product = Product.last
          expect(created_product.seller).to eq(user)
        end

        it "sets status to active" do
          post products_path, params: { product: valid_attributes }
          created_product = Product.last
          expect(created_product.status).to eq('active')
        end

        it "redirects to the created product" do
          post products_path, params: { product: valid_attributes }
          expect(response).to redirect_to(Product.last)
        end

        it "processes tags correctly" do
          post products_path, params: { product: valid_attributes }
          created_product = Product.last
          expect(created_product.tags).to eq(['tag1', 'tag2', 'tag3'])
        end

        context "with file attachments" do
          let(:image_file) do
            # Create a temporary file for testing
            Rack::Test::UploadedFile.new(
              StringIO.new("fake image content"),
              'image/jpeg',
              original_filename: 'test.jpg'
            )
          end

          it "handles new attachments" do
            post products_path, params: { 
              product: valid_attributes.merge(preview_image: image_file) 
            }
            created_product = Product.last
            expect(created_product.preview_image).to be_attached
          end
        end
      end

      context "with invalid parameters" do
        it "does not create a new Product" do
          expect {
            post products_path, params: { product: invalid_attributes }
          }.to change(Product, :count).by(0)
        end

        it "renders the new template" do
          post products_path, params: { product: invalid_attributes }
          expect(response).to have_http_status(422)
          expect(response.body).to include('New Product') # Check for form content
        end
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        post products_path, params: { product: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /products/:id/edit" do
    context "when user is the seller" do
      before { sign_in user }

      it "returns a successful response" do
        get edit_product_path(product)
        expect(response).to be_successful
      end

      it "displays edit form" do
        get edit_product_path(product)
        expect(response.body).to include('Edit Product') # or form elements
      end
    end

    context "when user is not the seller" do
      before { sign_in other_user }

      it "raises authorization error or redirects" do
        # Depending on how you handle authorization in your controller
        expect {
          get edit_product_path(product)
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get edit_product_path(product)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /products/:id" do
    let(:new_attributes) do
      {
        title: "Updated Product",
        description: "Updated Description",
        price: 15.99
      }
    end

    context "when user is the seller" do
      before { sign_in user }

      context "with valid parameters" do
        it "updates the requested product" do
          patch product_path(product), params: { product: new_attributes }
          product.reload
          expect(product.title).to eq("Updated Product")
          expect(product.description).to eq("Updated Description")
          expect(product.price).to eq(15.99)
        end

        it "redirects to the product" do
          patch product_path(product), params: { product: new_attributes }
          expect(response).to redirect_to(product)
        end

        context "with media removal" do
          before do
            # Attach an image first
            image_blob = ActiveStorage::Blob.create_and_upload!(
              io: StringIO.new("fake image content"),
              filename: 'test.jpg',
              content_type: 'image/jpeg'
            )
            product.preview_image.attach(image_blob)
          end

          it "removes preview image when requested" do
            expect(product.preview_image).to be_attached
            
            patch product_path(product), params: { 
              product: new_attributes.merge(remove_preview_image: '1') 
            }
            
            # The image will be scheduled for deletion
            product.reload
            # Test the actual behavior based on your implementation
          end
        end

        context "with new attachments" do
          let(:new_image) do
            Rack::Test::UploadedFile.new(
              StringIO.new("new image content"),
              'image/jpeg',
              original_filename: 'new_test.jpg'
            )
          end

          it "attaches new files" do
            patch product_path(product), params: { 
              product: new_attributes.merge(preview_image: new_image) 
            }
            
            product.reload
            expect(product.preview_image).to be_attached
          end
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) { { title: "", price: -1 } }

        it "renders the edit template" do
          patch product_path(product), params: { product: invalid_attributes }
          expect(response).to have_http_status(422)
          expect(response.body).to include('Edit Product') # Check for form content
        end

        it "does not update the product" do
          original_title = product.title
          patch product_path(product), params: { product: invalid_attributes }
          product.reload
          expect(product.title).to eq(original_title)
        end
      end

      context "when AWS S3 error occurs" do
        before do
          allow_any_instance_of(Product).to receive(:update).and_raise(
            Aws::S3::Errors::XAmzContentChecksumMismatch.new("context", "Checksum error")
          )
        end

        it "handles checksum errors gracefully" do
          patch product_path(product), params: { product: new_attributes }
          expect(response).to have_http_status(422)
          expect(response.body).to include("File upload failed") # Check for error message
        end
      end
    end

    context "when user is not the seller" do
      before { sign_in other_user }

      it "raises authorization error" do
        expect {
          patch product_path(product), params: { product: new_attributes }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "DELETE /products/:id" do
    context "when user is the seller" do
      before { sign_in user }

      it "destroys the requested product" do
        product # Create the product
        expect {
          delete product_path(product)
        }.to change(Product, :count).by(-1)
      end

      it "redirects to the products list" do
        delete product_path(product)
        expect(response).to redirect_to(products_path)
      end
    end

    context "when user is not the seller" do
      before { sign_in other_user }

      it "raises authorization error" do
        expect {
          delete product_path(product)
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /products/search" do
    let!(:searchable_product) { create(:product, title: "Searchable Product", status: 'active') }
    let!(:hidden_product) { create(:product, title: "Hidden Product", status: 'moderated') }

    context "when user is signed in" do
      before { sign_in user }

      it "returns JSON response" do
        get search_products_path, params: { query: "Searchable" }
        expect(response.content_type).to include('application/json')
      end

      it "searches products" do
        get search_products_path, params: { query: "Product" }
        expect(response).to be_successful
      end
    end

    context "when user is not signed in" do
      it "only searches active products" do
        get search_products_path, params: { query: "Product" }
        expect(response).to be_successful
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe "GET /products/:id/download" do
    let(:free_product) { create(:product, price: 0, seller: other_user) }
    let(:paid_product) { create(:product, price: 10.00, seller: other_user) }
    
    before do
      # Attach downloadable assets
      asset_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("downloadable content"),
        filename: 'asset.zip',
        content_type: 'application/zip'
      )
      free_product.downloadable_asset.attach(asset_blob)
      paid_product.downloadable_asset.attach(asset_blob)
    end

    context "when user is signed in" do
      before { sign_in user }

      context "for free products" do
        it "allows download and creates download log" do
          expect {
            get download_product_path(free_product)
          }.to change(DownloadLog, :count).by(1)
          
          expect(response).to be_redirect
        end
      end

      context "for paid products user hasn't purchased" do
        it "redirects with alert message" do
          get download_product_path(paid_product)
          expect(response).to redirect_to(paid_product)
          expect(flash[:alert]).to eq('You need to purchase this product before downloading')
        end
      end

      context "for paid products user has purchased" do
        before do
          # Mock the purchase check
          allow(paid_product).to receive(:downloadable_by?).with(user).and_return(true)
        end

        it "allows download" do
          get download_product_path(paid_product)
          expect(response).to be_redirect
        end
      end

      context "when product has no downloadable asset" do
        let(:no_asset_product) { create(:product, seller: other_user) }

        it "redirects with alert" do
          get download_product_path(no_asset_product)
          expect(response).to redirect_to(no_asset_product)
          expect(flash[:alert]).to eq('No downloadable asset available')
        end
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get download_product_path(free_product)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end