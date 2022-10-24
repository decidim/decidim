# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Session", type: :request do
  subject { response.body }

  let(:request_path) { Decidim::Core::Engine.routes.url_helpers.user_session_path }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, email: "user@example.org", password: "decidim123456789", organization:) }

  it "sets the correct SameSite flag for the cookie" do
    post(
      request_path,
      params: { user: { email: "user@example.org", password: "decidim123456789" } },
      headers: { "HOST" => organization.host }
    )

    expect(response.headers["Set-Cookie"].split("; ")).to include("SameSite=Lax")
  end
end
