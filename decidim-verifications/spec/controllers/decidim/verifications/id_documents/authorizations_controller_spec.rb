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

        context "when the explanation text contains HTML" do
          render_views

          let(:payload) { %(<img src=x onerror="alert(document.domain)">) }
          let(:organization) do
            create(
              :organization,
              available_authorizations: ["id_documents"],
              id_documents_methods: ["offline"],
              id_documents_explanation_text: { en: payload }
            )
          end

          before { sign_in user, scope: :user }

          describe "GET new" do
            it "does not render the stored explanation as raw HTML" do
              get :new, params: { using: "offline" }

              expect(response).to have_http_status(:ok)
              expect(response.body).not_to include(payload)
              expect(response.body).not_to include("onerror")
            end

            context "with allowed formatting" do
              let(:payload) { "<p>Hello <strong>world</strong></p>" }

              it "keeps the allowed markup" do
                get :new, params: { using: "offline" }

                expect(response).to have_http_status(:ok)
                expect(response.body).to include("<strong>world</strong>")
              end
            end
          end

          describe "GET edit" do
            let!(:authorization) { create(:authorization, :pending, user:, name: "id_documents") }

            it "does not render the stored explanation as raw HTML" do
              get :edit

              expect(response).to have_http_status(:ok)
              expect(response.body).not_to include(payload)
              expect(response.body).not_to include("onerror")
            end
          end
        end
      end
    end
  end
end
