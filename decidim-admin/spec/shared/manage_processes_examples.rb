# coding: utf-8
# frozen_string_literal: true
RSpec.shared_examples "manage processes examples" do
  context "previewing processes" do
    context "when the process is unpublished" do
      let!(:participatory_process) { create(:participatory_process, :unpublished, organization: organization) }

      it "allows the user to preview the unpublished process" do
        within find("tr", text: translated(participatory_process.title)) do
          click_link "Preview"
        end

        expect(page).to have_css(".process-header")
        expect(page).to have_content(translated(participatory_process.title))
      end
    end

    context "when the process is published" do
      let!(:participatory_process) { create(:participatory_process, organization: organization) }

      it "allows the user to preview the unpublished process" do
        within find("tr", text: translated(participatory_process.title)) do
          click_link "Preview"
        end

        expect(current_path).to eq decidim.participatory_process_path(participatory_process)
        expect(page).to have_content(translated(participatory_process.title))
      end
    end
  end

  it "displays all fields from a single participatory process" do
    within "table" do
      click_link participatory_process.title["en"]
    end

    within "dl" do
      expect(page).to have_content(stripped translated(participatory_process.title, locale: :en))
      expect(page).to have_content(stripped translated(participatory_process.title, locale: :es))
      expect(page).to have_content(stripped translated(participatory_process.title, locale: :ca))
      expect(page).to have_content(stripped translated(participatory_process.subtitle, locale: :en))
      expect(page).to have_content(stripped translated(participatory_process.subtitle, locale: :es))
      expect(page).to have_content(stripped translated(participatory_process.subtitle, locale: :ca))
      expect(page).to have_content(stripped translated(participatory_process.short_description, locale: :en))
      expect(page).to have_content(stripped translated(participatory_process.short_description, locale: :es))
      expect(page).to have_content(stripped translated(participatory_process.short_description, locale: :ca))
      expect(page).to have_content(stripped translated(participatory_process.description, locale: :en))
      expect(page).to have_content(stripped translated(participatory_process.description, locale: :es))
      expect(page).to have_content(stripped translated(participatory_process.description, locale: :ca))
      expect(page).to have_content(participatory_process.hashtag)
      expect(page).to have_content(participatory_process.slug)
      expect(page).to have_xpath("//img[@src=\"#{participatory_process.hero_image.url}\"]")
      expect(page).to have_xpath("//img[@src=\"#{participatory_process.banner_image.url}\"]")
    end
  end

  it "updates an participatory_process" do
    click_link translated(participatory_process.title)
    click_processes_menu_link "Settings"

    within ".edit_participatory_process" do
      fill_in_i18n(
        :participatory_process_title,
        "#title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      attach_file :participatory_process_banner_image, image3_path

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new title")
      click_link("My new title")
    end

    within "dl" do
      expect(page).not_to have_css("img[src*='#{image2_filename}']")
      expect(page).to have_css("img[src*='#{image3_filename}']")
    end
  end

  context "publishing a process" do
    let!(:participatory_process) { create(:participatory_process, :unpublished, organization: organization) }

    before do
      click_link translated(participatory_process.title)
      click_processes_menu_link "Settings"
    end

    it "publishes the process" do
      click_link "Publish"
      expect(page).to have_content("published successfully")
      expect(page).to have_content("Unpublish")
      expect(current_path).to eq decidim_admin.edit_participatory_process_path(participatory_process)

      participatory_process.reload
      expect(participatory_process).to be_published
    end
  end

  context "unpublishing a process" do
    let!(:participatory_process) { create(:participatory_process, organization: organization) }

    before do
      click_link translated(participatory_process.title)
      click_processes_menu_link "Settings"
    end

    it "unpublishes the process" do
      click_link "Unpublish"
      expect(page).to have_content("unpublished successfully")
      expect(page).to have_content("Publish")
      expect(current_path).to eq decidim_admin.edit_participatory_process_path(participatory_process)

      participatory_process.reload
      expect(participatory_process).not_to be_published
  end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_participatory_process) { create(:participatory_process) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "doesn't let the admin manage processes form other organizations" do
      within "table" do
        expect(page).not_to have_content(external_participatory_process.title)
      end
    end
  end
end
