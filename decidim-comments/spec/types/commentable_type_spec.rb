# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Comments
    describe CommentableType do
      include_context "graphql type"

      let(:model) { create(:dummy_resource) }
      let!(:comments) { create_list(:comment, 3, commentable: model) }

      describe "acceptsNewComments" do
        let(:query) { "{ acceptsNewComments }" }

        it "returns the 'accepts_new_comments?' method value" do
          expect(response).to include("acceptsNewComments" => model.accepts_new_comments?)
        end
      end

      describe "commentsHaveAlignment" do
        let(:query) { "{ commentsHaveAlignment }" }

        it "returns the 'comments_have_alignment?' method value" do
          expect(response).to include("commentsHaveAlignment" => model.comments_have_alignment?)
        end
      end

      describe "commentsHaveVotes" do
        let(:query) { "{ commentsHaveVotes }" }

        it "returns the 'comments_have_votes?' method value" do
          expect(response).to include("commentsHaveVotes" => model.comments_have_votes?)
        end
      end

      describe "comments" do
        let(:query) { "{ comments { id } }" }

        it "returns the commentable comments" do
          model.comments.each do |comment|
            expect(response["comments"]).to include("id" => comment.id.to_s)
          end
        end
      end
    end
  end
end
