class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { buyer: 'buyer', seller: 'seller', admin: 'admin' }
  enum status: { active: 'active', blocked: 'blocked', pending_approval: 'pending_approval', inactive: 'inactive' }
end
