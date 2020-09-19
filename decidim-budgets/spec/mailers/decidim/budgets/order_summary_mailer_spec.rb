# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe OrderSummaryMailer, type: :mailer do
    let(:order) { create :order, :with_projects }
    let(:user) { order.user }
    let(:space) { order.budget.participatory_space }
    let(:organization) { space.participatory_space.organization }
    let(:budget) { order.budget }

    describe "order_summary" do
      let(:mail) { described_class.order_summary(order) }

      it "delivers the email to the user" do
        expect(mail.to).to eq([user.email])
      end

      it "includes the organization data" do
        expect(mail.body.encoded).to include(user.organization.name)
      end

      it "includes the budget title" do
        expect(mail.body.encoded).to include(translated(budget.title))
      end

      it "includes the participatory space title" do
        expect(mail.body).to include(translated(space.title))
      end

      it "includes the projects names" do
        order.projects.each do |project|
          expect(mail.body).to include(translated(project.title))
        end
      end
    end
  end
end
