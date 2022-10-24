# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe VoteComment do
      describe "call" do
        let(:organization) { create :organization }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space: participatory_process) }
        let(:commentable) { create(:dummy_resource, component:) }
        let(:author) { create(:user, organization:) }
        let(:comment) { create(:comment, commentable:) }
        let(:options) { { weight: } }
        let(:weight) { 1 }
        let(:command) { described_class.new(comment, author, options) }

        describe "when the author is not in the same org as the comment" do
          let(:author) { build(:user, organization: create(:organization)) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment vote" do
            expect do
              command.call
            end.not_to change(CommentVote, :count)
          end
        end

        describe "when the vote is already created for this user" do
          before do
            comment.up_votes.create!(author:)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "removes the comment vote from this user" do
            expect do
              command.call
            end.to change(CommentVote, :count).by(-1)
          end
        end

        describe "when the vote is created" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new comment vote" do
            expect do
              command.call
            end.to change(CommentVote, :count).by(1)
          end
        end

        describe "sending notification" do
          context "when weight is positive" do
            let(:weight) { 1 }

            it "notifies the comment author of upvote event" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .with(
                  event: "decidim.events.comments.comment_upvoted",
                  event_class: Decidim::Comments::CommentUpvotedEvent,
                  resource: commentable,
                  affected_users: [comment.author],
                  extra: {
                    comment_id: comment.id,
                    weight:,
                    upvotes: comment.up_votes.count + 1,
                    downvotes: comment.down_votes.count
                  }
                )
              command.call
            end
          end

          context "when weight is negative" do
            let(:weight) { -1 }

            it "notifies the comment author of downvote event" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .with(
                  event: "decidim.events.comments.comment_downvoted",
                  event_class: Decidim::Comments::CommentDownvotedEvent,
                  resource: commentable,
                  affected_users: [comment.author],
                  extra: {
                    comment_id: comment.id,
                    weight:,
                    upvotes: comment.up_votes.count,
                    downvotes: comment.down_votes.count + 1
                  }
                )
              command.call
            end
          end
        end

        describe "when weight value is not the default" do
          describe "and it is equal to -1" do
            let(:command) { described_class.new(comment, author, weight: -1) }

            describe "when the author is not in the same org as the comment" do
              let(:author) { build(:user, organization: create(:organization)) }

              it "broadcasts invalid" do
                expect { command.call }.to broadcast(:invalid)
              end

              it "doesn't create a comment vote" do
                expect do
                  command.call
                end.not_to change(CommentVote, :count)
              end
            end

            describe "when the vote is already created for this user" do
              before do
                comment.down_votes.create!(author:)
              end

              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok)
              end

              it "removes the comment vote from this user" do
                expect do
                  command.call
                end.to change(CommentVote, :count).by(-1)
              end
            end

            describe "when the vote is created" do
              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok)
              end

              it "creates a new comment vote" do
                expect do
                  command.call
                end.to change(CommentVote, :count).by(1)
              end
            end
          end

          describe "and it has a invalid value" do
            let(:command) { described_class.new(comment, author, weight: 2) }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
