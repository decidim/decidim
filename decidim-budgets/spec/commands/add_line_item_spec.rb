require "spec_helper"

describe Decidim::Budgets::AddLineItem do
  let(:user) { create(:user) }
  let(:feature) { create(:budget_feature, organization: user.organization) }
  let(:project) { create(:project, feature: feature) }
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

  context "when line item can't be created" do
    let(:project) { nil }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
