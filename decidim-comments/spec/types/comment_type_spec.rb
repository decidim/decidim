# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Comments
    describe CommentType do
      include_context "graphql type"

      let(:model) { FactoryGirl.create(:comment) }

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns its created_at field" do
          expect(response).to include("createdAt" => model.created_at.to_s)
        end
      end

      describe "canHaveReplies" do
        let (:query) { "{ canHaveReplies }" }
        
        it "returns the return value of can_have_replies? method" do
          expect(response).to include("canHaveReplies" => model.can_have_replies?)
        end
      end

      describe "replies" do
        let!(:random_comment) { FactoryGirl.create(:comment) }
        let!(:replies) { 3.times.map { FactoryGirl.create(:comment, commentable: model) } }

        let(:query) { "{ replies { id } }" }

        it "return comment's replies comments data" do
          replies.each do |reply|
            expect(response["replies"]).to include("id" => reply.id.to_s)
          end
          expect(response["replies"]).to_not include("id" => random_comment.id.to_s)
        end
      end

      describe "alignment" do
        let(:query) { "{ alignment }" }

        it "returns the alignment field" do
          expect(response).to include("alignment" => model.alignment)
        end
      end

      describe "upVotes" do
        let(:query) { "{ upVotes }" }

        it "returns the up_votes count" do
          expect(response).to include("upVotes" => model.up_votes.count)
        end
      end

      describe "downVotes" do
        let(:query) { "{ downVotes }" }

        it "returns the down_votes count" do
          expect(response).to include("downVotes" => model.down_votes.count)
        end
      end
    end
  end
end
