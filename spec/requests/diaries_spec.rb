require 'rails_helper'

RSpec.describe "Diaries", type: :request do
  describe "GET /users/:user_id/diaries" do
    it "returns 200 ok response" do
      user = FactoryBot.create(:user)
      get user_diaries_path(user)
      expect(response).to have_http_status(:ok)
    end
  end
end
