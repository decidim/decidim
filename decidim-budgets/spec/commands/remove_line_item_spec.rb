require "spec_helper"

describe Decidim::Budgets::RemoveLineItem do
  let(:user) { create(:user) }
  let(:feature) { create(:budget_feature, organization: user.organization) }
  let(:project) { create(:project, feature: feature) }
  let(:order) { create(:order, user: user, feature: feature) }
  let(:line_item) { create(:line_item, order: order, project: project) }

  subject { described_class.new(order, project) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "removes a line item from the order" do
      subject.call
      last_order = Decidim::Budgets::Order.last
      expect(last_order.line_items.collect(&:project)).to be_empty
    end
  end

  context "when line item can't be deleted" do
    let(:project) { nil }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
