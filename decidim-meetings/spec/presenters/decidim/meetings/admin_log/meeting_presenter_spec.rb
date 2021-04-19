# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::AdminLog::MeetingPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:component) { create(:meeting_component, participatory_space: participatory_space) }
    let(:admin_log_resource) { create(:meeting, component: component) }
    let(:action) { "close" }
  end
end
