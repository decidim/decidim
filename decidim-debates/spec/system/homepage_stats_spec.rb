# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let!(:debates) { create_list(:debate, 3, component:) }
  let!(:moderation) { create :moderation, reportable: debates.first, hidden_at: 1.day.ago }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :stats
    visit decidim.root_path
  end

  it "display unhidden debates count" do
    within(".debates_count") do
      expect(page).to have_content(2)
    end
  end
end
