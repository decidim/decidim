# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Import::Importer do
  subject { described_class.new(file, reader, context: context, parser: parser) }

  let(:parser) { Decidim::Proposals::ProposalParser }

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
