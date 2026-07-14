# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::Admin
  describe VerificationsController do
    routes { Decidim::Verifications::Engine.routes }

    let(:organization) { create(:organization, available_authorizations: [authorization_name]) }
    let(:authorization_name) { "dummy_authorization_handler" }
    let(:admin) { create(:user, :admin, :confirmed, organization:) }

    let!(:regular_authorization) { create(:authorization, name: authorization_name, user: create(:user, :confirmed, organization:)) }
    let!(:managed_authorization) { create(:authorization, name: authorization_name, user: create(:user, :confirmed, :managed, organization:)) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in admin, scope: :user
    end

    describe "GET #count" do
      it "returns the count of granted authorizations matching the filters" do
        get :count, params: { name: authorization_name }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq("count" => 2)
      end

      it "returns the count filtered to impersonated authorizations only" do
        get :count, params: { name: authorization_name, impersonated_only: true }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq("count" => 1)
      end

      it "does not count authorizations belonging to another organization" do
        other_organization = create(:organization, available_authorizations: [authorization_name])
        create(:authorization, name: authorization_name, user: create(:user, :confirmed, organization: other_organization))

        get :count, params: { name: authorization_name }

        expect(response.parsed_body).to eq("count" => 2)
      end

      context "when the name is invalid" do
        it "renders an error with unprocessable_content status" do
          get :count, params: { name: "unknown_handler" }

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body).to eq("error" => "invalid")
        end
      end

      context "when the current user is not an admin" do
        let(:regular_user) { create(:user, :confirmed, organization:) }

        before do
          sign_in regular_user, scope: :user
        end

        it "redirects the user" do
          get :count, params: { name: authorization_name }

          expect(response).to have_http_status(:redirect)
        end
      end

      context "with a before_date filter" do
        let!(:regular_authorization) { create(:authorization, name: authorization_name, user: create(:user, :confirmed, organization:), created_at: Date.new(2020, 1, 1)) }
        let!(:managed_authorization) { create(:authorization, name: authorization_name, user: create(:user, :confirmed, :managed, organization:), created_at: Date.new(2024, 6, 1)) }

        it "returns the count of granted authorizations created before the given date" do
          get :count, params: { name: authorization_name, before_date: "15/03/2022" }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq("count" => 1)
        end
      end
    end

    describe "DELETE #destroy" do
      context "when the name is invalid" do
        it "sets a flash alert and redirects" do
          delete :destroy, params: { name: "unknown_handler" }

          expect(flash[:alert]).to eq(I18n.t("decidim.admin.menu.authorization_revocation.destroy_nok"))
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
