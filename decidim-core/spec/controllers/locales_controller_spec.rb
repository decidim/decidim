# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LocalesController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "POST create" do
      let(:locale) { "ca" }

      around do |example|
        I18n.with_locale(I18n.locale) { example.run }
      end

      context "when the user is signed in" do
        let(:user) { create(:user, :confirmed, locale: "en", organization:) }

        before do
          sign_in user, scope: :user
        end

        context "when the given locale is valid" do
          it "changes the user's locale" do
            post :create, params: { locale: }
            expect(user.reload.locale).to eq("ca")
          end
        end

        context "when otherwise" do
          let(:locale) { "foo" }

          it "does not change the user's locale" do
            post :create, params: { locale: }
            expect(user.locale).to eq("en")
          end
        end
      end

      it "redirects the user using the locale URL prefix" do
        post :create, params: { locale: }
        expect(response).to redirect_to("/ca")
      end

      context "when the referrer has some query params" do
        before do
          request.env["HTTP_REFERER"] = "/search?param1=foo&param2=bar"
        end

        it "keeps the original query params too" do
          post :create, params: { locale: }
          expect(response).to redirect_to("/ca/search?param1=foo&param2=bar")
        end

        context "when the referer already include the locale" do
          before do
            request.env["HTTP_REFERER"] = "/search?param1=foo&param2=bar&locale=en-US"
          end

          it "replaces it" do
            post :create, params: { locale: }
            expect(response).to redirect_to("/ca/search?param1=foo&param2=bar")
          end
        end
      end

      context "when the referrer uses locale prefixes" do
        before do
          request.env["HTTP_REFERER"] = "/en/users/sign_in"
        end

        it "replaces the locale segment in the path" do
          post :create, params: { locale: }
          expect(response).to redirect_to("/ca/users/sign_in")
        end
      end
    end
  end
end
