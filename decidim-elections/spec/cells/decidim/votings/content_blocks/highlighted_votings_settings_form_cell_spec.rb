# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::ContentBlocks::HighlightedVotingsSettingsFormCell, type: :cell do
  let(:cell) { described_class.new }

  describe "#content_block" do
    subject { cell.content_block }

    it { is_expected.to be_nil }
  end

  describe "#label" do
    subject { cell.label }

    it { is_expected.to eq("Maximum amount of elements to show") }
  end
end
