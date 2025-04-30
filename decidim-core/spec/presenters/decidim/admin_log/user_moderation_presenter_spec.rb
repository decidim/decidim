# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::UserModerationPresenter, type: :helper do
  context "with user" do
    include_examples "present admin log entry" do
      let(:reportable) { create(:user, :blocked, organization:) }
      let(:moderation) { create(:user_moderation, user: reportable) }
      let(:admin_log_resource) { reportable }
      let(:admin_log_extra_data) { { extra: { user_id: reportable.id } } }
      let(:action) { "report" }
    end
  end
end
