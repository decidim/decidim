# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateComment do
      describe "call" do
        include_context "when creating a comment"

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
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

        describe "when the nesting is too deep" do
          let!(:first_comment) { create(:comment, commentable: dummy_resource) }
          let!(:second_comment) { create(:comment, commentable: first_comment) }
          let!(:third_comment) { create(:comment, commentable: second_comment) }
          let!(:commentable) { create(:comment, commentable: third_comment) }
          let(:command) { described_class.new(form, author) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment" do
            expect do
              command.call
            end.not_to change(Comment, :count)
          end
        end

        describe "when the form is valid and the nesting is not too deep" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new comment" do
            expect(Comment).to receive(:create!).with(
              { author: author,
                commentable: commentable,
                root_commentable: commentable,
                body: { en: body },
                alignment: alignment,
                decidim_user_group_id: user_group_id,
                participatory_space: form.current_component.try(:participatory_space) }
            ).and_call_original

            expect do
              command.call
            end.to change(Comment, :count).by(1)
          end

          it "creates a new searchable resource" do
            expect do
              perform_enqueued_jobs { command.call }
            end.to change(Decidim::SearchableResource, :count).by_at_least(1)
          end

          it "calls content processors" do
            user_parser = instance_double("kind of UserParser", users: [])
            user_group_parser = instance_double("kind of UserGroupParser", groups: [])
            parsed_metadata = { user: user_parser, user_group: user_group_parser }
            parser = instance_double("kind of parser", rewrite: "whatever", metadata: parsed_metadata)
            allow(Decidim::ContentProcessor).to receive(:parse).with(
              form.body,
              current_organization: form.current_organization
            ).and_return(parser)
            expect(CommentCreation).to receive(:publish).with(a_kind_of(Comment), parsed_metadata)

            command.call
          end

          it "sends the notifications" do
            creator_double = instance_double(NewCommentNotificationCreator, create: true)

            allow(NewCommentNotificationCreator)
              .to receive(:new)
              .with(kind_of(Comment), [], [])
              .and_return(creator_double)

            expect(creator_double)
              .to receive(:create)

            command.call
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(
                Decidim::Comments::Comment,
                author,
                kind_of(Hash),
                visibility: "public-only"
              )
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "create"
          end

          context "and comment contains a user mention" do
            let(:mentioned_user) { create(:user, organization: organization) }
            let(:parser_context) { { current_organization: organization } }
            let(:body) { ::Faker::Lorem.paragraph + " @#{mentioned_user.nickname}" }

            it "creates a new comment with user mention replaced" do
              expect(Comment).to receive(:create!).with(
                { author: author,
                  commentable: commentable,
                  root_commentable: commentable,
                  body: { en: Decidim::ContentProcessor.parse(body, parser_context).rewrite },
                  alignment: alignment,
                  decidim_user_group_id: user_group_id,
                  participatory_space: form.current_component.try(:participatory_space) }
              ).and_call_original

              expect do
                command.call
              end.to change(Comment, :count).by(1)
            end

            it "sends the notifications" do
              creator_double = instance_double(NewCommentNotificationCreator, create: true)

              allow(NewCommentNotificationCreator)
                .to receive(:new)
                .with(kind_of(Comment), [mentioned_user], [])
                .and_return(creator_double)

              expect(creator_double)
                .to receive(:create)

              command.call
            end
          end

          context "and comment contains a group mention" do
            let(:mentioned_group) { create(:user_group, organization: organization) }
            let(:parser_context) { { current_organization: organization } }
            let(:body) { ::Faker::Lorem.paragraph + " @#{mentioned_group.nickname}" }

            it "creates a new comment with user_group mention replaced" do
              expect(Comment).to receive(:create!).with(
                { author: author,
                  commentable: commentable,
                  root_commentable: commentable,
                  body: { en: Decidim::ContentProcessor.parse(body, parser_context).rewrite },
                  alignment: alignment,
                  decidim_user_group_id: user_group_id,
                  participatory_space: form.current_component.try(:participatory_space) }
              ).and_call_original

              expect do
                command.call
              end.to change(Comment, :count).by(1)
            end

            it "sends the notifications" do
              creator_double = instance_double(NewCommentNotificationCreator, create: true)

              allow(NewCommentNotificationCreator)
                .to receive(:new)
                .with(kind_of(Comment), [], [mentioned_group])
                .and_return(creator_double)

              expect(creator_double)
                .to receive(:create)

              command.call
            end
          end
        end
      end
    end
  end
end
