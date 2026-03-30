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

  context "when browsing pages" do
    it_behaves_like "redirects to the new url", "pages" do
      it "redirects old url with locale and additional params" do
        get("/pages/foo-bar?locale=es", headers:)
        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to("/es/pages/foo-bar")
      end
    end
  end

  context "when browsing search" do
    it_behaves_like "redirects to the new url", "search" do
      it "redirects old url with query string with missing locale" do
        page_with_query_string = "/search?filter[term]=&filter[with_resource_type]=Decidim::Comments::Comment&filter[with_scope]&per_page=50"
        get(page_with_query_string, headers:)
        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to("/en#{page_with_query_string}")
      end
    end
  end

  context "when browsing gamification" do
    it_behaves_like "redirects to the new url", "gamification/badges"
  end

  context "when browsing account" do
    let!(:user) { create(:user, :confirmed, organization:) }

    before do
      login_as user, scope: :user
    end

    it_behaves_like "redirects to the new url", "account"

    context "and account delete section" do
      it_behaves_like "redirects to the new url", "account/delete"
    end
  end

  context "when browsing last_activities" do
    it_behaves_like "redirects to the new url", "last_activities" do
      it "redirects old url with query string with missing locale" do
        page_with_query_string = "/last_activities?filter[with_resource_type]=Decidim::Comments::Comment&per_page=50"
        get(page_with_query_string, headers:)
        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to("/en#{page_with_query_string}")
      end
    end
  end
end
