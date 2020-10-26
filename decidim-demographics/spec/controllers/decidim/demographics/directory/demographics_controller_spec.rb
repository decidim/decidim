# frozen_string_literal: true

require "spec_helper"

describe Decidim::Demographics::Directory::DemographicsController, type: :controller do
  routes { Decidim::Demographics::DirectoryEngine.routes }

  let(:time_zone) { "UTC" }
  let(:organization) { create(:organization, time_zone: time_zone) }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  let(:demographic_form ) do
    double(
      gender: "male",
      age: "< 15",
      nationalities: [1,4],
      postal_code: "111222",
      background: "self-employed"
    )
  end

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    sign_in user
  end

  it "tests new action" do
    get :new
    expect(demographic_form).to receive(:from_model)
  end
  # new
  # create
end
