# frozen_string_literal: true

require "spec_helper"

describe "Doorkeeper authorizations" do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:foreign_application) { create(:oauth_application, organization: other_organization) }
  let(:redirect_uri) { "http://#{organization.host}/oauth/authorize/native" }

  before do
    login_as user, scope: :user
  end

  it "does not authorize an application from another organization" do
    get "/oauth/authorize", params: {
      client_id: foreign_application.uid,
      redirect_uri:,
      response_type: "code",
      scope: "profile"
    }, headers: { "HOST" => organization.host }

    expect(response).to have_http_status(:not_found)
  end
end
