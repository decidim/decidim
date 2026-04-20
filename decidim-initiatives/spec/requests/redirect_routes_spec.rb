# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let!(:type1) { create(:initiatives_type, organization:) }
  let!(:scoped_type1) { create(:initiatives_type_scope, type: type1) }
  let(:headers) { { "HOST" => organization.host } }

  context "when requesting initiatives" do
    it "redirects old url with missing locale" do
      get("/initiatives", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/initiatives")
    end

    it "redirects old url with locale" do
      get("/initiatives?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/initiatives")
    end

    it "redirects to default locale when the locale is invalid" do
      get("/initiatives?locale=esp", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/initiatives")
    end

    it "redirects old url with locale and additional params" do
      get("/initiatives/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/initiatives/foo-bar")
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/initiatives", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/initiatives")
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/initiatives?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/initiatives")
    end
  end

  context "when requesting initiatives types" do
    it "redirects old url with locale and additional params" do
      get("/initiative_types/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/initiative_types/foo-bar")
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/initiative_types/foo-bar", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/initiative_types/foo-bar")
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/initiative_types/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/initiative_types/foo-bar")
    end
  end

  context "when requesting initiative type signature types" do
    it "redirects old url with locale and additional params" do
      get("/initiative_type_signature_types/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/initiative_type_signature_types/foo-bar")
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/initiative_type_signature_types/foo-bar", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/initiative_type_signature_types/foo-bar")
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/initiative_type_signature_types/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/initiative_type_signature_types/foo-bar")
    end
  end
end
