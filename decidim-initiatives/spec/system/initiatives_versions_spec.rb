# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", type: :system, versioning: true do
  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization:) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  let(:form) do
    Decidim::Initiatives::Admin::InitiativeForm.from_params(
      title: { en: "A reasonable initiative title" },
      description: { en: "A reasonable initiative description" },
      signature_start_date: initiative.signature_start_date,
      signature_end_date: initiative.signature_end_date
    ).with_context(
      current_organization: organization,
      current_component: nil,
      initiative:
    )
  end
  let(:command) { Decidim::Initiatives::Admin::UpdateInitiative.new(initiative, form, user) }
  let(:initiative_path) { decidim_initiatives.initiative_path(initiative) }

  before do
    switch_to_host(organization.host)
  end

  context "when visiting an initiative details" do
    it "has only one version" do
      visit initiative_path

      expect(page).to have_content("Version number 1 (of 1)")
    end

    it "shows the versions index" do
      visit initiative_path

      expect(page).to have_link "see other versions"
    end

    context "when updating an initiative" do
      before do
        command.call
      end

      it "creates a new version" do
        visit initiative_path

        expect(page).to have_content("Version number 2 (of 2)")
      end
    end
  end

  context "when visiting versions index" do
    before do
      command.call
      visit initiative_path
      click_link "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 2 of 2")
      expect(page).to have_link("Version 1 of 2")
    end
  end

  context "when showing version" do
    before do
      command.call
      visit initiative_path
      click_link "see other versions"
      click_link("Version 2 of 2")
    end

    # REDESIGN_PENDING: The accessibility should be tested after complete redesign
    # it_behaves_like "accessible page"

    it "allows going back to the versions list" do
      skip "REDESIGN_PENDING: Once redesigned this page will contain a call to the versions_list cell with links to each one"

      click_link "Show all versions"
      expect(page).to have_current_path "#{initiative_path}/versions"
    end

    it "shows the creation date" do
      within ".version__author" do
        skip_unless_redesign_enabled("This test pass using redesigned author cell")

        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within "#diff-for-title-english" do
        expect(page).to have_content("Title")

        within ".diff > ul > .ins" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
        end
      end

      within "#diff-for-description-english" do
        expect(page).to have_content("Description")

        within ".diff > ul > .ins" do
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        end
      end
    end
  end
end
