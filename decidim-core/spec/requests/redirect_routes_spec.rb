# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let(:headers) { { "HOST" => organization.host } }

  shared_examples "redirects to the new url" do |url|
    it "redirects old url (/#{url}) with missing locale to new version (/en/#{url})" do
      get("/#{url}", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/#{url}")
    end

    it "redirects old url (/#{url}?locale=es) with locale to new version (/es/#{url})" do
      get("/#{url}?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/#{url}")
    end

    it "redirects to default locale (/en/#{url}) when the locale is invalid (/#{url}?locale=esp)" do
      get("/#{url}?locale=esp", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/#{url}")
    end

    it "redirects user to the new url (/ca/#{url})" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/#{url}", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/#{url}")
    end

    it "redirects user to the new url (/es/#{url}) when using custom locale (/#{url}?locale=es)" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/#{url}?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/#{url}")
    end
  end

  it_behaves_like "redirects to the new url", "pages" do
    it "redirects old url with locale and additional params" do
      get("/pages/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/pages/foo-bar")
    end
  end

  context "when visiting profile pages" do
    let!(:user) { create(:user, :confirmed, nickname: "my_user", organization:) }

    it_behaves_like "redirects to the new url", "profiles/my_user/activity" do
      it "redirects old url with query string with missing locale" do
        page_with_query_string = "/profiles/my_user/activity?filter[resource_type]=Decidim::Comments::Comment&page=2&per_page=50"
        get(page_with_query_string, headers:)
        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to("/en#{page_with_query_string}")
      end
    end

    it_behaves_like "redirects to the new url", "profiles/my_user/badges"
    it_behaves_like "redirects to the new url", "profiles/my_user/following"
    it_behaves_like "redirects to the new url", "profiles/my_user/followers"
  end
end
