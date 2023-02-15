# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
  include_context "with a component"
  let(:component) { create(:proposal_component, organization:) }
  let!(:proposal) { create(:proposal, body: { en: "One liner body" }, component:, skip_injection: true) }
  let!(:emendation) { create(:proposal, body: { en: "Amended One liner body" }, component:, skip_injection: true) }
  let!(:amendment) { create :amendment, amendable: proposal, emendation: }

  let(:form) do
    Decidim::Amendable::ReviewForm.from_params(
      id: amendment.id,
      amendable_gid: proposal.to_sgid.to_s,
      emendation_gid: emendation.to_sgid.to_s,
      emendation_params: { title: emendation.title, body: emendation.body }
    )
  end
  let(:command) { Decidim::Amendable::Accept.new(form) }

  let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

  context "when visiting a proposal details" do
    before do
      visit proposal_path
    end

    it "has only one version" do
      expect(page).to have_content("Version number 1 (of 1)")
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
        expect(page).to have_content("Version number 2 (of 2)")
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
      expect(page).to have_link("Version 1 of 2")
      expect(page).to have_link("Version 2 of 2")
    end
  end

  context "when showing version" do
    before do
      visit proposal_path
      command.call
      click_link "see other versions"
      click_link("Version 2 of 2")
    end

    # REDESIGN_PENDING: The accessibility should be tested after complete redesign
    # it_behaves_like "accessible page"

    it "allows going back to the proposal" do
      click_link "Go back to proposal"
      expect(page).to have_current_path proposal_path
    end

    it "allows going back to the versions list" do
      skip "REDESIGN_PENDING: Once redesigned this page will contain a call to the versions_list cell with links to each one"

      click_link "Show all versions"
      expect(page).to have_current_path "#{proposal_path}/versions"
    end

    it "shows the creation date" do
      skip_unless_redesign_enabled("this test pass using redesigned version_author cell")

      within ".version__author" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within "#diff-for-title" do
        expect(page).to have_content("Title")

        within ".diff > ul > .del" do
          expect(page).to have_content(translated(proposal.title))
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content(translated(emendation.title))
        end
      end

      within "#diff-for-body" do
        expect(page).to have_content("Body")

        within ".diff > ul > .del" do
          expect(page).to have_content(translated(proposal.body))
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content(translated(emendation.body))
        end
      end
    end
  end
end
