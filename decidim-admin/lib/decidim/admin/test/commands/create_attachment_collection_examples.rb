# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "CreateAttachmentCollection command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:user) { create(:user, organization:) }
        let(:form_params) do
          {
            "attachment_collection" => {
              "name_en" => Decidim::Faker::Localized.sentence(word_count: 3),
              "name_es" => Decidim::Faker::Localized.sentence(word_count: 3),
              "name_ca" => Decidim::Faker::Localized.sentence(word_count: 3),
              "description_en" => Decidim::Faker::Localized.paragraph(sentence_count: 3),
              "description_es" => Decidim::Faker::Localized.paragraph(sentence_count: 3),
              "description_ca" => Decidim::Faker::Localized.paragraph(sentence_count: 3)
            }
          }
        end
        let(:form) do
          AttachmentCollectionForm.from_params(
            form_params,
            collection_for:
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form, collection_for, user) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create an attachment collection" do
            expect do
              command.call
            end.not_to change(AttachmentCollection, :count)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new attachment collection" do
            expect do
              command.call
            end.to change(collection_for.attachment_collections, :count).by(1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:create, Decidim::AttachmentCollection, user, {})
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("create")
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
