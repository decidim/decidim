# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::OrderReminderForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:attributes) { {} }
  let(:context) do
    {
      current_organization: organization,
      current_component: component
    }
  end
  let(:organization) { create(:organization) }
  let(:component) { create(:component, organization: organization, manifest_name: "budgets") }
  let(:budget) { create(:budget, component: component) }

  describe "#reminder_amount" do
    context "when there is new order" do
      let!(:new_order) { create(:order, budget: budget, created_at: 10.minutes.ago) }

      it "does not count it" do
        expect(subject.reminder_amount).to eq(0)
      end
    end

    context "when there is a pending order" do
      let!(:order) { create(:order, budget: budget, created_at: 3.days.ago) }

      it "counts that user will be reminded" do
        expect(subject.reminder_amount).to eq(1)
      end

      context "with reminder" do
        let(:reminder) { create(:reminder, user: order.user, component: component) }

        context "with recent delivery" do
          let!(:reminder_delivery) { create(:reminder_delivery, reminder: reminder) }

          it "calculates that the user will not be reminded" do
            expect(subject.reminder_amount).to eq(0)
          end
        end

        context "with old delivery" do
          let!(:reminder_delivery) { create(:reminder_delivery, reminder: reminder, created_at: 2.days.ago) }

          it "calculates that the user will be reminded" do
            expect(subject.reminder_amount).to eq(1)
          end
        end
      end
    end

    context "when there are multiple pending orders and one new order" do
      let(:pending_order_amount) { rand(2..7) }
      let!(:orders) { create_list(:order, pending_order_amount, budget: budget, created_at: 2.days.ago) }
      let!(:new_order) { create(:order, budget: budget, created_at: 10.minutes.ago) }

      it "counts pending order" do
        expect(subject.reminder_amount).to eq(pending_order_amount)
      end
    end
  end
end
