# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let(:headers) { { "HOST" => organization.host } }

  it "redirects old url with missing locale" do
    get("/assemblies", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/assemblies")
  end

  it "redirects old url with locale" do
    get("/assemblies?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/assemblies")
  end

  it "redirects to default locale when the locale is invalid" do
    get("/assemblies?locale=esp", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/assemblies")
  end

  it "redirects old url with locale and additional params" do
    get("/assemblies/foo-bar?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/assemblies/foo-bar")
  end

  it "redirects old url with query string" do
    get("/assemblies/laser-doctor?share_token=FOOBAR", headers:)

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/assemblies/laser-doctor?share_token=FOOBAR")
  end

  it "redirects user to the new url" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/assemblies", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/ca/assemblies")
  end

  it "redirects user to the new url when using custom locale" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/assemblies?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/assemblies")
  end
end
