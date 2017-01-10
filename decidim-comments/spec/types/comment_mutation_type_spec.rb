# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Comments
    describe CommentMutationType do
      include_context "graphql type"
      let(:model) { create(:comment) }

      describe "upVote" do
        let(:query) {
          "{ upVote { upVoted } }"
        }

        before do
          allow(Decidim::Comments::VoteComment).to receive(:call).with(model, current_user, weight: 1).and_return (
            model
          )
        end

        it "should call UpVoteComment command" do
          expect(model).to receive(:up_voted_by?).with(current_user).and_return(true)
          expect(response["upVote"]).to include("upVoted" => true)
        end
      end

      describe "downVote" do
        let(:query) {
          "{ downVote { downVoted } }"
        }

        before do
          allow(Decidim::Comments::VoteComment).to receive(:call).with(model, current_user, weight: -1).and_return (
            model
          )
        end

        it "should call UpVoteComment command" do
          expect(model).to receive(:down_voted_by?).with(current_user).and_return(true)
          expect(response["downVote"]).to include("downVoted" => true)
        end
      end
    end
  end
end
