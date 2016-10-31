# frozen_string_literal: true
require "spec_helper"

describe Decidim::PublishedProcesses do
  let!(:organization) { create :organization }
  let!(:external_process) { create :participatory_process }
  let!(:published_process) { create :participatory_process, organization: organization }
  let!(:unpublished_process) { create :participatory_process, :unpublished, organization: organization }

  subject { described_class.new(current_organization) }

  describe "#query" do
    context "when organization is set" do
      let(:current_organization) { organization }

      it "only returns the processes from the given organization" do
        expect(subject.query).to eq [published_process]
      end
    end

    context "when organization is not set" do
      let(:current_organization) { nil }

      it "only returns the processes from the given organization" do
        expect(subject.query).to match_array [published_process, external_process]
      end
    end
  end
end
