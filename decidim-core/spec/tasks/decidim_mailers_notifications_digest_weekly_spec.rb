# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:mailers:notifications_digest_weekly", type: :task do
  let(:organization) { create(:organization) }
  let(:resource) { create(:dummy_resource, organization:) }
  let(:current_time) { Time.utc(2026, 1, 15, 12, 0, 0) }
  let!(:target_user) { create(:user, organization:, notifications_sending_frequency: :weekly) }
  let!(:user_with_wrong_frequency) { create(:user, organization:, notifications_sending_frequency: :daily) }
  let!(:user_without_notifications) { create(:user, organization:, notifications_sending_frequency: :weekly) }

  before do
    allow(Time).to receive(:now).and_return(current_time)
    allow(Decidim::EmailNotificationsDigestGeneratorJob).to receive(:perform_later)

    create(:notification, user: target_user, resource:, created_at: current_time - 1.week - 1.day)
    create(:notification, user: target_user, resource:, created_at: current_time - 1.week - 4.days)
    create(:notification, user: user_with_wrong_frequency, resource:, created_at: current_time - 1.week - 1.day)
    create(:notification, user: target_user, resource:, created_at: current_time - 2.weeks)
  end

  it "enqueues one weekly digest job for each matching user" do
    task.execute

    expect(Decidim::EmailNotificationsDigestGeneratorJob)
      .to have_received(:perform_later)
      .with(target_user.id, :weekly, time: current_time)
      .once
    expect(Decidim::EmailNotificationsDigestGeneratorJob)
      .not_to have_received(:perform_later)
      .with(user_with_wrong_frequency.id, :weekly, time: current_time)
    expect(Decidim::EmailNotificationsDigestGeneratorJob)
      .not_to have_received(:perform_later)
      .with(user_without_notifications.id, :weekly, time: current_time)
  end
end
