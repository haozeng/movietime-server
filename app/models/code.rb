class Code < ActiveRecord::Base
  belongs_to :brand
  belongs_to :purchase_order

  validates :code, uniqueness: true, allow_nil: true

  def mark_used!
    update_attributes(status: 'used')
  end

  def mark_unused!
    update_attributes(status: 'unused')
  end

  def used?
    status == 'used'
  end

  def unused?
    status == 'unused'
  end
end