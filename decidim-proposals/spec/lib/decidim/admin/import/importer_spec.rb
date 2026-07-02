# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Import::Importer do
  subject { described_class.new(file: blob, reader:, creator:, context:) }

  let(:creator) { Decidim::Proposals::Import::ProposalCreator }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:user) { create(:user, organization:) }
  let(:context) do
    {
      current_organization: organization,
      current_user: user,
      current_component:,
      current_participatory_space: participatory_process
    }
  end
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:proposal_component, participatory_space: participatory_process) }

  context "with CSV" do
    let(:blob) { upload_test_file(Decidim::Dev.asset("import_proposals.csv"), return_blob: true) }
    let(:reader) { Decidim::Admin::Import::Readers::CSV }

    it_behaves_like "proposal importer"

    describe "#verify" do
      it "verifies that the import data is valid" do
        expect(subject.verify).to be(true)
      end
    end

    describe "#prepare" do
      it "makes an array of new proposals" do
        expect(subject.prepare).to be_an_instance_of(Array)
        expect(subject.prepare).not_to be_empty
        expect(subject.prepare).to all(be_a_instance_of(Decidim::Proposals::Proposal))
      end
    end

    describe "#import" do
      it "saves the proposals" do
        subject.prepare
        expect do
          subject.import!
        end.to change(Decidim::Proposals::Proposal, :count).by(3)
      end

      it "calls the creator batch notifier with import creator class in context" do
        notifier = instance_double(Decidim::Proposals::Import::BatchNotifier, notify!: nil)
        allow(Decidim::Proposals::Import::BatchNotifier).to receive(:new).and_return(notifier)

        subject.prepare
        subject.import!

        expect(Decidim::Proposals::Import::BatchNotifier).to have_received(:new).with(
          collection: kind_of(Array),
          context: hash_including(
            current_organization: organization,
            current_user: user,
            current_component:,
            current_participatory_space: participatory_process,
            import_creator_class: creator
          )
        )
        expect(notifier).to have_received(:notify!)
      end
    end
  end

  context "with JSON" do
    let(:blob) { upload_test_file(Decidim::Dev.asset("import_proposals.json"), return_blob: true) }
    let(:reader) { Decidim::Admin::Import::Readers::JSON }

    it_behaves_like "proposal importer"
  end

  context "with XLSX" do
    let(:blob) { upload_test_file(Decidim::Dev.asset("import_proposals.xlsx"), return_blob: true) }
    let(:reader) { Decidim::Admin::Import::Readers::XLSX }

    it_behaves_like "proposal importer"
  end

  context "when reader returns blank rows" do
    let(:blob) { upload_test_file(Decidim::Dev.asset("import_proposals.csv"), return_blob: true) }
    let(:reader) do
      Class.new(Decidim::Admin::Import::Readers::Base) do
        def read_rows
          yield %w(title/en body/en), 0
          yield ["Imported title", "Imported body"], 1
          yield [nil, nil], 2
          yield ["", ""], 3
          yield [], 4
        end
      end
    end

    it "ignores blank rows when preparing the collection" do
      expect(subject.prepare.length).to eq(1)
    end
  end
end
