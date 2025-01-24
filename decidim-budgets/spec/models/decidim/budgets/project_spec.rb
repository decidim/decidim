# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Project do
    subject { project }

    let(:project) { create(:project) }

    include_examples "has reference"
    include_examples "resourceable"
    include_examples "has taxonomies"

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }
    it { is_expected.to act_as_paranoid }

    context "without a budget" do
      let(:project) { build(:project, budget: nil) }

      it { is_expected.not_to be_valid }
    end

    context "when the scope is from another organization" do
      let(:scope) { create(:scope) }
      let(:project) { build(:project, scope:) }

      it { is_expected.not_to be_valid }
    end

    describe ".ordered_ids" do
      let(:budget) { create(:budget, total_budget: 1_000_000) }
      let(:projects) { create_list(:project, 50, budget:, budget_amount: 100_000) }
      let(:test_ids) do
        first = described_class.where(budget:).order(:id).pluck(:id)[0..3]
        ids = described_class.where(budget:).pluck(:id).shuffle

        # Put the first items at the end of the IDs array in order to get
        # possibly "conflicting" matches for them at earlier array positions.
        # As we have 50 projects, we should have IDs starting with 1, 2, 3 and 4
        # which is why we put the first 4 items at the end.
        (ids - first) + first
      end

      before do
        # Reset the project IDs to start from 1 in order to get possibly
        # "conflicting" ID sequences for the `.ordered_ids` call. In the past,
        # e.g. IDs such as "2", and "23" (containing "2") would have caused the
        # wrong order in case "23" comes first in the ordered IDs list.
        ActiveRecord::Base.connection.reset_pk_sequence!(described_class.table_name)

        # Create the projects after the sequence has been reset
        projects
      end

      it "returns the correctly ordered projects" do
        expect(described_class.ordered_ids(test_ids).pluck(:id)).to eq(test_ids)
      end
    end

    describe "#orders_count" do
      let(:project) { create(:project, budget_amount: 75_000_000) }
      let(:order) { create(:order, budget: project.budget) }
      let(:unfinished_order) { create(:order, budget: project.budget) }
      let!(:line_item) { create(:line_item, project:, order:) }
      let!(:line_item1) { create(:line_item, project:, order: unfinished_order) }

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

    describe "#selected?" do
      let(:project) { create(:project, selected_at:) }

      context "when selected_at is blank" do
        let(:selected_at) { nil }

        it "returns true" do
          expect(project.selected?).to be false
        end
      end

      context "when selected_at is present" do
        let(:selected_at) { Time.current }

        it "returns true" do
          expect(project.selected?).to be true
        end
      end
    end

    describe "#visible?" do
      subject { project.visible? }

      context "when component is not published" do
        before do
          allow(project.budget.component).to receive(:published?).and_return(false)
        end

        it { is_expected.not_to be_truthy }
      end

      context "when participatory space is visible" do
        before do
          allow(project.budget.component.participatory_space).to receive(:visible?).and_return(false)
        end

        it { is_expected.not_to be_truthy }
      end
    end
  end
end
