# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Verifications
    module IdDocuments
      describe AuthorizationsController do
        routes { Decidim::Verifications::IdDocuments::Engine.routes }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
        end

        describe "GET choose" do
          context "when the user is signed in" do
            before { sign_in user, scope: :user }

            it "is allowed to choose an identity document verification method" do
              get :choose
              expect(response).to have_http_status(:found)
              expect(flash[:alert]).not_to eq(I18n.t("actions.unauthorized", scope: "decidim.core"))
            end
          end

          context "when the user is not signed in" do
            it "is not allowed" do
              get :choose
              expect(response).to have_http_status(:found)
              expect(flash[:alert]).to eq(I18n.t("actions.unauthorized", scope: "decidim.core"))
            end
          end
        end
      end
    end
  end
end
