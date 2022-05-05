# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateUserReport do
    describe "call" do
      let(:current_organization) { create(:organization) }
      let(:component) { create(:component, organization: current_organization) }
      let!(:reported_user) { create(:user, :confirmed, organization: current_organization) }
      let(:reportable) { reported_user }
      let!(:admin) { create(:user, :admin, :confirmed, organization: current_organization) }
      let!(:admin_no_moderation_mail) { create(:user, :admin, :confirmed, organization: current_organization, email_on_moderations: false) }
      let(:user) { create(:user, :confirmed, organization: current_organization) }
      let(:form) { ReportForm.from_params(form_params) }
      let(:form_params) do
        {
          reason: "spam",
          details: "some details about the report"
        }
      end

      let(:command) { described_class.new(form, reportable, user) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create the report" do
          expect { command.call }.not_to change(UserReport, :count)
        end
      end

      describe "when the form is valid" do
        before do
          allow(form).to receive(:invalid?).and_return(false)
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a report" do
          command.call
          last_report = UserReport.last
          expect(last_report.user).to eq(user)
        end

        it "creates a moderation" do
          command.call
          last_moderation = UserModeration.last

          expect(last_moderation.user).to eq(reportable)
          expect(last_moderation.reports.count).to eq(1)
        end

        it "stores the details to the report" do
          command.call
          last_report = UserReport.last
          expect(last_report.details).to eq("some details about the report")
        end

        it "calls the report job in order to send the emails" do
          allow(UserReportJob).to receive(:perform_later).and_call_original
          command.call
          last_report = UserReport.last
          expect(UserReportJob).to have_received(:perform_later).with(admin, last_report)
        end

        context "when having multiple admins" do
          let!(:another_admin) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "calls twice the report job in order to send the emails and ingore the admin_no_moderation_mail" do
            expect(UserReportJob).to receive(:perform_later).twice.with(a_kind_of(Decidim::User), a_kind_of(Decidim::UserReport))

            command.call
          end
        end

        it "doesnt send an email to the admin when he/she doesnt allow it" do
          allow(UserReportJob).to receive(:perform_later).and_call_original
          command.call
          expect(UserReportJob).not_to have_received(:perform_later).with(admin_no_moderation_mail, a_kind_of(Decidim::UserReport))
        end

        context "and the reportable has been already reported two times" do
          before do
            expect(form).to receive(:invalid?).at_least(:once).and_return(false)
            (Decidim.max_reports_before_hiding - 1).times do
              described_class.new(form, reportable, create(:user, organization: current_organization)).call
            end
          end

          it "doesn't create an additional moderation" do
            expect { command.call }.not_to change(UserModeration, :count)

            last_moderation = UserModeration.last
            expect(last_moderation.report_count).to eq(3)
          end
        end
      end
    end
  end
end
