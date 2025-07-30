class Cart < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  has_many :cart_items, dependent: :destroy 
  has_many :products, through: :cart_items

  def total_price
    cart_items.joins(:product).sum('products.price')
  end
  #Vì products không có relation trực tiếp đến cart do đó ta phải
  #thông qua bảng cart_items để tính sum
  #Bằng cách join 2 barg đó lại và tính sum.
end
