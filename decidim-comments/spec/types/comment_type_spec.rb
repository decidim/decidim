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

      describe "hasComments" do
        let (:query) { "{ hasComments }" }

        it "returns false if the comment has not comments" do
          expect(response).to include("hasComments" => false)
        end

        it "returns true if the comment has comments" do
          FactoryGirl.create(:comment, commentable: model)
          expect(response).to include("hasComments" => true)
        end

        it "returns false if the comment depth is equal to MAX_DEPTH" do
          FactoryGirl.create(:comment, commentable: model)
          model.update_attribute(:depth, Comment::MAX_DEPTH)
          expect(response).to include("hasComments" => false)
        end
      end

      describe "acceptsNewComments" do
        let (:query) { "{ acceptsNewComments }" }

        it "returns the return value of accepts_new_comments? method" do
          expect(response).to include("acceptsNewComments" => model.accepts_new_comments?)
        end
      end

      describe "comments" do
        let!(:random_comment) { FactoryGirl.create(:comment) }
        let!(:replies) { 3.times.map { |n| FactoryGirl.create(:comment, commentable: model, created_at: Time.now - n.days) } }


        let(:query) { "{ comments { id } }" }

        it "return comment's comments comments data" do
          replies.each do |reply|
            expect(response["comments"]).to include("id" => reply.id.to_s)
          end
          expect(response["comments"]).not_to include("id" => random_comment.id.to_s)
        end

        it "return comment's comments ordered by date" do
          response_ids = response["comments"].map{|reply| reply["id"].to_i }
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
