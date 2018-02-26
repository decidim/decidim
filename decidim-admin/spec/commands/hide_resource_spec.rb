# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe HideResource do
    let(:reportable) { create(:dummy_resource) }
    let(:moderation) { create(:moderation, reportable: reportable, report_count: 1) }
    let!(:report) { create(:report, moderation: moderation) }
    let(:current_user) { create :user, organization: reportable.participatory_space.organization }
    let(:command) { described_class.new(reportable, current_user) }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "hides the resource" do
        command.call
        expect(reportable.reload).to be_hidden
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("hide", moderation, current_user)

        command.call
      end
    end

    context "when the resource is already hidden" do
      let(:moderation) { create(:moderation, reportable: reportable, report_count: 1, hidden_at: Time.current) }

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
