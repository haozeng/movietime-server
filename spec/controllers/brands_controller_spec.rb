require 'rails_helper'

describe BrandsController do
  render_views

  before do
    create_list :brand, 3
  end

  context "#index" do
    it "return list of brands in json" do
      get :index, format: :json
      expect(response.status).to eql(200)
      expect(JSON.parse(response.body)['brands'].size).to eql(3)
    end
  end

  context "#show" do
    it "return one brand in json" do
      get :show, id: Brand.last.id, format: :json
      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['name']).to eql(Brand.last.name)
    end
  end
end