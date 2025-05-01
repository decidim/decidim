# frozen_string_literal: true

require "spec_helper"

describe "Homepage" do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let!(:debates) { create_list(:debate, 3, component:) }
  let!(:moderation) { create(:moderation, reportable: debates.first, hidden_at: 1.day.ago) }

  before do
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :stats)
    visit decidim.root_path
  end

  it "does not display debates stat" do
    expect(page).to have_no_content("Debates")
  end
end
