# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateComment, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:feature) { create(:feature, participatory_process: participatory_process) }
        let(:user) { create(:user, organization: organization) }
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
            expect(Comment).to receive(:create!).with(
              author: author,
              commentable: commentable,
              root_commentable: commentable,
              body: body,
              alignment: alignment,
              decidim_user_group_id: user_group_id
            ).and_call_original

            expect do
              command.call
            end.to change { Comment.count }.by(1)
          end

          context "and the commentable is not notifiable" do
            before do
              expect(commentable).to receive(:notifiable?).and_return(false)
            end

            it "doesn't send an email" do
              expect(CommentNotificationMailer).not_to receive(:comment_created)
              command.call
            end
          end

          context "and the commentable is notifiable" do
            before do
              expect(commentable).to receive(:notifiable?).and_return(true)
              expect(commentable).to receive(:users_to_notify).and_return([user])
            end

            context "and the comment is a root comment" do
              it "sends an email to the author of the commentable" do
                expect(CommentNotificationMailer)
                  .to receive(:comment_created)
                  .with(user, an_instance_of(Comment), commentable)
                  .and_call_original

                command.call
              end
            end

            context "and the comment is a reply" do
              let(:commentable) { create(:comment, commentable: dummy_resource) }

              it "stores the root commentable" do
                command.call
                expect(Comment.last.root_commentable).to eq(dummy_resource)
              end

              it "sends an email to the author of the parent comment" do
                expect(CommentNotificationMailer)
                  .to receive(:reply_created)
                  .with(user, an_instance_of(Comment), commentable, commentable.root_commentable)
                  .and_call_original

                command.call
              end
            end
          end
        end
      end
    end
  end
end
