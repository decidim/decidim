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

  it_behaves_like "fires an ActiveSupport::Notification event", "decidim.admin.hide_resource:after" do
    let(:command) { subject }
  end
end
