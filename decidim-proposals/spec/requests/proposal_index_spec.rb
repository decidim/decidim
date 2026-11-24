# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Proposal index" do
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
    expect(queries.grep(/COUNT\(\*\).*decidim_proposals_proposal_votes/).size).to eq(1)
    expect(queries.grep(/SELECT "decidim_proposals_proposal_votes"\.\* FROM/)).to be_empty
    expect(queries.grep(/decidim_resource_permissions.*resource_id" = \$/)).to be_empty
  end

  context "when the vote threshold is reached but the counter cache is stale" do
    before do
      component[:settings]["global"] = { threshold_per_proposal: 5 }
      component.save!
      proposals.first.update!(proposal_votes_count: 0)
    end

    it "renders the disabled vote limit button" do
      get(request_path, headers: { "HOST" => organization.host })

      html = response.parsed_body
      button = html.css("button[disabled]").find { |node| node.text.include?(I18n.t("decidim.proposals.proposals.vote_button.maximum_votes_reached")) }

      expect(button).to be_present
    end
  end
end
