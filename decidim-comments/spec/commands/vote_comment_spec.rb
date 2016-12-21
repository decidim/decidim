# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe VoteComment, :db do
      describe "call" do
        let(:author) { create :user }
        let(:comment) { create :comment }
        let(:command) { described_class.new(comment, author) }

        describe "when the vote is not created" do
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

        describe "when the vote is already created for this user" do
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

        describe "when the vote is created" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new comment vote" do
            expect(comment.up_votes).to receive(:create!).with({
              author: author
            }).and_call_original
            expect do
              command.call
            end.to change { CommentVote.count }.by(1)
          end
        end

        describe "when weight value is not the default" do
          describe "and it is equal to -1" do
            let(:command) { described_class.new(comment, author, weight: -1) }

            describe "when the vote is not created" do
              before do
                expect(comment.down_votes).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
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

            describe "when the vote is already created for this user" do
              before do
                expect(comment.down_votes).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique)
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

            describe "when the vote is created" do
              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok)
              end

              it "creates a new comment vote" do
                expect(comment.down_votes).to receive(:create!).with({
                  author: author
                }).and_call_original
                expect do
                  command.call
                end.to change { CommentVote.count }.by(1)
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
