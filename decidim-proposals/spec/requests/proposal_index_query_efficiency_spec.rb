# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Proposal index query efficiency" do
  let(:component) { create(:proposal_component, :with_votes_enabled, :with_threshold_per_proposal, threshold_per_proposal: 100) }
  let(:organization) { component.participatory_space.organization }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:proposals) { create_list(:proposal, 5, :with_votes, component:) }
  let(:request_path) { Decidim::EngineRouter.main_proxy(component).proposals_path }

  before do
    login_as user, scope: :user
    proposals.each { |proposal| proposal.create_resource_permission(permissions: {}) }
  end

  it "does not query the votes or the resource permissions for each proposal" do
    queries = []
    callback = lambda do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] unless payload[:cached] || payload[:name] == "SCHEMA"
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      get(request_path, headers: { "HOST" => organization.host })
    end

    expect(response).to have_http_status(:ok)
    expect(queries.grep(/COUNT\(\*\).*decidim_proposals_proposal_votes/)).to be_empty
    expect(queries.grep(/SELECT "decidim_proposals_proposal_votes"\.\* FROM/)).to be_empty
    expect(queries.grep(/decidim_resource_permissions.*resource_id" = \$/)).to be_empty
  end
end
