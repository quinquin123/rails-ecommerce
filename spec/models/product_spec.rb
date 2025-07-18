require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { should belong_to(:seller).class_name('User') }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:reviews).dependent(:destroy) }
  end
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it {
        should define_enum_for(:status)
            .with_values(active: 'active', moderated: 'moderated', deleted: 'deleted')
            .backed_by_column_of_type(:string)
    }  
  end
end