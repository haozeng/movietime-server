class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :mark_used, :mark_unused], Code, :purchase_order => { :id => user.purchase_order_ids }
    can [:read, :create, :destroy], PaymentProfile, :user_id => user.id
    can [:read, :create], PurchaseOrder, :user_id => user.id
  end
end