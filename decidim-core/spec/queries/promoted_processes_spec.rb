# frozen_string_literal: true
require "spec_helper"

describe Decidim::PromotedProcesses do
  let!(:organization) { create :organization }
  let!(:promoted_process) { create :participatory_process, :promoted, organization: organization }
  let!(:unpromoted_process) { create :participatory_process, organization: organization }

  subject { described_class.new }

  describe "#query" do
    it "only returns promoted processes" do
      expect(subject.query).to eq [promoted_process]
    end
  end
end
