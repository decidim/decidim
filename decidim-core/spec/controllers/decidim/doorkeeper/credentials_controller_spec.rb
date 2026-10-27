# frozen_string_literal: true

require "spec_helper"

describe Decidim::Doorkeeper::CredentialsController do
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

      credentials = response.parsed_body

      expect(credentials.keys).to eq(%w(id email name nickname image))
      expect(credentials["id"]).to eq(user.id)
      expect(credentials["email"]).to eq(user.email)
      expect(credentials["name"]).to eq(user.name)
      expect(credentials["nickname"]).to eq(user.nickname)
      expect(credentials["image"]).to start_with("http")
    end

    context "when the token belongs to a user from another organization" do
      let(:other_user) { create(:user, :confirmed, organization: create(:organization)) }
      let!(:access_token) { create(:oauth_access_token, application:, resource_owner_id: other_user.id) }

      it "does not expose the user" do
        expect { get :me }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the token belongs to an application from another organization" do
      let(:other_application) { create(:oauth_application, organization: create(:organization)) }
      let!(:access_token) { create(:oauth_access_token, application: other_application, resource_owner_id: user.id) }

      it "does not expose the user" do
        get :me

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to be_blank
      end
    end
  end
end
