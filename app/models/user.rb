class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :purchase_orders
  has_many :payment_profiles

  def default_payment_profile
    payment_profiles.where(default: true).first    
  end

  def purchase_order_ids
    purchase_orders.pluck(:id)
  end

  def unset_default_payment_profile
    default_payment_profile.unset_default if default_payment_profile
    true
  end

  def set_default_payment_profile(payment_profile)
    payment_profile.set_default
  end
end