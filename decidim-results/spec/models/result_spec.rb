# frozen_string_literal: true

require "spec_helper"

describe Decidim::Results::Result do
  let(:result) { build :result }
  subject { result }

  it { is_expected.to be_valid }

  context "without a feature" do
    let(:result) { build :result, feature: nil }

    it { is_expected.not_to be_valid }
  end

  context "without a valid feature" do
    let(:result) { build :result, feature: build(:feature, manifest_name: "proposals") }

    it { is_expected.not_to be_valid }
  end

  context "when the scope is from another organization" do
    let(:scope) { create :scope }
    let(:result) { build :result, scope: scope }

    it { is_expected.not_to be_valid }
  end

  context "when the category is from another organization" do
    let(:category) { create :category }
    let(:result) { build :result, category: category }

    it { is_expected.not_to be_valid }
  end
end
