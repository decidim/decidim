# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe "NeedsAdminTosAccepted" do
      let!(:organization) { create(:organization) }

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

      shared_examples "needs admins' TOS acceptance to access other pages" do
        it "allows accessing the root page" do
          get :root

          expect(response.body).to have_text("Root page")
        end

        it "allows accessing the TOS page" do
          get :admin_tos

          expect(response.body).to have_text("Admin TOS page")
        end

        it "does not allow accessing another page" do
          get :another

          expect(response).to redirect_to("/admin_tos")
          expect(session[:user_return_to]).to eq("/another")
        end
      end

      shared_examples "allows accessing all the pages" do
        it "allows accessing the root page" do
          get :root

          expect(response.body).to have_text("Root page")
        end

        it "allows accessing the TOS page" do
          get :admin_tos

          expect(response.body).to have_text("Admin TOS page")
        end

        it "allows accessing another page" do
          get :another

          expect(response.body).to have_text("Another page")
        end
      end

      context "when the user is an admin" do
        context "and has not accepted the TOS" do
          let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: nil, organization:) }

          it_behaves_like "needs admins' TOS acceptance to access other pages"
        end

        context "and has accepted the TOS" do
          let(:user) { create(:user, :admin, :confirmed) }

          it_behaves_like "allows accessing all the pages"
        end
      end

      context "when the user has another role with access to admin panel" do
        let(:participatory_process) { create(:participatory_process, organization:) }

        context "and has not accepted the TOS" do
          let(:user) { create(:process_moderator, confirmed_at: Time.current, admin_terms_accepted_at: nil, participatory_process:) }

          it_behaves_like "needs admins' TOS acceptance to access other pages"
        end

        context "and has accepted the TOS" do
          let(:user) { create(:process_moderator, confirmed_at: Time.current, participatory_process:) }

          it_behaves_like "allows accessing all the pages"
        end
      end
    end
  end
end
