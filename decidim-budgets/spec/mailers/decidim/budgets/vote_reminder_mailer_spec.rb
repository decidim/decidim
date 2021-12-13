# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe VoteReminderMailer, type: :mailer do
    let(:mail) { described_class.vote_reminder(reminder) }
    let(:router) { Decidim::EngineRouter.main_proxy(order.component) }
    let(:user) { order.user }
    let(:order) { create(:order) }
    let(:reminder) { create(:reminder, component: order.component, user: order.user) }
    let!(:reminder_record) { create(:reminder_record, reminder: reminder, remindable: order) }

    describe "#vote_reminder" do
      it "delivers the email to the user" do
        expect(mail.to).to eq(Array(user.email))
      end

      it "sets a subject" do
        expect(mail.subject).to eq("You have an unfinished vote in the participatory budgeting vote")
      end

      it "includes link to the budget" do
        expect(mail).to have_link(order.budget.title["en"], href: router.budget_path(order.budget))
      end

      it "includes link to the component" do
        expect(mail).to have_link("Go to continue voting", href: router.root_path)
      end
    end
  end
end
