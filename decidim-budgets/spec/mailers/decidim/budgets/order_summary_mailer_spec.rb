# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe OrderSummaryMailer do
    let(:order) { create(:order, :with_projects) }
    let(:user) { order.user }
    let(:space) { order.budget.participatory_space }
    let(:organization) { space.organization }
    let(:budget) { order.budget }

    describe "#order_summary" do
      let(:mail) { described_class.order_summary(order) }

      shared_examples "working order summary mail" do
        it "delivers the email to the user" do
          expect(mail.to).to eq([user.email])
        end

        it "includes the organization data" do
          expect(mail.body.encoded).to include(translated(user.organization.name))
        end

        it "includes the budget title" do
          expect(mail.body.encoded).to include(decidim_escape_translated(budget.title))
        end

        it "includes the participatory space title" do
          expect(mail.body).to include(decidim_escape_translated(space.title))
        end

        it "includes the projects names" do
          order.projects.each do |project|
            expect(mail.body).to include(decidim_escape_translated(project.title))
          end
        end
      end

      it_behaves_like "working order summary mail"
    end
  end
end
