# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Api
    describe MutationType do
      include_context "graphql type"

      describe "commentable" do
        let!(:commentable) { create(:dummy_resource) }
        let(:query) do
          "{ commentable(id: \"#{commentable.id}\", type: \"#{commentable.commentable_type}\") { id } }"
        end

        it "should fetch the commentable given its id and commentable_type" do
          expect(response["commentable"]).to include("id" => commentable.id.to_s)
        end
      end

      describe "comment" do
        let!(:comment) { create(:comment) }
        let(:query) { "{ comment(id: \"#{comment.id}\") { id } }" }

        it "should fetch the comment given its id" do
          expect(response["comment"]).to include("id" => comment.id.to_s)
        end
      end
    end
  end
end
