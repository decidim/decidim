# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Devise
    describe PasswordsController do
      routes { Decidim::Core::Engine.routes }

      include Decidim::Core::Engine.routes.url_helpers

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        request.env["devise.mapping"] = ::Devise.mappings[:user]
        request.env["decidim.current_organization"] = organization
      end

      describe "GET change_password" do
        context "when the user is signed in" do
          before { sign_in user }

          it "is allowed" do
            get :change_password, params: { locale: I18n.locale }
            expect(response).to have_http_status(:ok)
          end
        end

        context "when the user is not signed in" do
          it "is not allowed" do
            get :change_password, params: { locale: I18n.locale }
            expect(response).to have_http_status(:found)
          end
        end
      end

      describe "PUT apply_password" do
        let(:params) do
          {
            locale: I18n.locale,
            user: {
              password: "new-password",
              password_confirmation: "new-password"
            }
          }
        end

        context "when the user is signed in" do
          before { sign_in user }

          it "is allowed" do
            put(:apply_password, params:)
            expect(response).to have_http_status(:found)
          end
        end

        context "when the user is not signed in" do
          it "is not allowed" do
            put(:apply_password, params:)
            expect(response).to redirect_to(new_user_session_path)
            expect(flash[:alert]).to eq("You are not authorized to perform this action.")
          end
        end
      end
    end
  end
end
