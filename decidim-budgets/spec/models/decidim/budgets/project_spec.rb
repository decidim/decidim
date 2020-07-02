# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Project do
    subject { project }

    let(:project) { create :project }

    include_examples "has reference"
    include_examples "resourceable"

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    context "without a budget" do
      let(:project) { build :project, budget: nil }

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

    describe "#orders_count" do
      let(:project) { create :project, budget_amount: 75_000_000 }
      let(:order) { create :order, component: project.component }
      let(:unfinished_order) { create :order, component: project.component }
      let!(:line_item) { create :line_item, project: project, order: order }
      let!(:line_item_1) { create :line_item, project: project, order: unfinished_order }

      it "return number of finished orders for this project" do
        order.reload.update!(checked_out_at: Time.current)
        expect(project.confirmed_orders_count).to eq(1)
      end
    end

    describe "#users_to_notify_on_comment_created" do
      let!(:follows) { create_list(:follow, 3, followable: subject) }

      it "returns the followers" do
        expect(subject.users_to_notify_on_comment_created).to match_array(follows.map(&:user))
      end
    end
  end
end
