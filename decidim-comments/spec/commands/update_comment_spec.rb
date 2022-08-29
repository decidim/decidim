# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe UpdateComment do
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:author) { create(:user, organization:) }
      let(:dummy_resource) { create :dummy_resource, component: }
      let(:commentable) { dummy_resource }
      let(:comment) { create :comment, author:, commentable: }
      let(:body) { "This is a reasonable comment" }
      let(:form_params) do
        {
          "comment" => {
            "body" => body,
            "commentable" => commentable
          }
        }
      end
      let(:form) do
        Decidim::Comments::CommentForm.from_params(
          form_params
        ).with_context(
          current_organization: organization
        )
      end
      let(:current_user) { author }
      let(:command) { described_class.new(comment, current_user, form) }

      describe "call" do
        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the comment" do
            expect { command.call }.not_to change(comment, :body)
          end
        end

        describe "when the comment is not authored by the user" do
          before do
            allow(comment).to receive(:authored_by?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the comment" do
            expect { command.call }.not_to change(comment, :body)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the comment" do
            command.call
            comment.reload
            expect(comment.body).to be_kind_of(Hash)
            expect(comment.body["en"]).to eq body
          end

          it "does not notify the followers" do
            expect(Decidim::EventsManager).not_to receive(:publish)

            command.call
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(
                Decidim::Comments::Comment,
                author,
                { body: { en: "This is a reasonable comment" } },
                { edit: true, visibility: "public-only" }
              )
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "update"
          end
        end
      end
    end
  end
end
