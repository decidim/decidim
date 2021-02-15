# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Import::Importer do
  subject { described_class.new(file: file, reader: reader, creator: creator, context: context) }

  let(:creator) { Decidim::Proposals::ProposalCreator }

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
    let(:file) { File.new Decidim::Dev.asset("import_proposals.csv") }
    let(:reader) { Decidim::Admin::Import::Readers::CSV }

    it_behaves_like "proposal importer"

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

    describe "#invalid_lines" do
      it "returns empty array when everything is ok" do
        subject.prepare
        expect(subject.invalid_lines).to be_empty
      end

      it "returns index+1 of erroneous resource when validations faild" do
        proposal = subject.prepare.first
        proposal.title = ""
        subject.instance_variable_set(:@prepare, [proposal])
        expect(subject.invalid_lines).to eq([1])
      end
    end
  end

  context "with JSON" do
    let(:file) { File.new Decidim::Dev.asset("import_proposals.json") }
    let(:reader) { Decidim::Admin::Import::Readers::JSON }

    it_behaves_like "proposal importer"
  end

  context "with XLS" do
    let(:file) { File.new Decidim::Dev.asset("import_proposals.xls") }
    let(:reader) { Decidim::Admin::Import::Readers::XLS }

    it_behaves_like "proposal importer"
  end
end
