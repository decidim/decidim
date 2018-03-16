# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe VoteComment do
      describe "call" do
        let(:organization) { create :organization }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:component) { create(:component, participatory_space: participatory_process) }
        let(:commentable) { create(:dummy_resource, component: component) }
        let(:author) { create(:user, organization: organization) }
        let(:comment) { create(:comment, commentable: commentable) }
        let(:command) { described_class.new(comment, author) }

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
            comment.up_votes.create!(author: author)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment vote" do
            expect do
              command.call
            end.not_to change(CommentVote, :count)
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
                comment.down_votes.create!(author: author)
              end

              it "broadcasts invalid" do
                expect { command.call }.to broadcast(:invalid)
              end

              it "doesn't create a comment vote" do
                expect do
                  command.call
                end.not_to change(CommentVote, :count)
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
