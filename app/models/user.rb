class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :purchase_orders
  has_many :payment_profiles

  def purchase_order_ids
    purchase_orders.pluck(:id)
  end
end