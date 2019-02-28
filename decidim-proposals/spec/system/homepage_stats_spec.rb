# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:moderation) { create :moderation, reportable: proposals.first, hidden_at: 1.day.ago }

  before do
    visit decidim.root_path
  end

  it "displays unhidden proposals count" do
    within(".proposals_count") do
      expect(page).to have_content(2)
    end
  end
end
