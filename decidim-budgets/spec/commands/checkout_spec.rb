require "spec_helper"

describe Decidim::Budgets::Checkout do
  let(:user) { create(:user) }
  let(:feature) do
    create(:budget_feature,
      :with_total_budget_and_vote_threshold_percent,
      organization: user.organization
    )
  end

  let(:project) { create(:project, feature: feature, budget: 90_000_000) }

  let(:order) do
    order = create(:order, user: user, feature: feature)
    order.projects << project
    order.save!
    order
  end

  let(:current_order) { order }

  subject { described_class.new(current_order, feature) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "sets the checked out at" do
      subject.call
      order.reload
      expect(order.checked_out_at).not_to be_nil
    end
  end

  context "when the order is not present" do
    let(:current_order) { nil }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the order total budget doesn't exceed the threshold" do
    let(:project) { create(:project, feature: feature, budget: 30_000_000) }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
