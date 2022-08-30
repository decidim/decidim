# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ErrorsController, type: :controller do
    let!(:organization) { create :organization }

    controller Decidim::ErrorsController do
      def auth_token
        render plain: "Error", status: :internal_server_error
      end

      def cors
        render js: "console.log('CORS');", status: :internal_server_error
      end
    end

    before do
      request.env["decidim.current_organization"] = organization
      routes.draw do
        get "not_found" => "decidim/errors#not_found"
        get "internal_server_error" => "decidim/errors#internal_server_error"
        post "internal_server_error" => "decidim/errors#internal_server_error"
        post "auth_token" => "decidim/errors#auth_token"
        post "cors" => "decidim/errors#cors"
      end
    end

    describe "not_found" do
      it "reports the correct status code" do
        get :not_found
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "internal_server_error" do
      it "reports the correct status code on GET" do
        get :internal_server_error
        expect(response).to have_http_status(:internal_server_error)
      end

      it "reports the correct status code on POST" do
        post :internal_server_error
        expect(response).to have_http_status(:internal_server_error)
      end

      context "with request forgery protection" do
        before do
          described_class.allow_forgery_protection = true
        end

        after do
          described_class.allow_forgery_protection = false
        end

        context "with invalid authenticity token" do
          it "reports the correct status code on POST and renders" do
            post :auth_token
            expect(response).to have_http_status(:internal_server_error)
            expect(response.body).to eq("Error")
          end
        end

        context "with invalid request origin" do
          it "reports the correct status code on POST and renders" do
            # This would make the CORS requests always fail regardless of the
            # passed `Origin` header in case the :verify_same_origin_request
            # after action is applied.
            controller.send(:mark_for_same_origin_verification!)

            post :cors
            expect(response).to have_http_status(:internal_server_error)
            expect(response.body).to eq("console.log('CORS');")
          end
        end
      end

      context "when the user is signed in but has not agreed to terms of service" do
        let(:user) { create(:user, :confirmed, accepted_tos_version: nil) }

        before do
          routes { Decidim::Core::Engine.routes }

          request.env["devise.mapping"] = ::Devise.mappings[:user]

          sign_in user
        end

        it "displays the error page without a redirection to the terms page" do
          get :internal_server_error

          expect(response).to have_http_status(:internal_server_error)
        end
      end
    end
  end
end
