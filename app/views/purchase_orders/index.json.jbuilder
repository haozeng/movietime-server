json.purchase_orders @tickets do |ticket|
  json.ticket_id ticket.id
  json.brand ticket.brand.name
  json.created_at ticket.purchase_order.created_at
  json.code ticket.code
  json.status ticket.status
end