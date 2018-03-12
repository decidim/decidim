# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateComment do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:component) { create(:component, participatory_space: participatory_process) }
        let(:user) { create(:user, organization: organization) }
        let(:author) { create(:user, organization: organization) }
        let(:dummy_resource) { create :dummy_resource, component: component }
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
          ).with_context(
            current_organization: organization
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
            end.not_to change(Comment, :count)
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
            end.to change(Comment, :count).by(1)
          end

          it "sends a notification to the corresponding users except the comment's author" do
            follower = create(:user, organization: organization)

            expect(commentable)
              .to receive(:users_to_notify_on_comment_created)
              .and_return([follower, author])

            expect_any_instance_of(Decidim::Comments::Comment) # rubocop:disable RSpec/AnyInstance
              .to receive(:id).at_least(:once).and_return 1

            expect_any_instance_of(Decidim::Comments::Comment) # rubocop:disable RSpec/AnyInstance
              .to receive(:root_commentable).at_least(:once).and_return commentable

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.comments.comment_created",
                event_class: Decidim::Comments::CommentCreatedEvent,
                resource: commentable,
                recipient_ids: [follower.id],
                extra: {
                  comment_id: a_kind_of(Integer)
                }
              )

            command.call
          end

          it "sends a notification to the author's followers" do
            follower = create(:user, organization: organization)
            create(:follow, followable: author, user: follower)

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.comments.comment_created",
                event_class: Decidim::Comments::CommentCreatedEvent,
                resource: commentable,
                recipient_ids: [follower.id],
                extra: {
                  comment_id: a_kind_of(Integer)
                }
              )

            command.call
          end

          context "and comment contains a user mention" do
            let(:mentioned_user) { create(:user, organization: organization) }
            let(:parser_context) { { current_organization: organization } }
            let(:body) { ::Faker::Lorem.paragraph + " @#{mentioned_user.nickname}" }

            it "creates a new comment with user mention replaced" do
              expect(Comment).to receive(:create!).with(
                author: author,
                commentable: commentable,
                root_commentable: commentable,
                body: Decidim::ContentProcessor.parse(body, parser_context).rewrite,
                alignment: alignment,
                decidim_user_group_id: user_group_id
              ).and_call_original

              expect do
                command.call
              end.to change(Comment, :count).by(1)
            end

            it "sends a notification to the mentioned users" do
              expect(command).to receive(:send_notification).and_return false

              expect(Decidim::EventsManager)
                .to receive(:publish)
                .with(
                  event: "decidim.events.comments.user_mentioned",
                  event_class: Decidim::Comments::UserMentionedEvent,
                  resource: commentable,
                  recipient_ids: [mentioned_user.id],
                  extra: {
                    comment_id: a_kind_of(Integer)
                  }
                )

              command.call
            end
          end
        end
      end
    end
  end
end
