# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateReport do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:component) { create(:component, organization:) }
      let(:reportable) { create(:dummy_resource, component:) }
      let!(:admin) { create(:user, :admin, :confirmed, organization:) }
      let!(:admin_no_moderation_mail) { create(:user, :admin, :confirmed, organization:, email_on_moderations: false) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:form) { ReportForm.from_params(form_params) }
      let(:form_params) do
        {
          reason: "spam"
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
          expect { command.call }.not_to change(Report, :count)
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
          last_report = Report.last
          expect(last_report.user).to eq(user)
        end

        it "creates a moderation" do
          command.call
          last_moderation = Moderation.last

          expect(last_moderation.reportable).to eq(reportable)
        end

        it "updates the moderation to include the reported content" do
          command.call
          last_moderation = Moderation.last

          expect(last_moderation.reported_content).to eq(reportable.reported_searchable_content_text)
        end

        it "stores the current locale to the report" do
          I18n.with_locale :ca do
            command.call
            last_report = Report.last
            expect(last_report.locale).to eq("ca")
          end
        end

        it "sends an email to the admin" do
          allow(ReportedMailer).to receive(:report).and_call_original
          command.call
          last_report = Report.last
          expect(ReportedMailer)
            .to have_received(:report)
            .with(admin, last_report)
        end

        it "doesnt send an email to the admin when he/she doesnt allow it" do
          allow(ReportedMailer).to receive(:report).and_call_original
          command.call
          last_report = Report.last
          expect(ReportedMailer)
            .not_to have_received(:report)
            .with(admin_no_moderation_mail, last_report)
        end

        context "and the reportable has been already reported two times" do
          before do
            expect(form).to receive(:invalid?).at_least(:once).and_return(false)
            (Decidim.max_reports_before_hiding - 1).times do
              described_class.new(form, reportable, create(:user, organization:)).call
            end
          end

          it "doesn't create an additional moderation" do
            expect { command.call }.not_to change(Moderation, :count)

            last_moderation = Moderation.last
            expect(last_moderation.report_count).to eq(3)
          end

          it "marks the reportable as hidden" do
            command.call
            expect(reportable.reload).to be_hidden
          end

          it "sends an email to the admin" do
            allow(ReportedMailer).to receive(:hide).and_call_original
            command.call
            last_report = Report.last
            expect(ReportedMailer)
              .to have_received(:hide)
              .with(admin, last_report)
          end
        end
      end
    end
  end
end
