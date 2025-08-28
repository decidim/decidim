# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe SuggestionsController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:collaborative_text_component) }
      let(:document) { build(:collaborative_text_document, :published, component:) }
      let!(:first_version) { create(:collaborative_text_version, document:) }
      let!(:second_version) { create(:collaborative_text_version, document:) }
      let!(:old_suggestion) { create(:collaborative_text_suggestion, document_version: first_version) }
      let!(:suggestion1) { create(:collaborative_text_suggestion, document_version: document.current_version) }
      let!(:suggestion2) { create(:collaborative_text_suggestion, document_version: document.current_version) }

      let(:params) do
        {
          component_id: component.id,
          document_id: document.id
        }
      end

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        request.headers["X-Requested-With"] = "XMLHttpRequest"
      end

      describe "GET #index" do
        it "returns a success response" do
          get :index, params: params
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body.first.keys).to contain_exactly("changeset", "createdAt", "id", "profileHtml", "status", "summary", "type")
          expect(body.pluck("id")).to contain_exactly(suggestion1.id, suggestion2.id)
          expect(body.first["changeset"].keys).to contain_exactly("replace", "original", "firstNode", "lastNode")
          expect(body.first["summary"]).to include("Replace:")
          expect(body.first["profileHtml"]).to include(suggestion1.author.name)
          expect(body.first["status"]).to eq(suggestion1.status)
          expect(body.first["type"]).to eq("replace")
          expect(body.first["createdAt"]).to be_present
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            component_id: component.id,
            document_id: document.id,
            changeset: {
              firstNode: first_node,
              lastNode: "2",
              original: ["Original text"],
              replace: ["Replaced text"]
            }
          }
        end
        let(:first_node) { "1" }

        it "returns an error when user is not signed in" do
          post :create, params: params
          expect(response).to have_http_status(:unprocessable_entity)
          body = JSON.parse(response.body)
          expect(body["message"]).to eq("You are not authorized to perform this action.")
        end

        context "when user is signed in" do
          before do
            sign_in user
          end

          it "creates a new suggestion" do
            expect do
              post :create, params: params
            end.to change(Suggestion, :count).by(1)
            expect(response).to have_http_status(:ok)
            body = JSON.parse(response.body)
            expect(body["message"]).to eq("Suggestion successfully created.")
          end

          context "when params are invalid" do
            let(:first_node) { "" }

            it "returns an error" do
              post :create, params: params
              expect(response).to have_http_status(:unprocessable_entity)
              body = JSON.parse(response.body)
              expect(body["message"]).to eq("There was a problem creating the suggestion. Invalid selected nodes.")
            end
          end
        end
      end
    end
  end
end
