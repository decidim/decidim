# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe HideResource do
    let(:reportable) { create(:dummy_resource) }
    let(:moderation) { create(:moderation, reportable:, report_count: 1) }
    let!(:report) { create(:report, moderation:) }
    let(:current_user) { create(:user, organization: reportable.participatory_space.organization) }
    let(:command) { described_class.new(reportable, current_user) }
    let(:author_notification) do
      {
        event: "decidim.events.reports.resource_hidden",
        event_class: Decidim::ResourceHiddenEvent,
        resource: reportable,
        extra: {
          force_email: true,
          report_reasons: [report.reason]
        },
        force_send: true,
        affected_users: reportable.try(:authors) || [reportable.try(:author)]
      }
    end

    context "when everything is ok" do
      let(:arguments) { { resource: reportable } }
      let(:fired_event) { "decidim.admin.hide_resource" }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "hides the resource" do
        command.call
        expect(reportable.reload).to be_hidden
      end

      it_behaves_like "fires an ActiveSupport::Notification event", "decidim.admin.hide_resource:before"
      it_behaves_like "fires an ActiveSupport::Notification event", "decidim.admin.hide_resource:after"

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("hide", moderation, current_user, extra: { reportable_type: "Decidim::Dev::DummyResource" })
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      it "sends a notification to the reportable's author" do
        expect(Decidim::EventsManager).to receive(:publish).with(author_notification)
        command.call
      end
    end

    context "when the resource is already hidden" do
      let(:moderation) { create(:moderation, reportable:, report_count: 1, hidden_at: Time.current) }

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when the resource is not reported" do
      let(:moderation) { nil }
      let!(:report) { nil }

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end
  end
end
