# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe UpdateInitiative do
      let(:form_klass) { Decidim::Initiatives::InitiativeForm }
      let(:organization) { create(:organization) }
      let!(:initiative) { create(:initiative, organization:) }
      let!(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          initiative:,
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
            title:,
            description:,
            signature_type:,
            type_id:,
            attachment:,
            add_documents: uploaded_files,
            documents: current_files
          }
        end
        let(:command) do
          described_class.new(initiative, form, initiative.author)
        end

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
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

          context "when attachments are allowed" do
            let(:uploaded_files) do
              [
                upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")),
                upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"))
              ]
            end

            it "creates multiple atachments for the initiative" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(2)
              initiative.reload
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to eq(initiative)
            end

            context "when the initiative already had some attachments" do
              let!(:document) { create(:attachment, :with_pdf, attached_to: initiative) }
              let(:current_files) { [document.id] }

              it "keeps the new and old attachments" do
                command.call
                initiative.reload
                expect(initiative.documents.count).to eq(3)
              end

              context "when the old attachments are deleted by the user" do
                let(:current_files) { [] }

                it "deletes the old attachments" do
                  command.call
                  initiative.reload
                  expect(initiative.documents.count).to eq(2)
                  expect(initiative.documents).not_to include(document)
                end
              end
            end
          end

          context "when attachments are allowed and file is invalid" do
            let(:uploaded_files) do
              [
                upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")),
                upload_test_file(Decidim::Dev.test_file("verify_user_groups.csv", "text/csv"))
              ]
            end

            it "does not create atachments for the initiative" do
              expect { command.call }.not_to change(Decidim::Attachment, :count)
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
