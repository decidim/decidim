# frozen_string_literal: true

require "spec_helper"

describe "Manage participatory processes", type: :feature do
  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-core", "spec", "support", image1_filename)
  end
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-core", "spec", "support", image2_filename)
  end
  let(:image3_filename) { "city3.jpeg" }
  let(:image3_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-core", "spec", "support", image3_filename)
  end
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:participatory_process) { create(:process, organization: organization) }

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
      expect(page).to have_content(participatory_process.title["en"])
      expect(page).to have_content(participatory_process.title["es"])
      expect(page).to have_content(participatory_process.title["ca"])
      expect(page).to have_content(participatory_process.subtitle["en"])
      expect(page).to have_content(participatory_process.subtitle["es"])
      expect(page).to have_content(participatory_process.subtitle["ca"])
      expect(page).to have_content(participatory_process.short_description["en"])
      expect(page).to have_content(participatory_process.short_description["es"])
      expect(page).to have_content(participatory_process.short_description["ca"])
      expect(page).to have_content(participatory_process.description["en"])
      expect(page).to have_content(participatory_process.description["es"])
      expect(page).to have_content(participatory_process.description["ca"])
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
    within find("tr", text: participatory_process.title["en"]) do
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
    let!(:participatory_process2) { create(:process, organization: organization) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "deletes a participatory_process" do
      within find("tr", text: participatory_process2.title["en"]) do
        click_link "Destroy"
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(participatory_process2.title)
      end
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_participatory_process) { create(:process) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "doesn't let the admin manage processes form other organizations" do
      within "table" do
        expect(page).to_not have_content(external_participatory_process.title)
      end
    end
  end

  context "when the user is not authorized to perform some actions" do
    let(:policy_double) { double edit?: policy_edit }
    let(:policy_edit) { true }

    before do
      allow(Decidim::Admin::ParticipatoryProcessPolicy)
        .to receive(:new)
        .and_return(policy_double)
    end

    context "it can't edit a record" do
      let(:policy_edit) { false }

      context 'when the user tries to manually access to the edition page' do
        it "is redirected to the root path" do
          visit decidim_admin.edit_participatory_process_path(participatory_process)
          expect(page).to have_content("You are not authorized to perform this action")
          expect(current_path).to eq decidim_admin.root_path
        end
      end
    end
  end
end
