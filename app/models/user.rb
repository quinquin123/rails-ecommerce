class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { buyer: 'buyer', seller: 'seller', admin: 'admin' }
  enum status: { active: 'active', blocked: 'blocked', pending_approval: 'pending_approval', inactive: 'inactive' }

  validate :custom_email_validation

  has_one :cart, foreign_key: :buyer_id, dependent: :destroy

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= 'buyer'
    self.status ||= 'active'
  end

  def custom_email_validation
    errors.add(:email, "phải thuộc domain @gmail.com") unless email.end_with?("@gmail.com")
  end
end
