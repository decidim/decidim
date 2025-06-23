# frozen_string_literal: true

shared_examples "manage processes examples" do
  context "when viewing the processes list" do
    let!(:process_group) { create(:participatory_process_group, organization:) }
    let!(:process_with_group) { create(:participatory_process, organization:, participatory_process_group: process_group) }
    let!(:process_without_group) { create(:participatory_process, organization:) }
    let(:model_name) { participatory_process.class.model_name }
    let(:resource_controller) { Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController }

    include_context "with filterable context"

    def filter_by_group(group_title)
      visit current_path
      apply_filter("By process group", group_title)
    end

    it "allows the user to filter processes by process_group" do
      filter_by_group(translated(process_group.title))

      expect(page).to have_content(translated(process_with_group.title))
      expect(page).to have_no_content(translated(process_without_group.title))
    end

    describe "listing processes" do
      it_behaves_like "filtering collection by published/unpublished"
      it_behaves_like "filtering collection by private/public"
    end

    context "when processes are filtered by process_group" do
      before { filter_by_group(translated(process_group.title)) }

      describe "listing processes filtered by group" do
        it_behaves_like "filtering collection by published/unpublished" do
          let!(:published_space) { process_with_group }
          let!(:unpublished_space) { create(:participatory_process, :unpublished, organization:, participatory_process_group: process_group) }
        end

        it_behaves_like "filtering collection by private/public" do
          let!(:public_space) { process_with_group }
          let!(:private_space) { create(:participatory_process, :private, organization:, participatory_process_group: process_group) }
        end
      end
    end
  end

  context "when previewing processes" do
    context "when the process is unpublished" do
      let!(:participatory_process) { create(:participatory_process, :unpublished, organization:) }

      it "allows the user to preview the unpublished process" do
        new_window = window_opened_by do
          within("tr", text: translated(participatory_process.title)) do
            find("button[data-component='dropdown']").click
            click_on "Preview"
          end
        end

        page.within_window(new_window) do
          expect(page).to have_css(".participatory-space__container")
          expect(page).to have_content(translated(participatory_process.title))
        end
      end
    end

    context "when the process is published" do
      let!(:participatory_process) { create(:participatory_process, organization:) }

      it "allows the user to preview the published process" do
        new_window = window_opened_by do
          within("tr", text: translated(participatory_process.title)) do
            find("button[data-component='dropdown']").click
            click_on "Preview"
          end
        end

        page.within_window(new_window) do
          expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(participatory_process)
          expect(page).to have_content(translated(participatory_process.title))
        end
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
    let(:attributes) { attributes_for(:participatory_process, organization:) }

    before do
      within "tr", text: translated(participatory_process.title) do
        click_on translated(participatory_process.title)
      end

      within_admin_sidebar_menu do
        click_on "About this process"
      end
    end

    it "updates a participatory_process" do
      fill_in_i18n(:participatory_process_title, "#participatory_process-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n(:participatory_process_subtitle, "#participatory_process-subtitle-tabs", **attributes[:subtitle].except("machine_translations"))
      fill_in_i18n_editor(:participatory_process_short_description, "#participatory_process-short_description-tabs", **attributes[:short_description].except("machine_translations"))
      fill_in_i18n_editor(:participatory_process_description, "#participatory_process-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:participatory_process_announcement, "#participatory_process-announcement-tabs", **attributes[:announcement].except("machine_translations"))
      fill_in_i18n(:participatory_process_developer_group, "#participatory_process-developer_group-tabs", **attributes[:developer_group].except("machine_translations"))
      fill_in_i18n(:participatory_process_local_area, "#participatory_process-local_area-tabs", **attributes[:local_area].except("machine_translations"))
      fill_in_i18n(:participatory_process_meta_scope, "#participatory_process-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
      fill_in_i18n(:participatory_process_target, "#participatory_process-target-tabs", **attributes[:target].except("machine_translations"))
      fill_in_i18n(:participatory_process_participatory_scope, "#participatory_process-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
      fill_in_i18n(:participatory_process_participatory_structure, "#participatory_process-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))

      dynamically_attach_file(:participatory_process_hero_image, image3_path, remove_before: true)

      fill_in_datepicker :participatory_process_end_date_date, with: Time.new.utc.strftime("%d/%m/%Y")

      within ".edit_participatory_process" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "[data-content]" do
        expect(page).to have_css("input[value='#{translated(attributes[:title])}']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} participatory process")
    end
  end

  context "when publishing a process" do
    let!(:participatory_process) { create(:participatory_process, :unpublished, organization:) }

    before do
      within "tr", text: translated(participatory_process.title) do
        click_on translated(participatory_process.title)
      end

      within_admin_sidebar_menu do
        click_on "About this process"
      end
    end

    it "publishes the process" do
      click_on "Publish"
      expect(page).to have_content("successfully published")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)

      participatory_process.reload
      expect(participatory_process).to be_published
    end
  end

  context "when unpublishing a process" do
    let!(:participatory_process) { create(:participatory_process, organization:) }

    before do
      within "tr", text: translated(participatory_process.title) do
        click_on translated(participatory_process.title)
      end

      within_admin_sidebar_menu do
        click_on "About this process"
      end
    end

    it "unpublishes the process" do
      click_on "Unpublish"
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

    it "does not let the admin manage processes form other organizations" do
      within "table" do
        expect(page).to have_no_content(external_participatory_process.title["en"])
      end
    end
  end
end
