# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :system do
  let(:manifest_name) { "proposals" }
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }

  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:moderation) { create :moderation, reportable: proposals.first, hidden_at: 1.day.ago }

  before do
    create :content_block, organization: organization, scope: :homepage, manifest_name: :stats
    switch_to_host(organization.host)
  end

  it "displays unhidden proposals count" do
    visit decidim.root_path

    within(".proposals_count") do
      expect(page).to have_content(2)
    end
  end
end
