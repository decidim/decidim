# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Project do
  let(:project) { create :project }
  subject { project }

  include_examples "has reference"

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

  context "#orders_count" do
    let(:project) { create :project, budget: 75_000_000 }
    let(:order) { create :order, feature: project.feature }
    let(:unfinished_order) { create :order, feature: project.feature }
    let!(:line_item) { create :line_item, project: project, order: order }
    let!(:line_item_1) { create :line_item, project: project, order: unfinished_order }

    it "return number of finished orders for this project" do
      order.reload.update_attributes!(checked_out_at: Time.current)
      expect(project.confirmed_orders_count).to eq(1)
    end
  end
end
