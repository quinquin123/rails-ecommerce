require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is invalid without a role" do
      user = User.new(email: "abc@gmail.com", password: "password")
      user.role = nil
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("can't be blank")
    end

    it "is invalid if email is not a gmail address" do
      user = User.new(email: "abc@yahoo.com", role: "buyer", password: "password")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("must belong to the domain @gmail.com")
    end

    it "is valid with a gmail email and role" do
      user = User.new(email: "abc@gmail.com", role: "buyer", password: "password")
      expect(user).to be_valid
    end
  end

  describe "enums" do
    it "defines correct roles" do
      expect(User.roles.keys).to contain_exactly("buyer", "seller", "admin")
    end

    it "defines correct statuses" do
      expect(User.statuses.keys).to contain_exactly("active", "blocked", "pending_approval", "inactive")
    end
  end

  describe "callbacks" do
    it "sets default role and status on new record" do
      user = User.new(email: "abc@gmail.com", password: "password")
      expect(user.role).to eq("buyer")
      expect(user.status).to eq("active")
    end
  end

  describe "associations" do
    it { should have_one(:cart).with_foreign_key(:buyer_id).dependent(:destroy) }
    it { should have_many(:products).with_foreign_key(:seller_id).dependent(:destroy) }
    it { should have_many(:orders).with_foreign_key(:buyer_id) }
  end

  describe "#has_purchased?" do
    let(:user) { create(:user, role: :buyer, email: "abc@gmail.com") }

    before do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return('image/png')
    end
    
    context "when the user has purchased the product" do
      it "returns true" do
        product = create(:product, price: 100)
        order = create(:order, buyer: user, status: "success")
        create(:order_item, order: order, product: product)

        expect(user.has_purchased?(product)).to be true
      end
    end

    context "when the user has not purchased the product" do
      it "returns false" do
        product = create(:product, price: 100)
        expect(user.has_purchased?(product)).to be false
      end
    end

    context "when product price is zero" do
      it "returns false" do
        free_product = create(:product, price: 0)
        expect(user.has_purchased?(free_product)).to be false
      end
    end
  end
end