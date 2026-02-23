# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExportParticipatorySpaceJob do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:export_manifest) { participatory_process.manifest.export_manifests.find { |m| m.name == :participatory_processes } }

  before do
    # Stub mailer to avoid actually sending emails
    mailer_double = double(deliver_later: true)
    allow(Decidim::ExportMailer).to receive(:export).and_return(mailer_double)
  end

  describe "exporting private processes" do
    let(:private_process) { create(:participatory_process, :private, organization:) }

    it "includes private processes when user is an admin" do
      collection = export_manifest.collection.call(private_process, admin)
      expect(collection).to include(private_process)
    end

    it "excludes private processes when user is nil (open data)" do
      collection = export_manifest.collection.call(private_process, nil)
      expect(collection).not_to include(private_process)
    end
  end

  describe "exporting unpublished processes" do
    let(:unpublished_process) { create(:participatory_process, :unpublished, organization:) }

    it "includes unpublished processes when user is an admin" do
      collection = export_manifest.collection.call(unpublished_process, admin)
      expect(collection).to include(unpublished_process)
    end

    it "excludes unpublished processes when user is nil (open data)" do
      collection = export_manifest.collection.call(unpublished_process, nil)
      expect(collection).not_to include(unpublished_process)
    end
  end
end
