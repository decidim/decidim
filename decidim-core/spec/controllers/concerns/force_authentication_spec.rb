# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "ForceAuthentication" do
    let(:organization) { create(:organization, force_users_to_authenticate_before_access_organization:) }

    controller do
      include Decidim::ForceAuthentication

      def current_organization
        request.env["decidim.current_organization"]
      end

      def show
        render plain: "Hello world"
      end

      def locale
        render plain: "Locale changed"
      end
    end

    before do
      request.env["decidim.current_organization"] = organization
      routes.draw do
        get "show" => "anonymous#show"
        get "locale" => "anonymous#locale"
      end
    end

    context "when the organization is configured to force user authentication" do
      let(:force_users_to_authenticate_before_access_organization) { true }

      it "forces authentication" do
        get :show
        expect(response.location).to eq("http://test.host/users/sign_in")
        expect(response).to have_http_status(:found)
      end

      it "allows accessing the locale page" do
        get :locale
        expect(request.path).to eq("/locale")
        expect(response.body).to have_text("Locale changed")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the organization is configured to not force user authentication" do
      let(:force_users_to_authenticate_before_access_organization) { false }

      it "shows the page" do
        get :show
        expect(request.path).to eq("/show")
        expect(response.body).to have_text("Hello world")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when there is no organization" do
      let(:organization) { nil }

      it "shows the page" do
        get :show
        expect(request.path).to eq("/show")
        expect(response.body).to have_text("Hello world")
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
