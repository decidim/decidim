# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe ImportProjectsMailer, type: :mailer do
      let(:user) { create :user, organization: }
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:mailer) { double :mailer }
      let!(:projects) { create_list(:project, 3, budget:, selected_at: Time.current) }
      let(:projects_id) { projects.ids }
      let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space:) }
      let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
      let(:current_component) { create(:component, manifest_name: "accountability", participatory_space:, published_at: Time.current) }

      context "with a valid user" do
        before do
          allow(Decidim::Accountability::Admin::ImportProjectsJob).to receive(:perform_now).with(user, budget_component, projects.count)
        end

        let(:mail) { described_class.import(user, current_component, projects.count) }

        it "emails success message to the user" do
          expect(mail.body).to include("Successful imported projects to results in the #{current_component.name["en"]} component. You can review the results in the administration interface.")
          expect(mail.body).to include("3 results were imported from projects.")
          expect(mail.body).to include("This email is sent from a notification-only-email and is not intended to receive emails")
        end
      end
    end
  end
end
