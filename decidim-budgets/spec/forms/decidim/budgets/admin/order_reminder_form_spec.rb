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
  let(:participatory_space) { create(:participatory_process, organization: organization) }
  let(:component) { create(:component, participatory_space: participatory_space, manifest_name: "budgets") }
  let(:budget) { create(:budget, component: component) }

  context "when voting is ending today" do
    let!(:step1) do
      create(:participatory_process_step,
             active: true,
             end_date: Time.zone.now.to_date,
             participatory_process: participatory_space)
    end
    let!(:step2) do
      create(:participatory_process_step,
             active: false,
             end_date: 1.month.from_now.to_date,
             participatory_process: participatory_space)
    end

    before do
      participatory_space.reload
      participatory_space.steps.reload
    end

    context "and there are 5 hours left in the day" do
      before { allow(Time.zone).to receive(:now).and_return(Time.zone.now.end_of_day - 5.hours) }

      it "voting_ends_soon? returns true" do
        expect(subject.voting_ends_soon?).to be(true)
      end
    end

    context "and there are 10 hours left in the day" do
      before { allow(Time.zone).to receive(:now).and_return(Time.zone.now.end_of_day - 10.hours) }

      it "voting_ends_soon? returns false" do
        expect(subject.voting_ends_soon?).to be(false)
      end
    end
  end

  context "when participatory spac doesnt have steps" do
    let(:participatory_space) { create(:assembly) }

    context "and there are 2 hours left in the day" do
      before { allow(Time.zone).to receive(:now).and_return(Time.zone.now.end_of_day - 2.hours) }

      it "we dont know that ending is ending soon" do
        expect(subject.voting_ends_soon?).to be(false)
      end
    end
  end

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
