require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:role) }

    it 'validates email domain' do
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('phải thuộc domain @gmail.com')
    end

    it 'accepts gmail domain' do
      user = build(:user, email: 'test@gmail.com')
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it { should have_one(:cart).with_foreign_key(:buyer_id).dependent(:destroy) }
  end

  describe 'enums' do
    it 'defines string-based enum for role' do
      expect(User.roles).to eq({ 'buyer' => 'buyer', 'seller' => 'seller', 'admin' => 'admin' })
    end

    it 'defines string-based enum for status' do
      expect(User.statuses).to eq({
        'active' => 'active',
        'blocked' => 'blocked',
        'pending_approval' => 'pending_approval',
        'inactive' => 'inactive'
      })
    end
  end

  describe 'callbacks' do
    it 'sets default role to buyer when not set' do
      user = User.new 
      expect(user.role).to eq('buyer')
    end

    it 'sets default status to active when not set' do
      user = User.new 
      expect(user.status).to eq('active')
    end
  end
end
