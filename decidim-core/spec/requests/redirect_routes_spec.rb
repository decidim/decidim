# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let(:headers) { { "HOST" => organization.host } }

  it "redirects old url with missing locale" do
    get("/pages", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/pages")
  end

  it "redirects old url with locale" do
    get("/pages?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/pages")
  end

  it "redirects to default locale when the locale is invalid" do
    get("/pages?locale=esp", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/pages")
  end

  it "redirects old url with locale and additional params" do
    get("/pages/foo-bar?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/pages/foo-bar")
  end

  it "redirects user to the new url" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/pages", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/ca/pages")
  end

  it "redirects user to the new url when using custom locale" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/pages?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/pages")
  end
end
