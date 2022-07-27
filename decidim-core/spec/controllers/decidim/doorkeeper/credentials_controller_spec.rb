# frozen_string_literal: true

require "spec_helper"

describe Decidim::Doorkeeper::CredentialsController, type: :controller do
  routes { Decidim::Core::Engine.routes }

  let(:user) { create(:user, :confirmed) }
  let(:organization) { user.organization }
  let(:application) { create(:oauth_application, organization:) }
  let!(:access_token) { create(:oauth_access_token, application:, resource_owner_id: user.id) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "GET me" do
    before do
      request.headers["Authorization"] = "Bearer #{access_token.token}"
      request.headers["Accept"] = "application/json"
    end

    it "returns public information about the user" do
      get :me

      credentials = JSON.parse(response.body)

      expect(credentials.keys).to eq(%w(id email name nickname image))
      expect(credentials["id"]).to eq(user.id)
      expect(credentials["email"]).to eq(user.email)
      expect(credentials["name"]).to eq(user.name)
      expect(credentials["nickname"]).to eq(user.nickname)
      expect(credentials["image"]).to start_with("http")
    end
  end
end
