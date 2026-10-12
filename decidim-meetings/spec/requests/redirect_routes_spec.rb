# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let(:headers) { { "HOST" => organization.host } }

  it "redirects old url with missing locale" do
    get("/meetings", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/meetings")
  end

  it "redirects old url with locale" do
    get("/meetings?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/meetings")
  end

  it "redirects to default locale when the locale is invalid" do
    get("/meetings?locale=esp", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/meetings")
  end

  it "redirects old url with query string" do
    get("/meetings?filter[title_or_description_cont]=foo&page=2", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/meetings?filter[title_or_description_cont]=foo&page=2")
  end

  it "redirects nested old urls with locale" do
    get("/meetings/calendar?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/meetings/calendar")
  end

  it "redirects nested old urls with query string" do
    get("/meetings/calendar?share_token=FOOBAR", headers:)

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/meetings/calendar?share_token=FOOBAR")
  end

  it "redirects user to the new url" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/meetings", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/ca/meetings")
  end

  it "redirects user to the new url when using custom locale" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user

    get("/", headers:)
    get("/meetings?locale=es", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/es/meetings")
  end
end
