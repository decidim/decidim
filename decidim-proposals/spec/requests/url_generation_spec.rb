# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Proposal index URL generation" do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.participatory_space.organization }
  let(:request_path) { Decidim::EngineRouter.main_proxy(component).proposals_path }

  before do
    create(:proposal, component:)
  end

  it "does not use the script_name parameter to generate order links" do
    get "#{request_path}?script_name=javascript:alert(1)//", headers: { "HOST" => organization.host }

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to match(/href="\s*javascript:/i)
  end
end
