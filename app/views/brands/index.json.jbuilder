json.brands @brands do |brand|
  json.id brand.id
  json.name brand.name
  json.price brand.price
  json.original_price brand.original_price
  json.description brand.description
  json.title brand.title
end