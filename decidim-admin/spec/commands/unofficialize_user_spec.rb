# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnofficializeUser do
    subject { described_class.new(user, current_user) }

    let(:organization) { create :organization }
    let(:user) { create(:user, :officialized, organization: organization) }
    let(:current_user) { create(:user, organization: organization) }
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

    it "traces the update" do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with("unofficialize", user, current_user, log_info)

      subject.call
    end

    it "unofficializes user" do
      subject.call

      expect(user.reload).not_to be_officialized
    end
  end
end
