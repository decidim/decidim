# frozen_string_literal: true

shared_examples "manage conferences" do
  describe "updating a conference" do
    let(:image3_filename) { "city3.jpeg" }
    let(:image3_path) { Decidim::Dev.asset(image3_filename) }

    before do
      click_link translated(conference.title)
    end

    it "updates a conference" do
      fill_in_i18n(
        :conference_title,
        "#conference-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      attach_file :conference_banner_image, image3_path

      within ".edit_conference" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_selector("input[value='My new title']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end
    end
  end

  describe "updating an conference without images" do
    before do
      click_link translated(conference.title)
    end

    it "update an conference without images does not delete them" do
      click_submenu_link "Info"
      click_button "Update"

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_css("img[src*='#{conference.hero_image.url}']")
      expect(page).to have_css("img[src*='#{conference.banner_image.url}']")
    end
  end

  describe "previewing conferences" do
    context "when the conference is unpublished" do
      let!(:conference) { create(:conference, :unpublished, organization: organization) }

      it "allows the user to preview the unpublished conference" do
        within find("tr", text: translated(conference.title)) do
          click_link "Preview"
        end

        expect(page).to have_css(".process-header")
        expect(page).to have_content(translated(conference.title))
      end
    end

    context "when the conference is published" do
      let!(:conference) { create(:conference, organization: organization) }

      it "allows the user to preview the unpublished conference" do
        within find("tr", text: translated(conference.title)) do
          click_link "Preview"
        end

        expect(page).to have_current_path decidim_conferences.conference_path(conference)
        expect(page).to have_content(translated(conference.title))
      end
    end
  end

  describe "viewing a missing conference" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_conferences.conference_path(99_999_999) }
    end
  end

  describe "publishing a conference" do
    let!(:conference) { create(:conference, :unpublished, organization: organization) }

    before do
      click_link translated(conference.title)
    end

    it "publishes the conference" do
      click_link "Publish"
      expect(page).to have_content("published successfully")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_conferences.edit_conference_path(conference)

      conference.reload
      expect(conference).to be_published
    end
  end

  describe "unpublishing a conference" do
    let!(:conference) { create(:conference, organization: organization) }

    before do
      click_link translated(conference.title)
    end

    it "unpublishes the conference" do
      click_link "Unpublish"
      expect(page).to have_content("unpublished successfully")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_conferences.edit_conference_path(conference)

      conference.reload
      expect(conference).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_conference) { create(:conference) }

    it "doesn't let the admin manage conferences form other organizations" do
      within "table" do
        expect(page).not_to have_content(external_conference.title["en"])
      end
    end
  end

  context "when the conference has a scope" do
    let(:scope) { create(:scope, organization: organization) }

    before do
      conference.update!(scopes_enabled: true, scope: scope)
    end

    it "disables the scope for the conference" do
      click_link translated(conference.title)

      uncheck :conference_scopes_enabled

      expect(page).to have_selector("#conference_scope_id.disabled")
      expect(page).to have_selector("#conference_scope_id .picker-values div input[disabled]", visible: false)

      within ".edit_conference" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
    end
  end
end
