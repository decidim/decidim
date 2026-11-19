# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Verifications
    module IdDocuments
      describe AuthorizationsController do
        routes { Decidim::Verifications::IdDocuments::Engine.routes }

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
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

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
