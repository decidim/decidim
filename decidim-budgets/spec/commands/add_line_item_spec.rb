require "spec_helper"

describe Decidim::Budgets::AddLineItem do
  let(:user) { create(:user) }
  let(:participatory_process) { create :participatory_process, :with_steps, organization: user.organization }
  let(:feature) { create(:budget_feature, participatory_process: participatory_process, settings: settings) }
  let(:project) { create(:project, feature: feature, budget: 60_000) }
  let(:settings) { { "total_budget" => 100_000, vote_threshold_percent: 50 }}
  let(:order) { nil }

  subject { described_class.new(order, project, user) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    context "when a order for the current user does exist" do
      let!(:order) { create(:order, user: user, feature: feature) }

      it "doesn't create a new order" do
        expect {
          subject.call
        }.not_to change { Decidim::Budgets::Order.count }
      end
    end

    context "when a order for the current user doesn't exist" do
      it "creates an order" do
        expect {
          subject.call
        }.to change { Decidim::Budgets::Order.count }.by(1)
      end
    end

    it "adds a line item to the order" do
      subject.call
      last_order = Decidim::Budgets::Order.last
      expect(last_order.line_items.collect(&:project)).to eq([project])
    end
  end

  context "when the order is checked out" do
    let(:projects) do
      build_list(:project, 2, budget: 30_000, feature: feature)
    end

    let!(:order) do
      order = create(:order,
                    user: user,
                    feature: feature)
      order.projects << projects
      order.checked_out_at = Time.current
      order.save!
      order
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the votes are not enabled" do
    let(:feature) { create(:budget_feature, :with_votes_disabled, participatory_process: participatory_process, settings: settings) }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
