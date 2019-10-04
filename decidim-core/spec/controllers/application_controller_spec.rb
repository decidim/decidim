# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationController, type: :controller do
    let!(:organization) { create :organization }
    let!(:user) { create :user, :confirmed, organization: organization }
    let(:tos_path) { "/pages/terms-and-conditions" }

    controller Decidim::ApplicationController do
      def show
        render plain: "Hello World"
      end

      def tos
        render plain: "Terms"
      end
    end

    before do
      request.env["decidim.current_organization"] = organization
      routes.draw do
        get "show" => "decidim/application#show"
        get "pages/terms-and-conditions" => "decidim/application#tos"
      end
    end

    describe "redirect_url" do
      it "allows relative paths" do
        get :show, params: { redirect_url: "/my/account" }

        expect(controller.helpers.redirect_url).to eq("/my/account")
      end

      it "allows absolute URLs within the organization" do
        get :show, params: { redirect_url: "http://#{organization.host}/my/account" }

        expect(controller.helpers.redirect_url).to eq("http://#{organization.host}/my/account")
      end

      it "doesn't allow other URLs" do
        get :show, params: { redirect_url: "http://www.example.org" }

        expect(controller.helpers.redirect_url).to eq(nil)
      end
    end

    describe "#show" do
      context "when authenticated" do
        before do
          sign_in user
        end

        it "sets the appropiate headers" do
          get :show

          expect(response.headers["Cache-Control"]).to eq("no-cache, no-store")
          expect(response.headers["Pragma"]).to eq("no-cache")
          expect(response.headers["Expires"]).to eq("Fri, 01 Jan 1990 00:00:00 GMT")
        end

        context "and the user should agree to the terms of service" do
          let!(:user) { create :user, :confirmed, organization: organization, accepted_tos_version: nil }

          it "redirects the user to the terms of service page and stores the location" do
            get :show
            expect(response).to redirect_to(tos_path)
            expect(session[:user_return_to]).to eq("/show")
          end

          context "and requesting the terms of service page itself" do
            it "does not redirect the user to the terms of service page or store the location" do
              get :tos
              expect(response).not_to redirect_to(tos_path)
              expect(session[:user_return_to]).to be_nil
            end
          end

          context "and the request format is not HTML" do
            it "does not redirect the user or store the location" do
              get :show, params: { format: :json }
              expect(response).not_to redirect_to(tos_path)
              expect(session[:user_return_to]).to be_nil
            end
          end
        end
      end

      context "when not authenticated" do
        it "sets the appropiate headers" do
          get :show

          expect(response.headers["Cache-Control"]).to be_nil
          expect(response.headers["Pragma"]).to be_nil
          expect(response.headers["Expires"]).to be_nil
        end

        it "stores the terms of service page location" do
          get :tos
          expect(session[:user_return_to]).to eq(tos_path)
        end

        context "and requesting a devise controller" do
          it "does not store the location" do
            allow(controller).to receive(:devise_controller?).and_return(true)
            get :show
            expect(session[:user_return_to]).to be_nil
          end
        end

        context "and the request format is not HTML" do
          it "does not store the location" do
            get :show, params: { format: :json }
            expect(session[:user_return_to]).to be_nil
          end
        end
      end

      context "when organization force users to authenticate before access" do
        before do
          organization.force_users_to_authenticate_before_access_organization = true
          organization.save
        end

        context "when authenticated" do
          before do
            sign_in user
          end

          it "sets the appropiate headers" do
            get :show

            expect(response.headers["Cache-Control"]).to eq("no-cache, no-store")
            expect(response.headers["Pragma"]).to eq("no-cache")
            expect(response.headers["Expires"]).to eq("Fri, 01 Jan 1990 00:00:00 GMT")
          end
        end

        context "when not authenticated" do
          it "redirects to sign in path" do
            get :show
            expect(response).to redirect_to("/users/sign_in")
            expect(flash[:warning]).to include("Please, login with your account before access")
          end
        end
      end
    end
  end
end
