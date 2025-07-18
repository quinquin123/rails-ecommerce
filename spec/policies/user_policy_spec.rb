require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }

  let(:admin) { create(:user, role: 'admin') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:record) { create(:user) }
  let(:other_user) { create(:user) }

  describe '#index?' do
    it 'allows admin' do
      policy = UserPolicy.new(admin, record)
      expect(policy.index?).to be(true)
    end

    it 'denies non-admin' do
      policy = UserPolicy.new(buyer, record)
      expect(policy.index?).to be(false)
    end
  end

  describe '#create?' do
    it 'allows admin' do
      policy = UserPolicy.new(admin, record)
      expect(policy.create?).to be(true)
    end

    it 'denies non-admin' do
      policy = UserPolicy.new(buyer, record)
      expect(policy.create?).to be(false)
    end
  end

  describe '#approve?' do
    it 'allows admin' do
      policy = UserPolicy.new(admin, record)
      expect(policy.approve?).to be(true)
    end

    it 'denies non-admin' do
      policy = UserPolicy.new(buyer, record)
      expect(policy.approve?).to be(false)
    end
  end

  describe '#block?' do
    it 'allows admin' do
      policy = UserPolicy.new(admin, record)
      expect(policy.block?).to be(true)
    end

    it 'denies non-admin' do
      policy = UserPolicy.new(buyer, record)
      expect(policy.block?).to be(false)
    end
  end

  describe '#show?' do
    it 'allows admin or self' do
      expect(UserPolicy.new(admin, record).show?).to be(true)
      expect(UserPolicy.new(record, record).show?).to be(true)
    end

    it 'denies others' do
      expect(UserPolicy.new(buyer, record).show?).to be(false)
    end
  end

  describe '#update?' do
    it 'allows admin or self' do
      expect(UserPolicy.new(admin, record).update?).to be(true)
      expect(UserPolicy.new(record, record).update?).to be(true)
    end

    it 'denies others' do
      expect(UserPolicy.new(buyer, record).update?).to be(false)
    end
  end

  describe '#destroy?' do
    it 'allows admin if not self' do
      expect(UserPolicy.new(admin, other_user).destroy?).to be(true)
    end

    it 'denies admin if trying to delete self' do
      expect(UserPolicy.new(admin, admin).destroy?).to be(false)
    end
  end
end
