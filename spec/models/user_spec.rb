require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

    it {
    should define_enum_for(:role)
        .with_values(buyer: 'buyer', seller: 'seller', admin: 'admin')
        .backed_by_column_of_type(:string)
    }

    it {
    should define_enum_for(:status)
        .with_values(active: 'active', blocked: 'blocked', pending_approval: 'pending_approval', inactive: 'inactive')
        .backed_by_column_of_type(:string)
    }


  it { should have_one(:cart).dependent(:destroy) }

  it 'is invalid if email not ends with @gmail.com' do
    subject.email = 'user@example.com'
    expect(subject).to be_invalid
    expect(subject.errors[:email]).to include('phải thuộc domain @gmail.com')
  end
end
