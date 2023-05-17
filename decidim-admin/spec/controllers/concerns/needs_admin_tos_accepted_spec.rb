# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe "NeedsAdminTosAccepted", type: :controller do
      let!(:organization) { create :organization }

      controller do
        include NeedsAdminTosAccepted

        def root
          render plain: "Root page"
        end

        def admin_tos
          render plain: "Admin TOS page"
        end

        def another
          render plain: "Another page"
        end

        private

        def permitted_paths
          ["/root", "/admin_tos"]
        end

        def admin_tos_path
          "/admin_tos"
        end
      end

      before do
        routes.draw do
          get "root" => "anonymous#root"
          get "another" => "anonymous#another"
          get "admin_tos" => "anonymous#admin_tos"
        end

        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      context "when the user has not accepted the TOS" do
        let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: nil, organization:) }

        it "allows entering the root page" do
          get :root

          expect(response.body).to have_text("Root page")
        end

        it "allows entering the TOS page" do
          get :admin_tos

          expect(response.body).to have_text("Admin TOS page")
        end

        it "does not allow entering another page" do
          get :another

          expect(response).to redirect_to("/admin_tos")
          expect(response.body).to have_text("You are being redirected")
          expect(session[:user_return_to]).to eq("/another")
        end
      end

      context "when the user has accepted the TOS" do
        let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: Time.zone.now, organization:) }

        it "allows entering the root page" do
          get :root

          expect(response.body).to have_text("Root page")
        end

        it "allows entering the TOS page" do
          get :admin_tos

          expect(response.body).to have_text("Admin TOS page")
        end

        it "allows entering another page" do
          get :another

          expect(response.body).to have_text("Another page")
        end
      end
    end
  end
end
