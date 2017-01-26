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

        it "returns its created_at field to iso format" do
          expect(response).to include("createdAt" => model.created_at.iso8601)
        end
      end

      describe "hasReplies" do
        let (:query) { "{ hasReplies }" }

        it "returns false if the comment has not replies" do
          expect(response).to include("hasReplies" => false)
        end

        it "returns true if the comment has replies" do
          FactoryGirl.create(:comment, commentable: model)
          expect(response).to include("hasReplies" => true)
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
        let!(:replies) { 3.times.map { |n| FactoryGirl.create(:comment, commentable: model, created_at: Time.now - n.days) } }


        let(:query) { "{ replies { id } }" }

        it "return comment's replies comments data" do
          replies.each do |reply|
            expect(response["replies"]).to include("id" => reply.id.to_s)
          end
          expect(response["replies"]).to_not include("id" => random_comment.id.to_s)
        end

        it "return comment's replies ordered by date" do
          response_ids = response["replies"].map{|reply| reply["id"].to_i }
          replies_ids = replies.sort_by(&:created_at).map(&:id)
          expect(response_ids).to eq(replies_ids)
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

      describe "upVoted" do
        let(:query) { "{ upVoted }" }

        it "returns the up_voted_by? method evaluation with the current user" do
          expect(model).to receive(:up_voted_by?).with(current_user).and_return(true)
          expect(response).to include("upVoted" => true)
        end
      end

      describe "downVoted" do
        let(:query) { "{ downVoted }" }

        it "returns the down_voted_by? method evaluation with the current user" do
          expect(model).to receive(:down_voted_by?).with(current_user).and_return(true)
          expect(response).to include("downVoted" => true)
        end
      end
    end
  end
end
