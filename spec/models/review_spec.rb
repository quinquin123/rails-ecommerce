# spec/models/review_spec.rb

require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:buyer) { create(:user) }
  let(:product) { create(:product, skip_image_validation: true) }
  let(:order) { create(:order, buyer: buyer) }
  
  let(:valid_attributes) do
    {
      buyer: buyer,
      product: product,
      order: order,
      rating: 5,
      comment: 'Great product!'
    }
  end

  describe 'associations' do
    it { should belong_to(:buyer).class_name('User') }
    it { should belong_to(:product) }
    it { should belong_to(:order) }
  end

  describe 'validations' do
    subject { Review.new(valid_attributes) }

    it { should validate_presence_of(:rating) }
    it { should validate_inclusion_of(:rating).in_range(1..5) }

    context 'uniqueness validation' do
      let!(:existing_review) { create(:review, buyer: buyer, product: product) }
      
      it 'should not allow duplicate reviews from same buyer for same product' do
        new_review = Review.new(valid_attributes.merge(buyer: buyer, product: product))
        expect(new_review).not_to be_valid
        expect(new_review.errors[:buyer_id]).to include('has already been taken')
      end

      it 'should allow reviews from same buyer for different products' do
        new_product = create(:product)
        new_review = Review.new(valid_attributes.merge(product: new_product))
        expect(new_review).to be_valid
      end

      it 'should allow reviews from different buyers for same product' do
        new_buyer = create(:user)
        new_review = Review.new(valid_attributes.merge(buyer: new_buyer))
        expect(new_review).to be_valid
      end
    end
  end

  describe 'callbacks' do
    context 'after_save' do
      let(:product) { create(:product, average_rating: 0, reviews_count: 0) }

      it 'updates product rating and reviews count after create' do
        review = Review.create!(valid_attributes.merge(rating: 4))
        
        product.reload
        expect(product.average_rating).to eq(4.0)
        expect(product.reviews_count).to eq(1)
      end

      it 'updates product rating when review is updated' do
        review = Review.create!(valid_attributes.merge(rating: 1))
        review.update!(rating: 5)
        
        product.reload
        expect(product.average_rating).to eq(5.0)
      end
    end

    context 'after_destroy' do
      let(:product) { create(:product) }

      it 'updates product rating when review is destroyed' do
        review1 = create(:review, product: product, rating: 5)
        review2 = create(:review, product: product, rating: 3)
        
        expect(product.average_rating).to eq(4.0)
        expect(product.reviews_count).to eq(2)
        
        review1.destroy
        
        product.reload
        expect(product.average_rating).to eq(3.0)
        expect(product.reviews_count).to eq(1)
      end
    end
  end

  describe '#update_product_rating' do
    let(:product) { create(:product) }
    let!(:review1) { create(:review, product: product, rating: 5) }
    let!(:review2) { create(:review, product: product, rating: 3) }

    it 'calculates correct average rating' do
      product.reviews.first.update_product_rating
      expect(product.average_rating).to eq(4.0)
    end

    it 'rounds average rating to 1 decimal place' do
      create(:review, product: product, rating: 4)
      product.reviews.first.update_product_rating
      expect(product.average_rating).to eq(4.0) # (5+3+4)/3 = 4.0
    end

    it 'updates reviews count' do
      product.reviews.first.update_product_rating
      expect(product.reviews_count).to eq(2)
    end
  end
end