# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies::Admin
  describe ImportAssembly do
    include Decidim::ComponentTestHelpers

    subject { described_class.new(form, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }
    let!(:document_file) { File.read(Decidim::Dev.asset(document_name)) }
    let(:form_doc) do
      instance_double(File,
                      blank?: false)
    end
    let(:form) do
      instance_double(
        AssemblyImportForm,
        title: { en: "title" },
        slug: "imported-slug",
        import_steps?: import_steps,
        import_attachments?: import_attachments,
        import_components?: import_components,
        document: form_doc,
        document_text: document_file,
        document_type:,
        current_user: create(:user, organization:),
        current_organization: organization,
        invalid?: invalid
      )
    end

    let(:invalid) { false }
    let(:document_name) { "assemblies.json" }
    let(:document_type) { "application/json" }
    let(:import_steps) { false }
    let(:import_components) { false }
    let(:import_attachments) { false }

    def stub_calls_to_external_files
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/hero_image/1/city.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/banner_image/1/city2.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/attachment/file/31/Exampledocument.pdf",
        "application/pdf"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/attachment/file/32/city.jpeg",
        "image/jpeg"
      )
    end

    shared_examples "import assembly succeeds" do
      before { stub_calls_to_external_files }

      it "broadcasts ok and create the assembly" do
        expect { subject.call }.to(
          broadcast(:ok) &&
          change { ::Decidim::Assembly.where(organization:).count }.by(1)
        )

        imported_assembly = Decidim::Assembly.last

        expect(imported_assembly.slug).to eq("imported-slug")
        expect(imported_assembly.title["en"]).to eq("title")
        expect(imported_assembly).not_to be_published
        expect(imported_assembly.organization).to eq(organization)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!).twice
                                       .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("import")
        expect(action_log.version).to be_present
      end
    end

    describe "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "does not create any assembly" do
        expect do
          subject.call
        end.not_to change(::Decidim::Assembly, :count)
      end
    end

    describe "when the form is valid" do
      let(:valid) { true }

      context "with json document" do
        it_behaves_like "import assembly succeeds"
      end
    end

    describe "when import_attachments exists" do
      let(:import_attachments) { true }

      context "when attachment collections exists" do
        it "imports an assembly and the collections" do
          stub_calls_to_external_files

          expect { subject.call }.to change(Decidim::AttachmentCollection, :count).by(1)
          imported_assembly_collection = Decidim::AttachmentCollection.first
          expect(imported_assembly_collection.name).to eq("ca" => "deleniti", "en" => "laboriosam", "es" => "quia")
          expect(imported_assembly_collection.collection_for).to eq(Decidim::Assembly.last)
        end
      end
    end
  end
end
