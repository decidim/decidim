# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :system do
  let(:manifest_name) { "debates" }
  let(:component) { create(:debates_component) }
  let(:organization) { component.organization }

  let!(:debates) { create_list(:debate, 3, component: component) }
  let!(:moderation) { create :moderation, reportable: debates.first, hidden_at: 1.day.ago }

  before do
    create :content_block, organization: organization, scope: :homepage, manifest_name: :stats
    switch_to_host(organization.host)
  end

  it "display unhidden debates count" do
    visit decidim.root_path

    within(".debates_count") do
      expect(page).to have_content(2)
    end
  end
end
