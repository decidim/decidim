# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Meeting do
  let(:meeting) { build :meeting }
  subject { meeting }

  it { is_expected.to be_valid }

  context "without a title" do
    let(:meeting) { build :meeting, title: nil }

    it { is_expected.not_to be_valid }
  end

  context "when the scope is from another organization" do
    let(:scope) { create :scope }
    let(:meeting) { build :meeting, scope: scope }

    it { is_expected.not_to be_valid }
  end

  context "when the category is from another organization" do
    let(:category) { create :category }
    let(:meeting) { build :meeting, category: category }

    it { is_expected.not_to be_valid }
  end
end
