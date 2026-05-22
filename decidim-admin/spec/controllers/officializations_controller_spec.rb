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

      describe "show_email" do
        context "when user is not found" do
          it "sets a not found message" do
            get :show_email, params: { user_id: 999_999_999 }

            expect(response.body).to have_content("No user found")
          end
        end

        context "when user is found" do
          let!(:user) { create(:user, :confirmed, organization:) }

          it "renders show_email template" do
            get :show_email, params: { user_id: user.id }
            expect(subject).to render_template(:show_email)
            expect(response.body).to have_content(user.email)
          end
        end
      end
    end
  end
end
