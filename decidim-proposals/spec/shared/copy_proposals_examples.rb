# frozen_string_literal: true

shared_examples "copy proposals" do
  let!(:proposals) { create_list :proposal, 3, :accepted, feature: origin_feature }
  let!(:rejected_proposals) { create_list :proposal, 3, :rejected, feature: origin_feature }
  let!(:origin_feature) { create :proposal_feature, participatory_space: current_feature.participatory_space }
  include Decidim::FeaturePathHelper

  it "copies proposals from one component to another" do
    click_link "Import from another component"

    within ".copy_proposals" do
      select origin_feature.name["en"], from: :proposals_copy_origin_feature_id
      check "Accepted"
      check :proposals_copy_copy_proposals
    end

    click_button "Import proposals"

    expect(page).to have_content("3 proposals successfully imported")

    proposals.each do |proposal|
      expect(page).to have_content(proposal.title["en"])
    end

    expect(page).to have_current_path(manage_feature_path(current_feature))
  end
end
