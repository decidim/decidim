# frozen_string_literal: true

require "spec_helper"

describe "Import proposals", type: :system do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }

  let(:manifest_name) { "proposals" }
  let(:participatory_space) { component.participatory_space }
  let(:user) { create :user, organization: organization }

  include_context "when managing a component as an admin"

  before do
    page.find(".imports").click
    click_link "Import from a file"
  end

  describe "import from a file page" do
    it "has start import button" do
      expect(page).to have_content("Import")
    end

    it "returns error without a file" do
      click_button "Import"
      expect(page).to have_content("There was a problem during the import")
    end

    it "doesnt change proposal amount if one imported row fails" do
      attach_file :import_file, Decidim::Dev.asset("import_proposals_broken.csv")
      click_button "Import"
      expect(page).to have_content("Found error in resource number 3")
      expect(Decidim::Proposals::Proposal.count).to eq(0)
    end

    it "creates proposals after succesfully import" do
      attach_file :import_file, Decidim::Dev.asset("import_proposals.csv")
      click_button "Import"
      expect(page).to have_content("3 proposals successfully imported")
      expect(Decidim::Proposals::Proposal.count).to eq(3)
    end
  end

  context "when the user is in user group" do
    let(:user_group) { create :user_group, :confirmed, :verified, organization: organization }
    let!(:membership) { create(:user_group_membership, user: user, user_group: user_group) }

    it "has create import as dropdown" do
      visit current_path
      page.find("#import_user_group_id").click
      expect(page).to have_content(user_group.name)
    end

    it "links proposal to user group during the import" do
      visit current_path
      page.find("#import_user_group_id").click
      select user_group.name, from: "import_user_group_id"
      attach_file :import_file, Decidim::Dev.asset("import_proposals.csv")
      click_button "Import"
      expect(page).to have_content("3 proposals successfully imported")
      expect(Decidim::Proposals::Proposal.last.user_groups.count).to eq(1)
      expect(Decidim::Proposals::Proposal.last.user_groups.first.name).to eq(user_group.name)
    end
  end
end
