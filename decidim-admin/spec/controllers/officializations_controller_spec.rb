# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OfficializationsController do
      routes { Decidim::Admin::Engine.routes }
      render_views

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "new" do
        context "when user is not found" do
          it "redirects to officializations path with alert" do
            get :new, params: { user_id: 999_999_999 }

            expect(flash[:alert]).to eq(I18n.t("officializations.create.no_user_found", scope: "decidim.admin"))
            expect(response).to redirect_to(officializations_path)
          end
        end

        context "when user is found" do
          let(:user) { create(:user, :confirmed, organization:) }

          it "renders the new with form with success" do
            get :new, params: { user_id: user.id }

            expect(response).to have_http_status(:ok)
            expect(assigns(:form)).to be_a(Decidim::Admin::OfficializationForm)
            expect(assigns(:form).user).to eq(user)
          end
        end
      end

      describe "show_email" do
        render_views

        context "when user is not found" do
          it "sets a not found message" do
            get :show_email, params: { user_id: 999_999_999 }

            expect(response.body).to have_text("No user found")
          end
        end

        context "when user is found" do
          let!(:user) { create(:user, :confirmed, organization:) }

          it "renders show_email template" do
            get :show_email, params: { user_id: user.id }
            expect(subject).to render_template(:show_email)
            expect(response.body).to have_text(user.email)
          end
        end
      end
    end
  end
end
