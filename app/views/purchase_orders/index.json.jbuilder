json.purchase_orders @purchase_orderes do |purchase_order|
  json.brand purchase_order.code.brand.name
  json.created_at purchase_order.created_at
  json.code purchase_order.code.code
end