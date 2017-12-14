# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "CreateAttachmentCollection command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:form_params) do
          {
            "attachment_collection" => {
              "name_en" => Decidim::Faker::Localized.sentence(3),
              "name_es" => Decidim::Faker::Localized.sentence(3),
              "name_ca" => Decidim::Faker::Localized.sentence(3),
              "description_en" => Decidim::Faker::Localized.paragraph(3),
              "description_es" => Decidim::Faker::Localized.paragraph(3),
              "description_ca" => Decidim::Faker::Localized.paragraph(3)
            }
          }
        end
        let(:form) do
          AttachmentCollectionForm.from_params(
            form_params,
            current_participatory_space: participatory_space
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form, participatory_space) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create an attachment collection" do
            expect do
              command.call
            end.not_to change { AttachmentCollection.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new attachment collection" do
            expect do
              command.call
            end.to change { participatory_space.attachment_collections.count }.by(1)
          end
        end
      end
    end
  end
end
