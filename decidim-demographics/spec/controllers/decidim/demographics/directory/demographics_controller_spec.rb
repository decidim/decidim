# frozen_string_literal: true

require "spec_helper"

describe Decidim::Demographics::Directory::DemographicsController, type: :controller do
  routes { Decidim::Demographics::DirectoryEngine.routes }

  let(:time_zone) { "UTC" }
  let(:organization) { create(:organization, time_zone: time_zone) }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }

  let(:user) { create :user, :admin, :confirmed, organization: organization }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    request.env["decidim.current_component"] = meeting_component
    sign_in user
  end

  pending
  # new
  # create
end
