json.purchase_orders @codes do |code|
  json.brand code.brand.name
  json.created_at code.purchase_order.created_at
  json.code code.code
  json.status code.status
end