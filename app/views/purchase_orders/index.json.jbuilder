json.purchase_orders @purchase_orders.map(&:codes).flatten do |code|
  json.brand code.brand.name
  json.created_at code.purchase_order.created_at
  json.code code.code
end