# frozen_string_literal: true

require "spec_helper"

describe Decidim::InactiveUsersQuery do
  let(:organization) { create(:organization) }
  let(:reminder_period) { 7.days }
  let(:inactivity_period) { 300 } # days

  let(:query) { described_class.new(organization, reminder_period, inactivity_period) }

  let!(:inactive_never_signed_in) { create(:user, organization:, last_sign_in_at: nil, created_at: 400.days.ago, removal_date: nil) }
  let!(:active_never_signed_in) { create(:user, organization:, last_sign_in_at: nil, created_at: 200.days.ago, removal_date: nil) }
  let!(:inactive_recent_sign_in) { create(:user, organization:, last_sign_in_at: 400.days.ago, created_at: 400.days.ago, removal_date: nil) }
  let!(:active_recent_sign_in) { create(:user, organization:, last_sign_in_at: 200.days.ago, created_at: 200.days.ago, removal_date: nil) }
  let!(:user_reminder_due) { create(:user, organization:, removal_date: 5.days.from_now, last_inactivity_notice_sent_at: 10.days.ago) }
  let!(:user_ready_for_removal) { create(:user, organization:, removal_date: 1.day.ago) }
  let!(:user_logged_in_after_notification) { create(:user, organization:, removal_date: 10.days.from_now, last_sign_in_at: 1.day.ago) }

  describe "#reset_inactivity_marks" do
    it "finds users who logged in after receiving a removal date" do
      result = query.reset_inactivity_marks

      expect(result).to include(user_logged_in_after_notification)
      expect(result).not_to include(inactive_never_signed_in, user_reminder_due, user_ready_for_removal)
    end
  end

  describe "#inactive_users" do
    it "finds users who are inactive and have no removal date set" do
      result = query.inactive_users

      expect(result).to include(inactive_never_signed_in, inactive_recent_sign_in)
      expect(result).not_to include(active_never_signed_in, active_recent_sign_in, user_reminder_due, user_ready_for_removal)
    end
  end

  describe "#users_for_reminder" do
    it "finds users due for a reminder notification" do
      result = query.users_for_reminder

      expect(result).to include(user_reminder_due)
      expect(result).not_to include(inactive_never_signed_in, active_never_signed_in, user_ready_for_removal)
    end
  end

  describe "#users_for_removal" do
    it "finds users who are ready for deletion" do
      result = query.users_for_removal

      expect(result).to include(user_ready_for_removal)
      expect(result).not_to include(inactive_never_signed_in, user_reminder_due, active_never_signed_in)
    end
  end
end
