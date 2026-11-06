# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLog do
  describe ".lazy_relation" do
    let!(:meetings) { create_list(:meeting, 2, :published) }
    let!(:action_logs) do
      meetings.map do |meeting|
        create(:action_log, action: "publish", visibility: "all", resource: meeting, organization: meeting.organization)
      end
    end

    it "eager loads the moderation and author associations for meetings" do
      resources = action_logs.map(&:resource_lazy)

      expect(resources).to all(be_a(Decidim::Meetings::Meeting))
      resources.each do |meeting|
        expect(meeting.association(:moderation).loaded?).to be(true)
        expect(meeting.association(:author).loaded?).to be(true)
      end
    end
  end
end
