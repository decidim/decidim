# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnofficializeUser do
    subject { described_class.new(user, current_user) }

    let(:organization) { create :organization }
    let(:user) { create(:user, :officialized, organization:) }
    let(:current_user) { create(:user, organization:) }
    let(:log_info) do
      hash_including(
        extra: {
          officialized_user_badge: nil,
          officialized_user_badge_previous: kind_of(Hash),
          officialized_user_at: nil,
          officialized_user_at_previous: kind_of(ActiveSupport::TimeWithZone)
        }
      )
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "traces the update", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with("unofficialize", user, current_user, log_info)
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.extra["version"]).to be_nil
      expect(action_log.extra)
        .to include(
          "extra" => {
            "officialized_user_badge_previous" => hash_including("en", "ca", "machine_translations"),
            "officialized_user_badge" => nil,
            "officialized_user_at_previous" => a_kind_of(String),
            "officialized_user_at" => nil
          }
        )
    end

    it "unofficializes user" do
      subject.call

      expect(user.reload).not_to be_officialized
    end
  end
end
