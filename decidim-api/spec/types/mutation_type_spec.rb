# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Api
    describe MutationType do
      include TypeHelpers

      describe "addComment" do
        let!(:participatory_process) { create(:participatory_process, organization: current_organization) }

        let(:query) { 
          "{ addComment(commentableId: \"#{participatory_process.id}\", commentableType: \"Decidim::ParticipatoryProcess\", body: \"This is a new comment\") { id, body } }" 
        }

        it "should create a new comment for the given commentable" do
          expect(response["addComment"]).to include("body" => "This is a new comment")
          comment = Decidim::Comments::Comment.last
          expect(comment.commentable).to eq(participatory_process)
          expect(response["addComment"]).to include("id" => comment.id.to_s)
        end
      end
    end
  end
end
