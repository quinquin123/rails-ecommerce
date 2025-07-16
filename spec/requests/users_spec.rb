# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:admin) { create(:user, role: 'admin') }
  let(:user) { create(:user) }

  before { sign_in admin }

  describe 'GET /users' do
    it 'returns success' do
      get users_path
      expect(response).to be_successful
    end
  end

  describe 'PATCH /users/:id/approve' do
    it 'updates user status to active' do
      patch approve_user_path(user)
      expect(user.reload.status).to eq('active')
    end
  end

  describe 'PATCH /users/:id/block' do
    it 'updates user status to blocked' do
      patch block_user_path(user)
      expect(user.reload.status).to eq('blocked')
    end
  end
end
