# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
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
      expect(page).to have_link("Version 1")
      expect(page).to have_link("Version 2")
    end

    it "shows the versions count" do
      expect(page).to have_content("VERSIONS\n2")
    end

    it "allows going back to the initiative" do
      click_link "Go back to initiative"
      expect(page).to have_current_path initiative_path, ignore_query: true
    end

    it "shows the creation date" do
      within ".card--list__item:last-child" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end
  end

  context "when showing version" do
    before do
      command.call
      visit initiative_path
      click_link "see other versions"

      within ".card--list__item:last-child" do
        first(:link, "Version 2").click
      end
    end

    it_behaves_like "accessible page"

    it "shows the version number" do
      expect(page).to have_content("VERSION NUMBER\n2 out of 2")
    end

    it "allows going back to the initiative" do
      click_link "Go back to initiative"
      expect(page).to have_current_path initiative_path, ignore_query: true
    end

    it "allows going back to the versions list" do
      click_link "Show all versions"
      expect(page).to have_current_path "#{initiative_path}/versions"
    end

    it "shows the creation date" do
      within ".card.extra.definition-data" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within ".diff-for-title-english" do
        expect(page).to have_content("TITLE")

        within ".diff > ul > .ins" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
        end
      end

      within ".diff-for-description-english" do
        expect(page).to have_content("DESCRIPTION")

        within ".diff > ul > .ins" do
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
        end
      end
    end
  end
end
