# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Api
    describe MutationType do
      include_context "with a graphql type"

      describe "commentable" do
        let!(:commentable) { create(:dummy_resource) }
        let(:query) do
          "{ commentable(id: \"#{commentable.id}\", type: \"#{commentable.commentable_type}\", locale: \"en\", toggleTranslations: false) { id } }"
        end

        it "fetches the commentable given its id and commentable_type" do
          expect(response["commentable"]).to include("id" => commentable.id.to_s)
        end
      end

      describe "comment" do
        let!(:comment) { create(:comment) }
        let(:query) { "{ comment(id: \"#{comment.id}\", locale: \"en\", toggleTranslations: false) { id } }" }

        it "fetches the comment given its id" do
          expect(response["comment"]).to include("id" => comment.id.to_s)
        end
      end
    end
  end
end
