# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:mailers:notifications_digest_daily", type: :task do
  let(:organization) { create(:organization) }
  let(:resource) { create(:dummy_resource, organization:) }
  let(:current_time) { Time.utc(2026, 1, 15, 12, 0, 0) }
  let!(:target_user) { create(:user, organization:, notifications_sending_frequency: :daily) }
  let!(:user_with_wrong_frequency) { create(:user, organization:, notifications_sending_frequency: :weekly) }
  let!(:user_without_notifications) { create(:user, organization:, notifications_sending_frequency: :daily) }

  before do
    allow(Time).to receive(:now).and_return(current_time)

    create(:notification, user: target_user, resource:, created_at: current_time - 1.day)
    create(:notification, user: target_user, resource:, created_at: current_time - 1.day + 2.hours)
    create(:notification, user: user_with_wrong_frequency, resource:, created_at: current_time - 1.day)
    create(:notification, user: target_user, resource:, created_at: current_time - 2.days)
  end

  it "enqueues one daily digest job for each matching user" do
    expect { task.execute }
      .to have_enqueued_job(Decidim::EmailNotificationsDigestGeneratorJob).with(target_user.id, :daily, time: current_time)
      .and have_enqueued_job(Decidim::EmailNotificationsDigestGeneratorJob).with(user_with_wrong_frequency.id, :daily, time: current_time).exactly(0).times
      .and have_enqueued_job(Decidim::EmailNotificationsDigestGeneratorJob).with(user_without_notifications.id, :daily, time: current_time).exactly(0).times
  end
end
