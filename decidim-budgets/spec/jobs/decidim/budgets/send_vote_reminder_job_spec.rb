# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::SendVoteReminderJob do
  subject { described_class }

  let(:organization) { user.organization }
  let(:user) { create(:user, :confirmed) }
  let(:component) { create(:budgets_component, organization:) }
  let(:budget) { create(:budget, component:) }
  let(:reminder) { create(:reminder, user:, component:) }
  let(:mailer) { double :mailer }
  let(:mailer_class) { Decidim::Budgets::VoteReminderMailer }

  context "when everything is OK" do
    let(:order) { create(:order, user:, budget:) }
    let!(:reminder_record) { create(:reminder_record, reminder:, remindable: order) }

    it "sends an email and creates reminder delivery" do
      allow(mailer_class)
        .to receive(:vote_reminder)
        .with(reminder)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_now)

      expect { subject.perform_now(reminder) }.to change(Decidim::ReminderDelivery, :count).to(1)
    end
  end

  context "when no orders" do
    it "doesn't send the email" do
      expect(mailer_class)
        .not_to receive(:vote_reminder)

      subject.perform_now(reminder)
    end
  end
end
