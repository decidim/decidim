# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateComment do
      describe "call" do
        include_context "when creating a comment"

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

          it "calls content processors" do
            user_parser = instance_double("kind of UserParser", users: [])
            parsed_metadata = { user: user_parser }
            parser = instance_double("kind of parser", rewrite: "whatever", metadata: parsed_metadata)
            expect(Decidim::ContentProcessor).to receive(:parse).with(
              form.body,
              current_organization: form.current_organization
            ).and_return(parser)
            expect(CommentCreation).to receive(:publish).with(a_kind_of(Comment), parsed_metadata)

            command.call
          end

          it "sends the notifications" do
            creator_double = instance_double(NewCommentNotificationCreator, create: true)

            expect(NewCommentNotificationCreator)
              .to receive(:new)
              .with(kind_of(Comment), [])
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

            it "sends the notifications" do
              creator_double = instance_double(NewCommentNotificationCreator, create: true)

              expect(NewCommentNotificationCreator)
                .to receive(:new)
                .with(kind_of(Comment), [mentioned_user])
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
