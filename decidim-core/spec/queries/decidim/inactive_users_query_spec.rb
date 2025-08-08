# frozen_string_literal: true

require "spec_helper"

describe Decidim::InactiveUsersQuery do
  let(:query) { described_class.new(Decidim::User.not_deleted) }

  let(:organization) { create(:organization) }
  let(:first_warning_inactive_users_after_days) { 270.days.ago }
  let(:last_warning_inactive_users_after_days) { 23.days.ago }
  let(:final_reminder_period_days) { 7.days.ago }
  let!(:inactive_never_signed_in) { create(:user, organization:, current_sign_in_at: nil, created_at: 400.days.ago, extended_data: {}) }
  let!(:active_never_signed_in) { create(:user, organization:, current_sign_in_at: nil, created_at: 200.days.ago, extended_data: {}) }
  let!(:inactive_just_below_threshold) { create(:user, organization:, current_sign_in_at: 270.days.ago, created_at: 350.days.ago, extended_data: {}) }
  let!(:inactive_recent_sign_in) { create(:user, organization:, current_sign_in_at: 400.days.ago, created_at: 400.days.ago, extended_data: {}) }
  let!(:active_recent_sign_in) { create(:user, organization:, current_sign_in_at: 200.days.ago, created_at: 200.days.ago, extended_data: {}) }
  let!(:user_reminder_due) do
    create(:user, organization: organization,
                  current_sign_in_at: 294.days.ago,
                  created_at: 400.days.ago,
                  extended_data: { "inactivity_notification" => { "notification_type" => "first", "sent_at" => 23.days.ago } })
  end

  let!(:user_ready_for_removal) do
    create(:user, organization: organization,
                  current_sign_in_at: 400.days.ago,
                  created_at: 400.days.ago,
                  extended_data: { "inactivity_notification" => { "notification_type" => "second", "sent_at" => 40.days.ago } })
  end

  let!(:user_logged_in_after_notification) do
    create(:user, organization: organization,
                  current_sign_in_at: 1.day.ago,
                  created_at: 400.days.ago,
                  extended_data: { "inactivity_notification" => { "notification_type" => "second", "sent_at" => 7.days.ago } })
  end

  describe "#for_first_warning" do
    it "finds users who should be marked for deletion" do
      result = query.for_first_warning(first_warning_inactive_users_after_days)

      expect(result).to include(inactive_never_signed_in, inactive_recent_sign_in, inactive_just_below_threshold)
      expect(result).not_to include(
        active_never_signed_in,
        active_recent_sign_in,
        user_reminder_due,
        user_ready_for_removal,
        user_logged_in_after_notification
      )
    end
  end

  describe "#for_last_warning" do
    it "finds users due for a reminder notification" do
      result = query.for_last_warning(last_warning_inactive_users_after_days)

      expect(result).to include(user_reminder_due)
      expect(result).not_to include(
        inactive_never_signed_in,
        active_never_signed_in,
        inactive_just_below_threshold,
        user_logged_in_after_notification,
        inactive_recent_sign_in,
        active_recent_sign_in,
        user_ready_for_removal
      )
    end
  end

  describe "#for_removal" do
    it "finds users who are ready for deletion" do
      result = query.for_removal(final_reminder_period_days)

      expect(result).to include(user_ready_for_removal)
      expect(result).not_to include(
        active_recent_sign_in,
        inactive_never_signed_in,
        user_reminder_due,
        active_never_signed_in,
        inactive_just_below_threshold,
        user_logged_in_after_notification,
        inactive_recent_sign_in
      )
    end
  end
end
