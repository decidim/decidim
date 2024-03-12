# frozen_string_literal: true

require "spec_helper"

describe "User is being blocked by admin", type: :system do
  subject { Decidim::Admin::HideResource.new(reportable, current_user) }

  let(:reportable) { create(:dummy_resource) }
  let(:current_user) { create(:user, organization: reportable.participatory_space.organization) }
  let(:moderation) { create(:moderation, reportable:, report_count: 1) }
  let!(:report) { create(:report, moderation:) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "enqueues a training job" do
    expect { subject.call }.to have_enqueued_job(Decidim::Ai::TrainHiddenResourceDataJob).on_queue("spam_analysis").with(reportable)
  end
end
