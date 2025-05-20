# frozen_string_literal: true

require "spec_helper"

describe "Import proposals" do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }

  let(:manifest_name) { "proposals" }
  let(:participatory_space) { component.participatory_space }
  let(:user) { create(:user, organization:) }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:proposal_component, participatory_space:) }
  end

  before do
    find("a", text: "Import").click
    click_on "Import proposals from a file"
  end

  describe "import from a file page" do
    it "has start import button" do
      expect(page).to have_content("Import")
    end

    it "returns error without a file" do
      click_on "Import"
      expect(page).to have_content("There is an error in this field")
    end

    it "does not change proposal amount if one imported row fails" do
      dynamically_attach_file(:import_file, Decidim::Dev.asset("import_proposals_broken.csv"))

      click_on "Import"
      expect(page).to have_content("Found an error in the import file on line 4")
      expect(Decidim::Proposals::Proposal.count).to eq(0)
    end

    it "creates proposals after successfully import" do
      dynamically_attach_file(:import_file, Decidim::Dev.asset("import_proposals.csv"))
      click_on "Import"
      expect(page).to have_content("3 proposals successfully imported")
      expect(Decidim::Proposals::Proposal.count).to eq(3)
    end
  end
end
