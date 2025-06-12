# frozen_string_literal: true

shared_examples "manage conferences" do
  describe "creating a conference" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }
    let(:attributes) { attributes_for(:conference) }
    let(:last_conference) { Decidim::Conference.last }

    before do
      click_on "New conference"
    end

    %w(description short_description objectives).each do |field|
      it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='conference-#{field}-tabs']", "full"
    end
    it_behaves_like "having a rich text editor for field", "#conference_registrations_terms", "content"
    it_behaves_like "having no taxonomy filters defined"

    it "creates a new conference", versioning: true do
      within ".new_conference" do
        fill_in_i18n(:conference_title, "#conference-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:conference_slogan, "#conference-slogan-tabs", **attributes[:slogan].except("machine_translations"))
        fill_in_i18n_editor(:conference_short_description, "#conference-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:conference_description, "#conference-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:conference_objectives, "#conference-objectives-tabs", **attributes[:objectives].except("machine_translations"))

        select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")

        fill_in :conference_weight, with: 1
        fill_in :conference_slug, with: "slug"
      end

      dynamically_attach_file(:conference_hero_image, image1_path)
      dynamically_attach_file(:conference_banner_image, image2_path)

      within ".new_conference" do
        fill_in_datepicker :conference_start_date_date, with: 1.month.ago.strftime("%d/%m/%Y")
        fill_in_datepicker :conference_end_date_date, with: (1.month.ago + 3.days).strftime("%d/%m/%Y")

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(last_conference.taxonomies).to contain_exactly(taxonomy)

      within "[data-content]" do
        expect(page).to have_current_path decidim_admin_conferences.conferences_path
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} conference")
    end
  end

  describe "updating a conference" do
    let(:image3_filename) { "city3.jpeg" }
    let(:image3_path) { Decidim::Dev.asset(image3_filename) }
    let(:attributes) { attributes_for(:conference) }

    before do
      within "tr", text: translated(conference.title) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    it "updates a conference", versioning: true do
      dynamically_attach_file(:conference_banner_image, image3_path, remove_before: true)

      within ".edit_conference" do
        fill_in_i18n(:conference_title, "#conference-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:conference_slogan, "#conference-slogan-tabs", **attributes[:slogan].except("machine_translations"))
        fill_in_i18n_editor(:conference_short_description, "#conference-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:conference_description, "#conference-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:conference_objectives, "#conference-objectives-tabs", **attributes[:objectives].except("machine_translations"))
        select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_select("taxonomies-#{taxonomy_filter.id}", selected: decidim_sanitize_translated(taxonomy.name))
      expect(page).to have_select("taxonomies-#{another_taxonomy_filter.id}", selected: "Please select an option")
      expect(conference.reload.taxonomies).to contain_exactly(taxonomy)

      within "[data-content]" do
        expect(page).to have_css("input[value='#{translated(attributes[:title])}']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} conference")
    end
  end

  describe "updating a conference without images" do
    before do
      within "tr", text: translated(conference.title) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    %w(description short_description objectives).each do |field|
      it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='conference-#{field}-tabs']", "full"
    end
    it_behaves_like "having a rich text editor for field", "#conference_registrations_terms", "content"

    it "update an conference without images does not delete them" do
      within_admin_sidebar_menu do
        click_on "About this conference"
      end
      click_on "Update"

      expect(page).to have_admin_callout("successfully")

      hero_blob = conference.hero_image.blob
      within %([data-active-uploads] [data-filename="#{hero_blob.filename}"]) do
        src = page.find("img")["src"]
        expect(src).to be_blob_url(hero_blob)
      end

      banner_blob = conference.banner_image.blob
      within %([data-active-uploads] [data-filename="#{banner_blob.filename}"]) do
        src = page.find("img")["src"]
        expect(src).to be_blob_url(banner_blob)
      end
    end
  end

  describe "previewing conferences" do
    context "when the conference is unpublished" do
      let!(:conference) { create(:conference, :unpublished, organization:) }

      it "allows the user to preview the unpublished conference" do
        within "tr", text: translated(conference.title) do
          find("button[data-component='dropdown']").click
          click_on "Preview"
        end

        expect(page).to have_content(translated(conference.title))
      end
    end

    context "when the conference is published" do
      let!(:conference) { create(:conference, organization:) }

      it "allows the user to preview the unpublished conference" do
        new_window = window_opened_by do
          within "tr", text: translated(conference.title) do
            find("button[data-component='dropdown']").click
            click_on "Preview"
          end
        end

        page.within_window(new_window) do
          expect(page).to have_current_path decidim_conferences.conference_path(conference)
          expect(page).to have_content(translated(conference.title))
        end
      end
    end
  end

  describe "viewing a missing conference" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_conferences.conference_path(99_999_999) }
    end
  end

  describe "publishing a conference" do
    let!(:conference) { create(:conference, :unpublished, organization:) }

    before do
      within "tr", text: translated(conference.title) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    it "publishes the conference" do
      click_on "Publish"
      expect(page).to have_content("successfully published")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_conferences.edit_conference_path(conference)

      conference.reload
      expect(conference).to be_published
    end
  end

  describe "unpublishing a conference" do
    let!(:conference) { create(:conference, organization:) }

    before do
      within "tr", text: translated(conference.title) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    it "unpublishes the conference" do
      click_on "Unpublish"
      expect(page).to have_content("successfully unpublished")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_conferences.edit_conference_path(conference)

      conference.reload
      expect(conference).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_conference) { create(:conference) }

    it "does not let the admin manage conferences form other organizations" do
      within "table" do
        expect(page).to have_no_content(external_conference.title["en"])
      end
    end
  end
end
