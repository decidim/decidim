# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "NeedsPasswordChange" do
    let(:organization) { create(:organization) }
    let(:admin) { create(:user, :admin, organization:, password_updated_at: 93.days.ago) }

    controller do
      include Decidim::NeedsPasswordChange

      def current_user
        @current_user
      end

      def current_organization
        organization
      end

      def show
        render plain: "Hello world"
      end

      def change_password
        render plain: "Change password"
      end

      def accept_tos
        render plain: "Accept TOS"
      end

      def delete_account
        render plain: "Delete account"
      end

      def download_your_data
        render plain: "Download your data"
      end

      def export_download_your_data
        render plain: "Export your data"
      end
    end

    before do
      request.env["decidim.current_organization"] = organization
      allow(Decidim.config).to receive(:admin_password_strong).and_return(true)
      allow(controller).to receive(:current_user).and_return(admin)
      routes.draw do
        get "show" => "anonymous#show"
        get "change_password" => "anonymous#change_password"
        get "accept_tos" => "anonymous#accept_tos"
        get "delete_account" => "anonymous#delete_account"
        get "download_your_data" => "anonymous#download_your_data"
        get "export_download_your_data" => "anonymous#export_download_your_data"
      end
    end

    describe "#check_password_update_required" do
      context "when the request is not HTML" do
        it "does not redirect" do
          get :show, as: :json
          expect(response).to have_http_status(:ok)
        end
      end

      context "when there is no current user" do
        before do
          allow(controller).to receive(:current_user).and_return(nil)
        end

        it "does not redirect" do
          get :show
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the current user is not an admin" do
        let(:admin) { create(:user, organization:, password_updated_at: 93.days.ago) }

        it "does not redirect" do
          get :show
          expect(response).to have_http_status(:ok)
        end
      end

      context "when admin_password_strong is disabled" do
        before do
          allow(Decidim.config).to receive(:admin_password_strong).and_return(false)
        end

        it "does not redirect" do
          get :show
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the user does not need a password update" do
        let(:admin) { create(:user, :admin, organization:, password_updated_at: 1.day.ago) }

        it "does not redirect" do
          get :show
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the user needs a password update" do
        before do
          allow(admin).to receive(:needs_password_update?).and_return(true)
        end

        context "and the session authentication_method is omniauth" do
          [:enabled, :existing, :disabled].each do |users_registration_mode|
            context "when registration mode is #{users_registration_mode}" do
              let(:organization) { create(:organization, users_registration_mode:) }

              before do
                session[:authentication_method] = "omniauth"
              end

              it "does not redirect" do
                get :show
                expect(response).to have_http_status(:ok)
              end
            end
          end
        end

        context "and the session authentication_method is not omniauth" do
          before do
            session.delete(:authentication_method)
          end

          it "redirects to change password" do
            get :show
            expect(response).to redirect_to(Decidim::Core::Engine.routes.url_helpers.change_password_path)
          end

          it "sets a flash notice" do
            get :show
            expect(flash[:secondary]).to be_present
          end
        end

        context "when the path is the change_password path" do
          before do
            allow(controller).to receive(:password_update_permitted_path?).with("/change_password").and_return(true)
          end

          it "does not redirect" do
            get :change_password
            expect(response).to have_http_status(:ok)
          end
        end

        context "when the path is the accept_tos path" do
          before do
            allow(controller).to receive(:password_update_permitted_path?).with("/accept_tos").and_return(true)
          end

          it "does not redirect" do
            get :accept_tos
            expect(response).to have_http_status(:ok)
          end
        end

        context "when the path is the delete_account path" do
          before do
            allow(controller).to receive(:password_update_permitted_path?).with("/delete_account").and_return(true)
          end

          it "does not redirect" do
            get :delete_account
            expect(response).to have_http_status(:ok)
          end
        end

        context "when the path is the download_your_data path" do
          before do
            allow(controller).to receive(:password_update_permitted_path?).with("/download_your_data").and_return(true)
          end

          it "does not redirect" do
            get :download_your_data
            expect(response).to have_http_status(:ok)
          end
        end

        context "when the path is the export_download_your_data path" do
          before do
            allow(controller).to receive(:password_update_permitted_path?).with("/export_download_your_data").and_return(true)
          end

          it "does not redirect" do
            get :export_download_your_data
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
