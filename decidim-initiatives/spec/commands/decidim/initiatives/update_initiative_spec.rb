# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe UpdateInitiative do
      let(:form_klass) { Decidim::Initiatives::InitiativeForm }
      let(:organization) { create(:organization) }
      let!(:initiative) { create(:initiative, organization: organization) }
      let!(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          initiative: initiative,
          initiative_type: initiative.type
        )
      end
      let(:signature_type) { "online" }
      let(:hashtag) { nil }
      let(:attachment) { nil }
      let(:uploaded_files) { [] }
      let(:current_files) { [] }

      describe "call" do
        let(:title) { "Changed Title" }
        let(:description) { "Changed description" }
        let(:type_id) { initiative.type.id }
        let(:form_params) do
          {
            title: title,
            description: description,
            signature_type: signature_type,
            type_id: type_id,
            attachment: attachment,
            add_documents: uploaded_files,
            documents: current_files
          }
        end
        let(:command) do
          described_class.new(initiative, form, initiative.author)
        end

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the initiative" do
            expect do
              command.call
            end.not_to change(initiative, :title)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the initiative" do
            command.call
            initiative.reload
            expect(initiative.title).to be_kind_of(Hash)
            expect(initiative.title["en"]).to eq title
            expect(initiative.description).to be_kind_of(Hash)
            expect(initiative.description["en"]).to eq description
          end

          context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
            let(:uploaded_files) do
              [
                Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
                Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")
              ]
            end

            it "creates multiple atachments for the initiative" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(2)
              initiative.reload
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to eq(initiative)
            end
          end

          context "when attachments are allowed and file is invalid", processing_uploads_for: Decidim::AttachmentUploader do
            let(:uploaded_files) do
              [
                Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
                Decidim::Dev.test_file("Exampledocument.pdf", "")
              ]
            end

            it "does not create atachments for the initiative" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(0)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
