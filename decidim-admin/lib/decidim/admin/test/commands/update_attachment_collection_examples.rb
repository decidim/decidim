# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "UpdateAttachmentCollection command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:user) { create(:user, organization: organization) }
        let(:attachment_collection) { create(:attachment_collection, collection_for: collection_for) }
        let(:form_params) do
          {
            "attachment_collection" => {
              "name_en" => "New title",
              "name_es" => "Title",
              "name_ca" => "Title",
              "description_en" => "Description",
              "description_es" => "Description",
              "description_ca" => "Description"
            }
          }
        end
        let(:form) do
          AttachmentCollectionForm.from_params(
            form_params,
            collection_for: collection_for
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(attachment_collection, form, user) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the attachment collection" do
            command.call
            attachment_collection.reload

            expect(translated(attachment_collection.name)).not_to eq("New title")
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the attachment collection in the process" do
            command.call
            attachment_collection.reload

            expect(translated(attachment_collection.name)).to eq("New title")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:update, Decidim::AttachmentCollection, user, {})
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("update")
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
