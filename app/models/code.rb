class Code < ActiveRecord::Base
  belongs_to :brand
  belongs_to :purchase_order

  validates :code, uniqueness: true, allow_nil: true
end