# frozen_string_literal: true

shared_examples "manage processes examples" do
  context "when viewing the processes list" do
    let!(:process_group) { create(:participatory_process_group, organization: organization) }
    let!(:process_with_group) { create(:participatory_process, organization: organization, participatory_process_group: process_group) }
    let!(:process_without_group) { create(:participatory_process, organization: organization) }
    let(:model_name) { participatory_process.class.model_name }
    let(:resource_controller) { Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController }

    def filter_by_group(group_title)
      visit current_path
      within(".card-title") do
        click_button("Process Groups")
        click_link(group_title)
      end
    end

    it "allows the user to filter processes by process_group" do
      filter_by_group(translated(process_group.title))

      expect(page).to have_content(translated(process_with_group.title))
      expect(page).not_to have_content(translated(process_without_group.title))
    end

    describe "listing processes" do
      it_behaves_like "filtering collection by published/unpublished"
      it_behaves_like "filtering collection by private/public"
    end

    context "when processes are filtered by process_group" do
      before { filter_by_group(translated(process_group.title)) }

      it "allows the user to edit the process_group" do
        click_link translated(process_group.title)

        expect(page).to have_content("Edit process group")
      end

      describe "listing processes filtered by group" do
        it_behaves_like "filtering collection by published/unpublished" do
          let!(:published_space) { process_with_group }
          let!(:unpublished_space) { create(:participatory_process, :unpublished, organization: organization, participatory_process_group: process_group) }
        end

        it_behaves_like "filtering collection by private/public" do
          let!(:public_space) { process_with_group }
          let!(:private_space) { create(:participatory_process, :private, organization: organization, participatory_process_group: process_group) }
        end
      end
    end
  end

  context "when previewing processes" do
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

      it "allows the user to preview the published process" do
        within find("tr", text: translated(participatory_process.title)) do
          click_link "Preview"
        end

        expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(participatory_process)
        expect(page).to have_content(translated(participatory_process.title))
      end
    end
  end

  context "when viewing a missing process" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_participatory_processes.participatory_process_path(99_999_999) }
    end
  end

  context "when updating a participatory process" do
    let(:image3_filename) { "city3.jpeg" }
    let(:image3_path) { Decidim::Dev.asset(image3_filename) }

    before do
      within find("tr", text: translated(participatory_process.title)) do
        click_link "Configure"
      end
    end

    it "updates a participatory_process" do
      fill_in_i18n(
        :participatory_process_title,
        "#participatory_process-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      dynamically_attach_file(:participatory_process_banner_image, image3_path, remove_before: true)

      page.execute_script("$('#participatory_process_end_date').focus()")
      page.find(".datepicker-dropdown .day", text: "22").click

      within ".edit_participatory_process" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_selector("input[value='My new title']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end
    end
  end

  context "when publishing a process" do
    let!(:participatory_process) { create(:participatory_process, :unpublished, organization: organization) }

    before do
      within find("tr", text: translated(participatory_process.title)) do
        click_link "Configure"
      end
    end

    it "publishes the process" do
      click_link "Publish"
      expect(page).to have_content("successfully published")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)

      participatory_process.reload
      expect(participatory_process).to be_published
    end
  end

  context "when unpublishing a process" do
    let!(:participatory_process) { create(:participatory_process, organization: organization) }

    before do
      within find("tr", text: translated(participatory_process.title)) do
        click_link "Configure"
      end
    end

    it "unpublishes the process" do
      click_link "Unpublish"
      expect(page).to have_content("successfully unpublished")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)

      participatory_process.reload
      expect(participatory_process).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_participatory_process) { create(:participatory_process) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "doesn't let the admin manage processes form other organizations" do
      within "table" do
        expect(page).to have_no_content(external_participatory_process.title["en"])
      end
    end
  end

  context "when the process has a scope" do
    let(:scope) { create(:scope, organization: organization) }

    before do
      participatory_process.update!(scopes_enabled: true, scope: scope)
    end

    it "disables the scope for a participatory process" do
      within find("tr", text: translated(participatory_process.title)) do
        click_link "Configure"
      end

      uncheck :participatory_process_scopes_enabled

      expect(page).to have_selector("#participatory_process_scope_id.disabled")
      expect(page).to have_selector("#participatory_process_scope_id .picker-values div input[disabled]", visible: :all)

      within ".edit_participatory_process" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
    end
  end
end
