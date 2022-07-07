# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::SendOrderSummaryJob do
  subject { described_class }

  let(:order) { create :order }
  let(:user) { order.user }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end

  describe "when everything is OK" do
    let(:mailer) { double :mailer }

    it "sends an email" do
      allow(Decidim::Budgets::OrderSummaryMailer)
        .to receive(:order_summary)
        .with(order)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_now)

      subject.perform_now(order)
    end
  end

  describe "when no order" do
    let(:order) { nil }

    it "doesn't send the email" do
      expect(Decidim::Budgets::OrderSummaryMailer)
        .not_to receive(:order_summary)

      subject.perform_now(order)
    end
  end

  describe "when no user" do
    it "doesn't send the email" do
      user.destroy
      order.reload

      expect(Decidim::Budgets::OrderSummaryMailer)
        .not_to receive(:order_summary)

      subject.perform_now(order)
    end
  end

  describe "when user as no email" do
    it "doesn't send the email" do
      user.update(email: "")

      expect(Decidim::Budgets::OrderSummaryMailer)
        .not_to receive(:order_summary)

      subject.perform_now(order)
    end
  end
end
