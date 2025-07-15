# spec/policies/user_policy_spec.rb
require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }

  let(:admin) { create(:user, role: 'admin') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:record) { create(:user) }
  let(:other_user) { create(:user) }

  permissions :index?, :create?, :approve?, :block? do
    it 'allows admin' do
      expect(subject).to permit(admin, record)
    end

    it 'denies non-admin' do
      expect(subject).not_to permit(buyer, record)
    end
  end

  permissions :show?, :update? do
    it 'allows admin or self' do
      expect(subject).to permit(admin, record)
      expect(subject).to permit(record, record)
    end

    it 'denies others' do
      expect(subject).not_to permit(buyer, record)
    end
  end

  permissions :destroy? do
    it 'allows admin if not self' do
      expect(subject).to permit(admin, other_user)
    end

    it 'denies admin if trying to delete self' do
      expect(subject).not_to permit(admin, admin)
    end
  end
end
