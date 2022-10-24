# frozen_string_literal: true

require "spec_helper"

describe "Import proposals", type: :system do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }

  let(:manifest_name) { "proposals" }
  let(:participatory_space) { component.participatory_space }
  let(:user) { create :user, organization: }

  include_context "when managing a component as an admin"

  before do
    page.find(".imports").click
    click_link "Import proposals from a file"
  end

  describe "import from a file page" do
    it "has start import button" do
      expect(page).to have_content("Import")
    end

    it "returns error without a file" do
      click_button "Import"
      expect(page).to have_content("There's an error in this field")
    end

    it "doesnt change proposal amount if one imported row fails" do
      dynamically_attach_file(:proposals_file_import_file, Decidim::Dev.asset("import_proposals_broken.csv"))

      click_button "Import"
      expect(page).to have_content("Found an error in the import file on line 4")
      expect(Decidim::Proposals::Proposal.count).to eq(0)
    end

    it "creates proposals after succesfully import" do
      dynamically_attach_file(:proposals_file_import_file, Decidim::Dev.asset("import_proposals.csv"))
      click_button "Import"
      expect(page).to have_content("3 proposals successfully imported")
      expect(Decidim::Proposals::Proposal.count).to eq(3)
    end
  end

  context "when the user is in user group" do
    let(:user_group) { create :user_group, :confirmed, :verified, organization: }
    let!(:membership) { create(:user_group_membership, user:, user_group:) }

    before do
      visit "#{current_path}?name=proposals"
    end

    it "has create import as dropdown" do
      page.find("#proposals_file_import_user_group_id").click
      expect(page).to have_content(user_group.name)
    end

    it "links proposal to user group during the import" do
      page.find("#proposals_file_import_user_group_id").click
      select user_group.name, from: "proposals_file_import_user_group_id"
      dynamically_attach_file(:proposals_file_import_file, Decidim::Dev.asset("import_proposals.csv"))
      click_button "Import"
      expect(page).to have_content("3 proposals successfully imported")
      expect(Decidim::Proposals::Proposal.last.user_groups.count).to eq(1)
      expect(Decidim::Proposals::Proposal.last.user_groups.first.name).to eq(user_group.name)
    end
  end
end
