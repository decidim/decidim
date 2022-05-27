# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Import::Importer do
  subject { described_class.new(file: blob, reader: reader, creator: creator, context: context) }

  let(:creator) { Decidim::Proposals::Import::ProposalCreator }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:user) { create(:user, organization: organization) }
  let(:context) do
    {
      current_organization: organization,
      current_user: user,
      current_component: current_component,
      current_participatory_space: participatory_process
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }

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
end
