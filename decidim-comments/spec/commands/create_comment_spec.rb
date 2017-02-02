# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe CreateComment, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization)}
        let(:feature) { create(:feature, participatory_process: participatory_process)}
        let(:author) { create(:user, organization: organization) }
        let(:dummy_resource) { create :dummy_resource, feature: feature }
        let(:commentable) { dummy_resource }
        let(:body) { ::Faker::Lorem.paragraph }
        let(:alignment) { 1 }
        let(:user_group_id) { nil }
        let(:form_params) do
          {
            "comment" => {
              "body" => body,
              "alignment" => alignment,
              "user_group_id" => user_group_id
            }
          }
        end
        let(:form) do
          CommentForm.from_params(
            form_params
          )
        end
        let(:command) { described_class.new(form, author, commentable) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment" do
            expect do
              command.call
            end.not_to change { Comment.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new comment" do
            expect(Comment).to receive(:create!).with({
              author: author,
              commentable: commentable,
              body: body,
              alignment: alignment,
              decidim_user_group_id: user_group_id
            }).and_call_original
            expect do
              command.call
            end.to change { Comment.count }.by(1)
          end

          context "and the comment is a root comment" do
            it "sends an email to the author of the commentable" do
              expect(CommentNotificationMailer)
                .to receive(:comment_created)
                .with(author, an_instance_of(Comment), commentable)
                .and_call_original

              command.call
            end

            context "and I am the author of the commentable" do
              let(:dummy_resource) { create :dummy_resource, feature: feature, author: author }

              it "doesn't send an email" do
                expect(CommentNotificationMailer).not_to receive(:comment_created)
                command.call
              end
            end

            context "and the author has comment notifications disabled" do
              let(:author) { create(:user, organization: organization, comments_notifications: false) }

              it "doesn't send an email" do
                expect(CommentNotificationMailer).not_to receive(:comment_created)
                command.call
              end
            end
          end

          context "and the comment is a reply" do
            let (:commentable) { create(:comment, commentable: dummy_resource) }

            it "sends an email to the author of the parent comment" do
              expect(CommentNotificationMailer)
                .to receive(:reply_created)
                .with(author, an_instance_of(Comment), commentable, commentable.root_commentable)
                .and_call_original

              command.call
            end

            context "and I am the author of the parent comment" do
              let (:commentable) { create(:comment, author: author, commentable: dummy_resource) }

              it "doesn't send an email" do
                expect(CommentNotificationMailer).not_to receive(:reply_created)
                command.call
              end
            end

            context "and the author has reply notifications disabled" do
              let(:author) { create(:user, organization: organization, replies_notifications: false) }

              it "doesn't send an email" do
                expect(CommentNotificationMailer).not_to receive(:reply_created)
                command.call
              end
            end
          end
        end
      end
    end
  end
end
