# frozen_string_literal: true

require "spec_helper"

describe Decidim::InactiveUsersQuery do
  let(:organization) { create(:organization) }
  let(:inactivity_period_days) { 300 }
  let(:initial_warning_period_days) { 30 }
  let(:final_reminder_period_days) { 7 }

  let(:query) { described_class.new(organization, inactivity_period_days, initial_warning_period_days, final_reminder_period_days) }

  let!(:inactive_never_signed_in) { create(:user, organization:, last_sign_in_at: nil, created_at: 400.days.ago, marked_for_deletion_at: nil) }
  let!(:active_never_signed_in) { create(:user, organization:, last_sign_in_at: nil, created_at: 200.days.ago, marked_for_deletion_at: nil) }
  let!(:inactive_just_below_threshold) { create(:user, organization:, last_sign_in_at: 270.days.ago, created_at: 350.days.ago, marked_for_deletion_at: nil) }
  let!(:inactive_recent_sign_in) { create(:user, organization:, last_sign_in_at: 400.days.ago, created_at: 400.days.ago, marked_for_deletion_at: nil) }
  let!(:active_recent_sign_in) { create(:user, organization:, last_sign_in_at: 200.days.ago, created_at: 200.days.ago, marked_for_deletion_at: nil) }
  let!(:user_reminder_due) { create(:user, organization:, marked_for_deletion_at: 23.days.ago, last_sign_in_at: 294.days.ago, created_at: 400.days.ago) }
  let!(:user_ready_for_removal) { create(:user, organization:, marked_for_deletion_at: 40.days.ago, last_sign_in_at: 400.days.ago, created_at: 400.days.ago) }
  let!(:user_logged_in_after_notification) { create(:user, organization:, marked_for_deletion_at: 10.days.ago, last_sign_in_at: 1.day.ago, created_at: 400.days.ago) }

  describe "#users_to_mark_for_deletion" do
    it "finds users who should be marked for deletion" do
      result = query.users_to_mark_for_deletion

      expect(result).to include(inactive_never_signed_in, inactive_recent_sign_in, inactive_just_below_threshold)
      expect(result).not_to include(active_never_signed_in, active_recent_sign_in, user_reminder_due, user_ready_for_removal, user_logged_in_after_notification)
    end
  end

  describe "#users_to_send_reminder" do
    it "finds users due for a reminder notification" do
      result = query.users_to_send_reminder

      expect(result).to include(user_reminder_due)
      expect(result).not_to include(
        inactive_never_signed_in,
        active_never_signed_in,
        inactive_just_below_threshold,
        user_logged_in_after_notification,
        inactive_recent_sign_in
      )
    end
  end

  describe "#users_to_remove" do
    it "finds users who are ready for deletion" do
      result = query.users_to_remove

      expect(result).to include(user_ready_for_removal)
      expect(result).not_to include(
        inactive_never_signed_in,
        user_reminder_due,
        active_never_signed_in,
        inactive_just_below_threshold,
        user_logged_in_after_notification,
        inactive_recent_sign_in
      )
    end
  end

  describe "#users_to_unmark_for_deletion" do
    it "finds users who logged in after being marked for deletion" do
      result = query.users_to_unmark_for_deletion

      expect(result).to include(user_logged_in_after_notification)
      expect(result).not_to include(
        inactive_never_signed_in,
        user_reminder_due,
        user_ready_for_removal,
        inactive_just_below_threshold,
        active_never_signed_in
      )
    end
  end
end
