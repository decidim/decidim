# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
  include_context "with a component"
  let(:component) { create(:proposal_component, organization: organization) }
  let!(:proposal) { create(:proposal, component: component) }
  let!(:emendation) { create(:proposal, component: component) }
  let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }
  let(:command) { Decidim::Amendable::Accept.new(form) }

  let(:form) { Decidim::Amendable::ReviewForm.from_params(form_params) }

  let(:emendation_fields) do
    {
      title: emendation.title,
      body: emendation.body
    }
  end

  let(:form_params) do
    {
      id: amendment.id,
      amendable_gid: proposal.to_sgid.to_s,
      emendation_gid: emendation.to_sgid.to_s,
      emendation_fields: emendation_fields
    }
  end

  let(:proposal_path) do
    Decidim::ResourceLocatorPresenter.new(proposal).path
  end

  context "when visiting a proposal details" do
    before do
      visit proposal_path
    end

    it "has only one version" do
      expect(page).to have_content("VERSION 1 (of 1)")
    end

    it "shows the versions index" do
      expect(page).to have_link "see other versions"
    end

    context "when accepting an amendment" do
      before do
        command.call
        visit proposal_path
      end

      it "creates a new version" do
        expect(page).to have_content("VERSION 2 (of 2)")
      end
    end
  end

  context "when visiting versions index" do
    before do
      visit proposal_path
      command.call
      click_link "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1")
      expect(page).to have_link("Version 2")
    end

    it "shows the versions count" do
      expect(page).to have_content("VERSIONS\n2")
    end

    it "allows going back to the proposal" do
      click_link "Go back to proposal"
      expect(page).to have_current_path proposal_path
    end

    it "shows the creation date" do
      within ".card--list__item:last-child" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end
  end

  context "when showing version" do
    before do
      visit proposal_path
      command.call
      click_link "see other versions"

      within ".card--list__item:last-child" do
        click_link("Version 2")
      end
    end

    it "shows the version number" do
      expect(page).to have_content("VERSION NUMBER\n2 out of 2")
    end

    it "allows going back to the proposal" do
      click_link "Go back to proposal"
      expect(page).to have_current_path proposal_path
    end

    it "allows going back to the versions list" do
      click_link "Show all versions"
      expect(page).to have_current_path proposal_path + "/versions"
    end

    it "shows the creation date" do
      within ".card.extra.definition-data" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")
      expect(page).to have_content("TITLE")
      expect(page).to have_content("BODY")

      first ".diff-string > .removal" do
        expect(page).to have_content(proposal.title)
      end
      first ".diff-string > .addition" do
        expect(page).to have_content(emendation.title)
      end

      all(".diff-string > .removal").last do
        expect(page).to have_content(proposal.body)
      end
      all(".diff-string > .addition").last do
        expect(page).to have_content(emendation.body)
      end
    end
  end
end
