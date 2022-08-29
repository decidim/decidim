# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::ImportParticipatoryProcess do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let!(:document_file) { File.read(Decidim::Dev.asset(document_name)) }
    let(:form_doc) do
      instance_double(File,
                      blank?: false)
    end
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessImportForm,
        title: { en: "title" },
        slug: "imported-slug",
        import_steps?: import_steps,
        import_categories?: import_categories,
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
    let(:document_name) { "participatory_processes.json" }
    let(:document_type) { "application/json" }
    let(:import_steps) { false }
    let(:import_components) { false }
    let(:import_attachments) { false }
    let(:import_categories) { false }

    shared_examples "import participatory_process succeeds" do
      it "broadcasts ok and create the process" do
        expect { subject.call }.to(
          broadcast(:ok) &&
          change { ::Decidim::ParticipatoryProcess.where(organization:).count }.by(1)
        )

        imported_participatory_process = Decidim::ParticipatoryProcess.last

        expect(imported_participatory_process.slug).to eq("imported-slug")
        expect(imported_participatory_process.title["en"]).to eq("title")
        expect(imported_participatory_process).not_to be_published
        expect(imported_participatory_process.organization).to eq(organization)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!).exactly(3).times
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

      it "doesn't create any proces" do
        expect do
          subject.call
        end.not_to change(::Decidim::ParticipatoryProcess, :count)
      end
    end

    describe "when the form is valid" do
      let(:valid) { true }

      context "with json document" do
        it_behaves_like "import participatory_process succeeds"
      end
    end

    describe "when import_components exists" do
      let(:import_components) { true }

      it "imports a participatory process and the steps" do
        expect { subject.call }.to change(Decidim::Component, :count).by(3)
        expect(Decidim::Component.where(participatory_space_id: Decidim::ParticipatoryProcess.last).count).to eq 3
      end

      context "when participatory process steps are null" do
        let(:document_name) { "participatory_processes_with_null.json" }

        it_behaves_like "import participatory_process succeeds"
      end
    end

    describe "when import_steps exists" do
      let(:import_steps) { true }

      it "imports a participatory process and the steps" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcessStep, :count).by(1)
        expect(Decidim::ParticipatoryProcessStep.distinct.pluck(:decidim_participatory_process_id).count).to eq 1

        imported_participatory_process_step = Decidim::ParticipatoryProcessStep.last

        expect(imported_participatory_process_step.title).to eq("ca" => "Quo.", "en" => "Magni.", "es" => "Praesentium.")
        expect(imported_participatory_process_step.description).not_to be_nil
      end

      context "when participatory process steps are null" do
        let(:document_name) { "participatory_processes_with_null.json" }

        it_behaves_like "import participatory_process succeeds"
      end
    end

    describe "when import_categories exists" do
      let(:import_categories) { true }

      it "imports a participatory process and the categories" do
        expect { subject.call }.to change(Decidim::Category, :count).by(8)
        expect(Decidim::Category.unscoped.distinct.pluck(:decidim_participatory_space_id).count).to eq 1

        imported_participatory_process_category = Decidim::Category.unscoped.first
        expect(imported_participatory_process_category.name).to eq(
          "ca" => "Rerum quo dicta asperiores officiis.",
          "en" => "Illum nesciunt praesentium explicabo qui.",
          "es" => "Consequatur dolorem aspernatur quia aut."
        )
        expect(imported_participatory_process_category.participatory_space).to eq(Decidim::ParticipatoryProcess.last)
      end

      context "when categories are null" do
        let(:document_name) { "participatory_processes_with_null.json" }

        it_behaves_like "import participatory_process succeeds"
      end
    end

    describe "when import_attachments exists" do
      let(:import_attachments) { true }

      context "when attachment collections exists" do
        it "imports a participatory process and the collections" do
          expect { subject.call }.to change(Decidim::AttachmentCollection, :count).by(1)
          imported_participatory_process_collection = Decidim::AttachmentCollection.first
          expect(imported_participatory_process_collection.name).to eq("ca" => "assumenda", "en" => "cumque", "es" => "rem")
          expect(imported_participatory_process_collection.collection_for).to eq(Decidim::ParticipatoryProcess.last)
        end
      end

      context "when attachments are null" do
        let(:document_name) { "participatory_processes_with_null.json" }

        it_behaves_like "import participatory_process succeeds"
      end
    end
  end
end
