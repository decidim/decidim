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

  context "when checking the search page" do
    it "redirects old url with missing locale" do
      get("/search", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/search")
    end

    it "redirects old url with query string with missing locale" do
      page_with_query_string = "/search?filter[term]=&filter[with_resource_type]=Decidim::Comments::Comment&filter[with_scope]&per_page=50"
      get(page_with_query_string, headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en#{page_with_query_string}")
    end

    it "redirects old url with locale" do
      get("/search?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/search")
    end

    it "redirects to default locale when the locale is invalid" do
      get("/search?locale=esp", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/search")
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/search", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/search")
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/search?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/search")
    end
  end

  context "when checking the badges page" do
    it "redirects old url with missing locale" do
      get("/gamification/badges", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/gamification/badges")
    end

    it "redirects old url with locale" do
      get("/gamification/badges?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/gamification/badges")
    end

    it "redirects to default locale when the locale is invalid" do
      get("/gamification/badges?locale=esp", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/gamification/badges")
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/gamification/badges", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/gamification/badges")
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/gamification/badges?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/gamification/badges")
    end
  end
end
