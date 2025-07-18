require 'rails_helper'

RSpec.describe ProductPolicy do
    subject { described_class }

    let(:product) { create(:product) }

    let(:admin) { create(:user, :admin) }
    let(:seller) { create(:user, :seller) }
    let(:buyer) { nil }
    let(:seller_product) { create(:product, seller: seller) }

    describe '#index?' do
        it 'allows everyone' do
            expect(subject.new(buyer, product).index?).to be true
            expect(subject.new(admin, product).index?).to be true
            expect(subject.new(seller, product).index?).to be true
        end
    end
    describe '#show?' do
        context 'for active product' do
            it 'allows all users' do
                product.update(status: 'active')
                expect(subject.new(buyer, product).show?).to be true
            end
        end

        context 'for seller viewing own product' do
            it 'allows access' do
                expect(subject.new(seller, seller_product).show?).to be true
            end
        end

        context 'for admin' do
            it 'allows access' do
                expect(subject.new(admin, product).show?).to be true
            end
        end

        context 'unauthorized seller' do
            it 'denies access to inactive product' do
                product.update(status: 'moderated')
                expect(subject.new(seller, product).show?).to be false
            end
        end
    end
    describe '#create?' do
        it 'allows admin and seller' do
            expect(subject.new(admin, product).create?).to be true
            expect(subject.new(seller, product).create?).to be true
            expect(subject.new(buyer, product).create?).to be false
        end
    end

    describe '#update?' do
        it 'allows admin and owner seller' do
            expect(subject.new(admin, product).update?).to be true
            expect(subject.new(seller, seller_product).update?).to be true
            expect(subject.new(seller, product).update?).to be false
        end
    end

    describe '#destroy?' do
        it 'same logic as update' do
            expect(subject.new(admin, product).destroy?).to be true
            expect(subject.new(seller, seller_product).destroy?).to be true
            expect(subject.new(seller, product).destroy?).to be false
        end
    end

    describe '#moderate?' do
        it 'only allows admin' do
            expect(subject.new(admin, product).moderate?).to be true
            expect(subject.new(seller, product).moderate?).to be false
        end
    end
    describe 'Scope' do
        let!(:active_product) { create(:product, status: 'active') }
        let!(:seller_owned_product) { create(:product, status: 'moderated', seller: seller) }

        subject { ProductPolicy::Scope.new(current_user, Product).resolve }

        context 'buyer user' do
            let(:current_user) { nil }

            it 'returns only active products' do
                scope_result = ProductPolicy::Scope.new(current_user, Product).resolve
                
                puts Product.all.pluck(:status)
                puts scope_result.inspect

                expect(ProductPolicy::Scope.new(nil, Product).resolve).to eq(Product.active)
                
            end
        end

        context 'admin user' do
            let(:current_user) { admin }

            it 'returns all products' do
                expect(subject).to include(active_product, seller_owned_product)
            end
        end

        context 'seller user' do
            let(:current_user) { seller }

            it 'returns seller\'s products only' do
                expect(subject).to match_array([seller_owned_product])
            end
        end
    end

end
