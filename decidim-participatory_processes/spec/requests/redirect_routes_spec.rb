# frozen_string_literal: true

require "spec_helper"

describe "Redirect routes" do
  let(:organization) { create(:organization, available_locales: %w(en es ca), default_locale: "en") }
  let(:headers) { { "HOST" => organization.host } }

  context "when there is a participatory process" do
    it "redirects old url with missing locale" do
      get("/processes", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/processes")
    end

    it "redirects old url with locale" do
      get("/processes?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/processes")
    end

    it "redirects to default locale when the locale is invalid" do
      get("/processes?locale=esp", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/en/processes")
    end

    it "redirects old url with locale and additional params" do
      get("/processes/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/processes/foo-bar")
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/processes", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/processes")
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/processes?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/processes")
    end
  end

  context "when there is a participatory process group" do
    it "redirects old url with locale and additional params" do
      get("/participatory_process_groups/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/processes_groups/foo-bar")
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/participatory_process_groups/foo-bar", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/ca/processes_groups/foo-bar")
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user

      get("/", headers:)
      get("/participatory_process_groups/foo-bar?locale=es", headers:)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/es/processes_groups/foo-bar")
    end
  end
end
