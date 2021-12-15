# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::CreateOrderReminders do
  let(:command) { described_class.new(form).call }

  let(:form) do
    instance_double(
      Decidim::Budgets::Admin::OrderReminderForm,
      invalid?: false,
      voting_enabled?: voting_enabled,
      current_component: component,
      minimum_interval_between_reminders: minimum_interval
    )
  end
  let(:voting_enabled) { true }
  let(:minimum_interval) { 24.hours }
  let(:organization) { create(:organization) }
  let(:component) { create(:component, organization: organization, manifest_name: "budgets") }
  let(:budget) { create(:budget, component: component) }

  context "when there is a new order" do
    let!(:new_order) { create(:order, budget: budget, created_at: 10.minutes.ago) }

    it "generates reminder and broadcasts ok with count of reminded people" do
      expect { command }.to change(Decidim::Reminder, :count).by(1).and broadcast(:ok, 0)
    end
  end

  context "when there is a pending order" do
    let!(:order) { create(:order, budget: budget, created_at: 3.days.ago) }

    it "user will be reminded" do
      expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

      expect { command }.to broadcast(:ok, 1)
    end

    context "with reminder" do
      let(:reminder) { create(:reminder, user: order.user, component: component) }

      context "with recent delivery" do
        let!(:reminder_delivery) { create(:reminder_delivery, reminder: reminder) }

        it "user will not be reminded" do
          expect(Decidim::Budgets::SendVoteReminderJob).not_to receive(:perform_later)

          expect { command }.to broadcast(:ok, 0)
        end
      end

      context "with old delivery" do
        let!(:reminder_delivery) { create(:reminder_delivery, reminder: reminder, created_at: 2.days.ago) }

        it "user will be reminded" do
          expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

          expect { command }.to broadcast(:ok, 1)
        end
      end
    end
  end
end
