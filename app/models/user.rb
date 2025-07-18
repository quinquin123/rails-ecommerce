class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { buyer: 'buyer', seller: 'seller', admin: 'admin' }
  enum status: { active: 'active', blocked: 'blocked', pending_approval: 'pending_approval', inactive: 'inactive' }

  has_one :cart, foreign_key: :buyer_id, dependent: :destroy
  
  validate :custom_email_validation
  validates :role, presence: true

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= 'buyer'
    self.status ||= 'active'
  end

  def custom_email_validation
    return if email.blank? 

    unless email.end_with?('@gmail.com')
      errors.add(:email, 'must belong to the domain @gmail.com')
    end
  end
end
