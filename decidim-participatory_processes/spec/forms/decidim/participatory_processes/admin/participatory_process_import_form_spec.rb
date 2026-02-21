# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessImportForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:document) { upload_test_file(Decidim::Dev.asset("participatory_processes.json"), content_type: "application/json", return_blob: true) }
        let(:slug) { "imported-process-slug" }
        let(:title) do
          {
            en: "Imported Process",
            es: "Proceso Importado",
            ca: "Procés Importat"
          }
        end

        let(:params) do
          {
            slug:,
            title_en: title[:en],
            title_es: title[:es],
            title_ca: title[:ca],
            document:,
            import_steps: true,
            import_attachments: true,
            import_components: true
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when document is missing" do
          let(:document) { nil }

          it { is_expected.to be_invalid }

          it "adds an error on document" do
            form.valid?
            expect(form.errors[:document]).not_to be_empty
          end
        end

        context "when document content type is not valid" do
          let(:document) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"), return_blob: true) }

          it { is_expected.to be_invalid }

          it "adds an error on document" do
            form.valid?
            expect(form.errors[:document]).not_to be_empty
          end
        end

        context "when slug is missing" do
          let(:slug) { nil }

          it { is_expected.to be_invalid }
        end

        context "when slug is not valid" do
          let(:slug) { "123-invalid-slug" }

          it { is_expected.to be_invalid }
        end

        context "when slug is not unique" do
          before do
            create(:participatory_process, slug:, organization:)
          end

          it { is_expected.to be_invalid }

          it "adds an error on slug" do
            form.valid?
            expect(form.errors[:slug]).not_to be_empty
          end
        end

        context "when default language in title is missing" do
          let(:title) do
            {
              ca: "Procés Importat"
            }
          end

          it { is_expected.to be_invalid }
        end

        context "when document has empty JSON array" do
          let(:document) do
            file = Tempfile.new(["empty", ".json"])
            file.write("[]")
            file.rewind
            upload_test_file(file.path, content_type: "application/json", return_blob: true)
          end

          it { is_expected.to be_invalid }

          it "adds an error on document" do
            form.valid?
            expect(form.errors[:document]).to include("The document is empty")
          end
        end

        context "when document has invalid JSON" do
          let(:document) do
            file = Tempfile.new(["invalid", ".json"])
            file.write("{ invalid }")
            file.rewind
            upload_test_file(file.path, content_type: "application/json", return_blob: true)
          end

          it { is_expected.to be_invalid }

          it "adds an error on document" do
            form.valid?
            expect(form.errors[:document]).to include("The document is not valid JSON")
          end
        end
      end
    end
  end
end
