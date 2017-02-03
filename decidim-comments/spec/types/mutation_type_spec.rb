# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Api
    describe MutationType do
      include_context "graphql type"

      describe "addComment" do
        let!(:feature) { create(:feature, organization: current_organization)}
        let!(:dummy_resource) { create(:dummy_resource, feature: feature) }

        let(:query) {
          "{ addComment(commentableId: \"#{dummy_resource.id}\", commentableType: \"Decidim::DummyResource\", body: \"This is a new comment\") { id, body } }"
        }

        it "should create a new comment for the given commentable" do
          expect(response["addComment"]).to include("body" => "This is a new comment")
          comment = Decidim::Comments::Comment.last
          expect(comment.commentable).to eq(dummy_resource)
          expect(response["addComment"]).to include("id" => comment.id.to_s)
        end

        context "if the query contains an argument alignment" do
          let(:query) {
            "{ addComment(commentableId: \"#{dummy_resource.id}\", commentableType: \"Decidim::DummyResource\", body: \"This is positive comment\", alignment: 1) { alignment } }"
          }

          it "should create a comment with that alignment" do
            expect(response["addComment"]).to include("alignment" => 1)
            comment = Decidim::Comments::Comment.last
            expect(comment.alignment).to eq(1)
          end
        end
      end

      describe "comment" do
        let!(:comment) { create(:comment) }
        let(:query) {
          "{ comment(id: \"#{comment.id}\") { id } }"
        }

        it "should fetch the comment given its id" do
          expect(response["comment"]).to include("id" => comment.id.to_s)
        end
      end
    end
  end
end
