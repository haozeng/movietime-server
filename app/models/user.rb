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

  def set_default_payment_profile(payment_profile)
    if payment_profile.default
      payment_profiles = self.payment_profiles.where.not(id: payment_profile.id)
      if payment_profiles.count > 0
        payment_profiles[0].set_default
      end
    end
  end

  def remove_default_payment_profile
    default_payment_profile.unset_default if default_payment_profile
  end
end