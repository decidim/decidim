# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let(:headers) { { "HOST" => organization.host } }

  it "redirects old url with missing locale" do
    get("/conferences", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/conferences")
  end

  it "redirects old url with locale" do
    get("/conferences?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/conferences")
  end

  it "redirects to default locale when the locale is invalid" do
    get("/conferences?locale=esp", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/conferences")
  end

  it "redirects old url with locale and additional params" do
    get("/conferences/foo-bar?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/conferences/foo-bar")
  end

  it "redirects old url with query string" do
    get("/conferences/foo-bar?share_token=FOOBAR", headers:)

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/conferences/foo-bar?share_token=FOOBAR")
  end

  it "redirects user to the new url" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/conferences", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/ca/conferences")
  end

  it "redirects user to the new url when using custom locale" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/conferences?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/conferences")
  end
end
