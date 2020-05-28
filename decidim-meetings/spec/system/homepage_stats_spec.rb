# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meetings) { create_list(:meeting, 3, component: component, organizer: component.organization) }
  let!(:moderation) { create :moderation, reportable: meetings.first, hidden_at: 1.day.ago }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :stats
    visit decidim.root_path
  end

  it "display unhidden meeting count" do
    within(".meetings_count") do
      expect(page).to have_content(2)
    end
  end
end
