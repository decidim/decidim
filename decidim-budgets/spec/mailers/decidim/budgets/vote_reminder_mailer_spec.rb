# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe VoteReminderMailer, type: :mailer do
    let(:mail) { described_class.vote_reminder(reminder) }
    let(:router) { Decidim::EngineRouter.main_proxy(component) }
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }
    let(:component) { create(:budgets_component, organization: organization) }
    let(:budget) { create(:budget, component: component) }
    let(:order) { create(:order, budget: budget, user: user) }

    context "when reminder and reminder record exists" do
      let(:reminder) { create(:reminder, component: component, user: user) }
      let!(:reminder_record) { create(:reminder_record, reminder: reminder, remindable: order) }

      describe "#vote_reminder" do
        it "delivers the email to the user" do
          expect(mail.to).to eq(Array(user.email))
        end

        it "sets a subject" do
          expect(mail.subject).to eq("You have an unfinished vote in the participatory budgeting vote")
        end

        it "includes link to the budget" do
          expect(mail).to have_link(budget.title["en"], href: router.budget_path(budget))
        end

        it "includes link to the component" do
          expect(mail).to have_link("Go to continue voting", href: router.root_path)
        end
      end
    end

    context "when reminder with multiple reminder records exists" do
      let(:reminder) { create(:reminder, component: component, user: user) }
      let!(:reminder_record) { create(:reminder_record, reminder: reminder, remindable: order) }
      let!(:reminder_record2) { create(:reminder_record, reminder: reminder, remindable: order2) }
      let!(:reminder_record3) { create(:reminder_record, reminder: reminder, remindable: order3) }
      let(:budgets) { create_list(:budget, 2, component: component) }
      let(:order2) { create(:order, budget: budgets.first, user: user) }
      let(:order3) { create(:order, budget: budgets.last, user: user) }

      it "includes links to the budgets" do
        expect(mail).to have_link(budget.title["en"], href: router.budget_path(budget))
        expect(mail).to have_link(budgets[0].title["en"], href: router.budget_path(budgets[0]))
        expect(mail).to have_link(budgets[1].title["en"], href: router.budget_path(budgets[1]))
      end
    end
  end
end
