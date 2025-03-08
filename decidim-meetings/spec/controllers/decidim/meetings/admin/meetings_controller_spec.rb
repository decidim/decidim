# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

describe Decidim::Meetings::Admin::MeetingsController do
  let(:meeting) { create(:meeting, component:) }
  let(:current_user) { create(:user, :admin, :confirmed, organization:) }

  let(:time_zone) { "UTC" }
  let(:organization) { create(:organization, time_zone:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:meeting_component, participatory_space: participatory_process) }
  let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:proposal) { create(:proposal, component: proposal_component) }
  let(:meeting_proposals) { meeting.authored_proposals }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    request.env["decidim.current_component"] = component
    sign_in current_user
  end

  it_behaves_like "a soft-deletable resource",
                  resource_name: :meeting,
                  resource_path: :meetings_path,
                  trash_path: :manage_trash_meetings_path
end
