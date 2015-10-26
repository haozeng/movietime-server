json.purchase_orders @purchase_orders do |purchase_order|
  json.purchase_order_id purchase_order.id
  json.created_at purchase_order.created_at

  json.tickets purchase_order.tickets do |ticket|
    json.ticket_id ticket.id
    json.brand ticket.brand.name
    json.created_at ticket.purchase_order.created_at
    json.code ticket.code
    json.status ticket.status
  end
end