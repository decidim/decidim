# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let(:headers) { { "HOST" => organization.host } }

  it "redirects root to the locale home" do
    get("/", headers:)
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/en/")
  end

  shared_examples "redirects to the new url" do |url|
    it "redirects old url (/#{url}) with missing locale to new version (/en/#{url})" do
      get("/#{url}", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/#{url}")
      expect(response.location).not_to include("locale=")
    end

    it "redirects old url (/#{url}?locale=es) with locale to new version (/es/#{url})" do
      get("/#{url}?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/#{url}")
      expect(response.location).not_to include("locale=")
    end

    it "redirects to default locale (/en/#{url}) when the locale is invalid (/#{url}?locale=esp)" do
      get("/#{url}?locale=esp", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/#{url}")
      expect(response.location).not_to include("locale=")
    end

    it "redirects user to the new url (/ca/#{url})" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/#{url}", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/#{url}")
      expect(response.location).not_to include("locale=")
    end

    it "redirects user to the new url (/es/#{url}) when using custom locale (/#{url}?locale=es)" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/#{url}?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/#{url}")
      expect(response.location).not_to include("locale=")
    end
  end

  it_behaves_like "redirects to the new url", "pages" do
    it "redirects old url with locale and additional params" do
      get("/pages/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/pages/foo-bar")
    end

    it "redirects old url with query string" do
      get("/pages/foo-bar?share_token=FOOBAR", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/pages/foo-bar?share_token=FOOBAR")
    end
  end

  context "when visiting admin pages" do
    it "redirects /admin to the locale-aware admin root" do
      get("/admin", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/admin")
      expect(response.location).not_to include("locale=")
    end

    it "redirects /admin with a path to the locale-aware admin path" do
      get("/admin/users", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/admin/users")
      expect(response.location).not_to include("locale=")
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

  context "when visiting download your data pages" do
    let(:user) { create(:user, :confirmed, organization:, locale: "ca") }
    let(:private_export) { create(:private_export, attached_to: user, organization:) }

    before do
      login_as user, scope: :user
    end

    it "redirects old url (/download_your_data) with missing locale to user locale (/ca/download_your_data)" do
      get("/download_your_data", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/download_your_data")
      expect(response.location).not_to include("locale=")
    end

    it "redirects old url (/download_your_data?locale=es) with locale to new version (/es/download_your_data)" do
      get("/download_your_data?locale=es", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/download_your_data")
      expect(response.location).not_to include("locale=")
    end

    it "redirects to default locale (/en/download_your_data) when the locale is invalid" do
      get("/download_your_data?locale=esp", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/download_your_data")
      expect(response.location).not_to include("locale=")
    end

    it "redirects old url (/download_your_data/:uuid) with missing locale to new version (/ca/download_your_data/:uuid)" do
      get("/download_your_data/#{private_export.uuid}", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/download_your_data/#{private_export.uuid}")
      expect(response.location).not_to include("locale=")
    end

    it "redirects old url (/download_your_data/:uuid?locale=es) with locale to new version (/es/download_your_data/:uuid)" do
      get("/download_your_data/#{private_export.uuid}?locale=es", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/download_your_data/#{private_export.uuid}")
      expect(response.location).not_to include("locale=")
    end

    it "redirects to default locale when uuid download url locale is invalid" do
      get("/download_your_data/#{private_export.uuid}?locale=esp", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/download_your_data/#{private_export.uuid}")
      expect(response.location).not_to include("locale=")
    end
  end

  context "when visiting conversations pages" do
    it "redirects the conversations index" do
      get("/conversations", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/conversations")
    end

    it "redirects conversations with a path" do
      get("/conversations/123", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/conversations/123")
    end

    it "redirects conversations with query string" do
      get("/conversations?share_token=faketoken", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/conversations?share_token=faketoken")
    end
  end

  context "when visiting notifications settings" do
    it "redirects notifications settings" do
      get("/notifications_settings", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/notifications_settings")
    end

    it "redirects notifications settings with query string" do
      get("/notifications_settings?share_token=faketoken", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/notifications_settings?share_token=faketoken")
    end
  end

  context "when visiting account pages" do
    it "redirects account delete to the locale-aware path" do
      user = create(:user, :confirmed, organization:)
      login_as user, scope: :user

      get("/", headers:)
      get("/account/delete", headers:)

      expect(response).to redirect_to("/en/account/delete")
    end
  end

  context "when visiting legacy devise pages" do
    it "redirects password reset pages with missing locale" do
      get("/users/password/edit?reset_password_token=faketoken", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/password/edit?reset_password_token=faketoken")
    end

    it "redirects invitation accept pages with query string" do
      get("/users/invitation/accept?invitation_token=faketoken&invite_redirect=%2Fen%2Fadmin%2F", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/invitation/accept?invitation_token=faketoken&invite_redirect=%2Fen%2Fadmin%2F")
    end

    it "redirects the sign in page" do
      get("/users/sign_in", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/sign_in")
    end

    it "redirects the sign up page" do
      get("/users/sign_up", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/sign_up")
    end

    it "redirects the password reset request page" do
      get("/users/password/new", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/password/new")
    end

    it "redirects the confirmation request page" do
      get("/users/confirmation/new", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/confirmation/new")
    end

    it "redirects the confirmation page" do
      get("/users/confirmation", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/confirmation")
    end

    it "redirects the unlock request page" do
      get("/users/unlock/new", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/unlock/new")
    end

    it "redirects the unlock page" do
      get("/users/unlock", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/unlock")
    end

    it "redirects the invitation request page" do
      get("/users/invitation/new", headers:)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/users/invitation/new")
    end
  end
end
