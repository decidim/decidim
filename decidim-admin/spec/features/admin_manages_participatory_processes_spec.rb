# frozen_string_literal: true

require "spec_helper"

describe "Admin manage participatory processes", type: :feature do
  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image1_filename)
  end
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image2_filename)
  end
  let(:image3_filename) { "city3.jpeg" }
  let(:image3_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image3_filename)
  end
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.participatory_processes_path
  end

  it "displays all fields from a single participatory process" do
    within "table" do
      click_link participatory_process.title["en"]
    end

    within "dl" do
      expect(page).to have_content(translated(participatory_process.title, locale: :en))
      expect(page).to have_content(translated(participatory_process.title, locale: :es))
      expect(page).to have_content(translated(participatory_process.title, locale: :ca))
      expect(page).to have_content(translated(participatory_process.subtitle, locale: :en))
      expect(page).to have_content(translated(participatory_process.subtitle, locale: :es))
      expect(page).to have_content(translated(participatory_process.subtitle, locale: :ca))
      expect(page).to have_content(translated(participatory_process.short_description, locale: :en))
      expect(page).to have_content(translated(participatory_process.short_description, locale: :es))
      expect(page).to have_content(translated(participatory_process.short_description, locale: :ca))
      expect(page).to have_content(translated(participatory_process.description, locale: :en))
      expect(page).to have_content(translated(participatory_process.description, locale: :es))
      expect(page).to have_content(translated(participatory_process.description, locale: :ca))
      expect(page).to have_content(participatory_process.hashtag)
      expect(page).to have_content(participatory_process.slug)
      expect(page).to have_xpath("//img[@src=\"#{participatory_process.hero_image.url}\"]")
      expect(page).to have_xpath("//img[@src=\"#{participatory_process.banner_image.url}\"]")
    end
  end

  it "creates a new participatory_process" do
    find(".actions .new").click

    within ".new_participatory_process" do
      fill_in :participatory_process_title_en, with: "My participatory process"
      fill_in :participatory_process_title_es, with: "Mi proceso participativo"
      fill_in :participatory_process_title_ca, with: "El meu procés participatiu"
      fill_in :participatory_process_subtitle_en, with: "Subtitle"
      fill_in :participatory_process_subtitle_es, with: "Subtítulo"
      fill_in :participatory_process_subtitle_ca, with: "Subtítol"
      fill_in :participatory_process_slug, with: "slug"
      fill_in :participatory_process_hashtag, with: "#hashtag"
      fill_in :participatory_process_short_description_en, with: "Short description"
      fill_in :participatory_process_short_description_es, with: "Descripción corta"
      fill_in :participatory_process_short_description_ca, with: "Descripció curta"
      fill_in :participatory_process_description_en, with: "A longer description"
      fill_in :participatory_process_description_es, with: "Descripción más larga"
      fill_in :participatory_process_description_ca, with: "Descripció més llarga"
      attach_file :participatory_process_hero_image, image1_path
      attach_file :participatory_process_banner_image, image2_path

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My participatory process")
      click_link("My participatory process")
    end

    within "dl" do
      expect(page).to have_css("img[src*='#{image1_filename}']")
      expect(page).to have_css("img[src*='#{image2_filename}']")
    end
  end

  it "updates an participatory_process" do
    within find("tr", text: translated(participatory_process.title)) do
      click_link "Edit"
    end

    within ".edit_participatory_process" do
      fill_in :participatory_process_title_en, with: "My new title"
      fill_in :participatory_process_title_es, with: "Mi nuevo título"
      fill_in :participatory_process_title_ca, with: "El meu nou títol"
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
      expect(page).to_not have_css("img[src*='#{image2_filename}']")
      expect(page).to have_css("img[src*='#{image3_filename}']")
    end
  end

  context "deleting a participatory process" do
    let!(:participatory_process2) { create(:participatory_process, organization: organization) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "deletes a participatory_process" do
      within find("tr", text: translated(participatory_process2.title)) do
        click_link "Destroy"
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(translated(participatory_process2.title))
      end
    end
  end

  context "publishing a process" do
    let!(:participatory_process) { create(:participatory_process, :unpublished, organization: organization) }

    context "from the index page" do
      it "publishes the process" do
        click_link "Publish"
        expect(page).to have_content("published successfully")
        expect(page).to have_content("Unpublish")
        expect(current_path).to eq decidim_admin.participatory_processes_path

        participatory_process.reload
        expect(participatory_process).to be_published
      end
    end

    context "from the process page" do
      before do
        click_link translated(participatory_process.title)
      end

      it "publishes the process" do
        click_link "Publish"
        expect(page).to have_content("published successfully")
        expect(page).to have_content("Unpublish")
        expect(current_path).to eq decidim_admin.participatory_process_path(participatory_process)

        participatory_process.reload
        expect(participatory_process).to be_published
      end
    end
  end

  context "unpublishing a process" do
    let!(:participatory_process) { create(:participatory_process, organization: organization) }

    context "from the index page" do
      it "unpublishes the process" do
        click_link "Unpublish"
        expect(page).to have_content("unpublished successfully")
        expect(page).to have_content("Publish")
        expect(current_path).to eq decidim_admin.participatory_processes_path

        participatory_process.reload
        expect(participatory_process).not_to be_published
      end
    end

    context "from the process page" do
      before do
        click_link translated(participatory_process.title)
      end

      it "unpublishes the process" do
        click_link "Unpublish"
        expect(page).to have_content("unpublished successfully")
        expect(page).to have_content("Publish")
        expect(current_path).to eq decidim_admin.participatory_process_path(participatory_process)

        participatory_process.reload
        expect(participatory_process).not_to be_published
      end
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_participatory_process) { create(:participatory_process) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "doesn't let the admin manage processes form other organizations" do
      within "table" do
        expect(page).to_not have_content(external_participatory_process.title)
      end
    end
  end
end
