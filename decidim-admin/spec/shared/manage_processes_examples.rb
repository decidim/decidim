# coding: utf-8
# frozen_string_literal: true
RSpec.shared_examples "manage processes examples" do
  context "previewing processes" do
    context "when the process is unpublished" do
      let!(:participatory_process) { create(:participatory_process, :unpublished, organization: organization) }

      it "allows the user to preview the unpublished process" do
        within find("tr", text: translated(participatory_process.title)) do
          page.find('a.action-icon--preview').click
        end

        expect(page).to have_css(".process-header")
        expect(page).to have_content(translated(participatory_process.title))
      end
    end

    context "when the process is published" do
      let!(:participatory_process) { create(:participatory_process, organization: organization) }

      it "allows the user to preview the unpublished process" do
        within find("tr", text: translated(participatory_process.title)) do
          page.find('a.action-icon--preview').click
        end

        expect(current_path).to eq decidim.participatory_process_path(participatory_process)
        expect(page).to have_content(translated(participatory_process.title))
      end
    end
  end

  it "updates an participatory_process" do
    click_link translated(participatory_process.title)

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

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within ".container" do
      expect(page).to have_content("My new title")
      expect(page).not_to have_css("img[src*='#{image2_filename}']")
      expect(page).to have_css("img[src*='#{image3_filename}']")
    end
  end

  context "publishing a process" do
    let!(:participatory_process) { create(:participatory_process, :unpublished, organization: organization) }

    before do
      click_link translated(participatory_process.title)
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
