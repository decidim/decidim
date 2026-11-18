# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe SuggestionVotesController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:collaborative_text_component) }
      let(:document) { create(:collaborative_text_document, :published, component:, body: "<p>Body</p>") }
      let!(:suggestion) { create(:collaborative_text_suggestion, document_version: document.current_version) }
      let(:params) { { component_id: component.id, document_id: document.id, suggestion_id: suggestion.id, weight: 1 } }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        request.headers["X-Requested-With"] = "XMLHttpRequest"
      end

      it "requires the user to be signed in" do
        post(:create, params:)

        expect(response).to have_http_status(:unauthorized)
      end

      context "when the user is signed in" do
        before { sign_in user }

        it "creates an upvote" do
          post(:create, params:)

          expect(response).to have_http_status(:ok)
          expect(suggestion.reload).to be_up_voted_by(user)
          expect(response.parsed_body).to include("upVotesCount" => 1, "downVotesCount" => 0, "voteWeight" => 1)
        end

        it "creates a downvote" do
          post(:create, params: params.merge(weight: -1))

          expect(suggestion.reload).to be_down_voted_by(user)
          expect(response.parsed_body).to include("upVotesCount" => 0, "downVotesCount" => 1, "voteWeight" => -1)
        end

        it "removes the vote when voting the same option again" do
          post(:create, params:)
          post(:create, params:)

          expect(suggestion.reload).not_to be_up_voted_by(user)
          expect(response.parsed_body).to include("upVotesCount" => 0, "downVotesCount" => 0, "voteWeight" => 0)
        end

        it "returns an error when the weight is invalid" do
          post(:create, params: params.merge(weight: 0))

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body["message"]).to include("There was a problem registering your vote")
        end

        context "when the suggestion belongs to another document" do
          let(:other_document) { create(:collaborative_text_document, :published, component:) }

          it "does not create a vote" do
            expect do
              post(:create, params: params.merge(document_id: other_document.id))
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when the document belongs to another organization" do
          let(:other_component) { create(:collaborative_text_component) }
          let(:other_document) { create(:collaborative_text_document, :published, component: other_component, body: "<p>Body</p>") }
          let(:other_suggestion) { create(:collaborative_text_suggestion, document_version: other_document.current_version) }

          it "does not create a vote" do
            expect do
              post(:create, params: params.merge(document_id: other_document.id, suggestion_id: other_suggestion.id))
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
