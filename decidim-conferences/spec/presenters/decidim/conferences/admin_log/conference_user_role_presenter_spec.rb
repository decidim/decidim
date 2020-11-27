# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::AdminLog::ConferenceUserRolePresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:conference) { create(:conference, organization: organization) }
    let(:admin_log_resource) { create(:conference_user_role, conference: conference, user: user) }
    let(:action) { "delete" }
  end
end
