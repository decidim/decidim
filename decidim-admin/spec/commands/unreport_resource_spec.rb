# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnreportResource do
    let(:reportable) { create(:dummy_resource) }
    let(:moderation) { create(:moderation, reportable: reportable, report_count: 1) }
    let!(:report) { create(:report, moderation: moderation) }
    let(:command) { described_class.new(reportable) }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "resets the report count" do
        command.call
        expect(reportable.reload.moderation.report_count).to eq(0)
      end

      context "when the resource is hidden" do
        let(:moderation) { create(:moderation, reportable: reportable, report_count: 1, hidden_at: Time.current) }

        it "unhides the resource" do
          command.call
          expect(reportable.reload).not_to be_hidden
        end
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
