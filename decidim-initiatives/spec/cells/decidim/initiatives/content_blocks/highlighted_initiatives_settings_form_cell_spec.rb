# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::ContentBlocks::HighlightedInitiativesSettingsFormCell, type: :cell do
  let(:cell) { described_class.new }

  describe "#max_results_label" do
    subject { cell.max_results_label }

    it { is_expected.to eq("Maximum amount of elements to show") }
  end

  describe "#order_label" do
    subject { cell.order_label }

    it { is_expected.to eq("Order element by:") }
  end

  describe "#order_select" do
    subject { cell.order_select }

    it { is_expected.to eq([["Default (Least recent)", "default"], ["Most recent", "most_recent"]]) }
  end
end
