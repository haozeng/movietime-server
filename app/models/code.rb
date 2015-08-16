class Code < ActiveRecord::Base
  belongs_to :brand
  belongs_to :purchase_order
end
