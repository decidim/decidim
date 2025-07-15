# frozen_string_literal: true

require "spec_helper"
require "devise/jwt/test_helpers"

describe Decidim::Api::SessionsController do
  routes { Decidim::Api::Engine.routes }

  let(:organization) { create(:organization) }
  let(:api_key) { "user_key" }
  let(:api_secret) { "decidim123456789" }
  let!(:user) { create(:api_user, organization: organization, api_key: api_key, api_secret: api_secret) }
  let(:params) do
    {
      api_user: {
        key: api_key,
        secret: api_secret
      }
    }
  end
  let(:invalid_params) do
    {
      api_user: {
        key: api_key,
        secret: "incorrect_secret"
      }
    }
  end

  before do
    request.env["devise.mapping"] = Devise.mappings[:api_user]
    request.env[Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY] = "warden-jwt_auth.token_dispatcher"
    request.env["decidim.current_organization"] = organization
  end

  describe "sign in" do
    it "returns JWT token when credentials are valid" do
      expect(request.env[Warden::JWTAuth::Hooks::PREPARED_TOKEN_ENV_KEY]).not_to be_present
      post :create, params: params
      expect(response).to have_http_status(:ok)
      token = request.env[Warden::JWTAuth::Hooks::PREPARED_TOKEN_ENV_KEY]
      expect(token).to be_present
      parsed_response_body = JSON.parse(response.body)
      expect(parsed_response_body["jwt_token"]).to eq(token)
    end

    it "returns :forbidden when credentials are invalid" do
      post :create, params: invalid_params

      expect(response).to have_http_status(:forbidden)
      expect(request.env[Warden::JWTAuth::Hooks::PREPARED_TOKEN_ENV_KEY]).not_to be_present
    end

    it "renders resource without JWT token in body when `Tokendispatcher::ENV_KEY` is nil" do
      request.env[Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY] = nil
      post :create, params: params
      expect(request.env[Warden::JWTAuth::Hooks::PREPARED_TOKEN_ENV_KEY]).to be_present
      parsed_response_body = JSON.parse(response.body)
      expect(parsed_response_body.has_key?("jwt_token")).to be(false)
    end
  end
end
