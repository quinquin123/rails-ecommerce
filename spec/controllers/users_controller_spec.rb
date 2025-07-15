# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
    
  let(:admin) { create(:user, role: 'admin') }
  let(:user) { create(:user) }

  before { sign_in admin }

  describe 'GET #index' do
    it 'returns success' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'PATCH #approve' do
    it 'updates user status to active' do
      patch :approve, params: { id: user.id }
      expect(user.reload.status).to eq('active')
    end
  end

  describe 'PATCH #block' do
    it 'updates user status to blocked' do
      patch :block, params: { id: user.id }
      expect(user.reload.status).to eq('blocked')
    end
  end
end
