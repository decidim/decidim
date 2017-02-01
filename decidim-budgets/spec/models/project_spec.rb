# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Project do
  let(:project) { build :project }
  subject { project }

  it { is_expected.to be_valid }

  context "without a feature" do
    let(:project) { build :project, feature: nil }

    it { is_expected.not_to be_valid }
  end

  context "when the scope is from another organization" do
    let(:scope) { create :scope }
    let(:project) { build :project, scope: scope }

    it { is_expected.not_to be_valid }
  end

  context "when the category is from another organization" do
    let(:category) { create :category }
    let(:project) { build :project, category: category }

    it { is_expected.not_to be_valid }
  end
end
