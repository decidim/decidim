# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe UpVoteComment, :db do
      describe "call" do
        let(:author) { create :user }
        let(:comment) { create :comment }
        let(:command) { described_class.new(comment, author) }

        describe "when the upvote is not created" do
          before do
            expect(comment.up_votes).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment vote" do
            expect do
              command.call
            end.to_not change { CommentVote.count }
          end
        end

        describe "when the upvote is already created for this user" do
          before do
            expect(comment.up_votes).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment vote" do
            expect do
              command.call
            end.to_not change { CommentVote.count }
          end
        end

        describe "when the upvote is created" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new comment upvote" do
            expect(comment.up_votes).to receive(:create!).with({
              author: author
            }).and_call_original
            expect do
              command.call
            end.to change { CommentVote.count }.by(1)
          end
        end
      end
    end
  end
end
