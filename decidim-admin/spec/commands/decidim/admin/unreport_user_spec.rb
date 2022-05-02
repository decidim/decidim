# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnreportUser do
    let(:reportable) { create(:user, :confirmed) }
    let(:moderation) { create(:user_moderation, user: reportable, report_count: 1) }
    let!(:report) { create(:user_report, moderation: moderation, user: current_user, reason: "spam") }
    let(:current_user) { create :user, organization: reportable.organization }
    let(:command) { described_class.new(reportable, current_user) }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "deletes the moderation" do
        command.call
        expect(reportable.reload.user_moderation).to be_nil
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("unreport", moderation, current_user, extra: { reportable_type: "Decidim::User",
                                                               user_id: reportable.id,
                                                               username: reportable.name })
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
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
