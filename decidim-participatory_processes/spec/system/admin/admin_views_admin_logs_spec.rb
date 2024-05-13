# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  include_context "when admin administrating a participatory process"

  describe "Participatory Process Types" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_process_types_path
    end

    let!(:participatory_process_type) { create(:participatory_process_type, organization:) }
    let(:attributes) { attributes_for(:participatory_process_type, organization:) }

    it "can create new participatory process types", versioning: true do
      click_on "New process type"

      within ".new_participatory_process_type" do
        fill_in_i18n(:participatory_process_type_title, "#participatory_process_type-title-tabs", **attributes[:title].except("machine_translations"))
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a participatory process type", versioning: true do
      visit current_path

      within "tr", text: translated(participatory_process_type.title) do
        click_on "Edit"
      end

      within ".edit_participatory_process_type" do
        fill_in_i18n(:participatory_process_type_title, "#participatory_process_type-title-tabs", **attributes[:title].except("machine_translations"))
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Participatory Process User Roles" do
    let(:participatory_process) { create(:participatory_process, organization:) }

    let(:attributes) { attributes_for(:user, organization:) }
    let(:other_user) { create(:user, organization:, email: "my_email@example.org") }

    let!(:process_admin) do
      create(:process_admin,
             :confirmed,
             organization:,
             participatory_process:)
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
      within_admin_sidebar_menu do
        click_on "Process admins"
      end
    end

    it "creates a new process admin", versioning: true do
      click_on "New process admin"

      within ".new_participatory_process_user_role" do
        fill_in :participatory_process_user_role_email, with: other_user.email
        fill_in :participatory_process_user_role_name, with: attributes[:name]
        select "Administrator", from: :participatory_process_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates an assembly admin", versioning: true do
      create(:participatory_process_user_role, participatory_process:, user: other_user)
      visit current_path
      within "#process_admins" do
        within "#process_admins tr", text: other_user.email do
          click_on "Edit"
        end
      end

      within ".edit_participatory_process_user_roles" do
        select "Administrator", from: :participatory_process_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Participatory Process Group" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:participatory_process_group) { create(:participatory_process_group, organization:) }
    let(:attributes) { attributes_for(:participatory_process_group, organization:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_process_groups_path
    end

    it "creates a new participatory process group", versioning: true do
      within "div.process-title" do
        click_on "New process group"
      end

      within ".new_participatory_process_group" do
        fill_in_i18n(
          :participatory_process_group_title,
          "#participatory_process_group-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n_editor(
          :participatory_process_group_description,
          "#participatory_process_group-description-tabs",
          **attributes[:description].except("machine_translations")
        )
        fill_in :participatory_process_group_hashtag, with: "hashtag"
        fill_in :participatory_process_group_group_url, with: "http://example.org"
        fill_in_i18n(
          :participatory_process_group_developer_group,
          "#participatory_process_group-developer_group-tabs",
          **attributes[:developer_group].except("machine_translations")
        )
        select translated(participatory_process.title), from: :participatory_process_group_participatory_process_ids
      end

      within ".new_participatory_process_group" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "can edit them", versioning: true do
      visit current_path
      within "tr", text: translated(participatory_process_group.title) do
        click_on "Edit"
      end

      within ".edit_participatory_process_group" do
        fill_in_i18n(:participatory_process_group_title, "#participatory_process_group-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:participatory_process_group_description, "#participatory_process_group-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in :participatory_process_group_hashtag, with: "new_hashtag"
        fill_in :participatory_process_group_group_url, with: "http://new-example.org"
        fill_in_i18n(:participatory_process_group_developer_group, "#participatory_process_group-developer_group-tabs", **attributes[:developer_group].except("machine_translations"))
        select translated(participatory_process.title), from: :participatory_process_group_participatory_process_ids
      end

      within ".edit_participatory_process_group" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Participatory Process" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let(:attributes) { attributes_for(:participatory_process, organization:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "creates a new participatory process", versioning: true do
      click_on "New process"

      within ".new_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n(
          :participatory_process_subtitle,
          "#participatory_process-subtitle-tabs",
          **attributes[:subtitle].except("machine_translations")
        )
        fill_in_i18n_editor(
          :participatory_process_short_description,
          "#participatory_process-short_description-tabs",
          **attributes[:short_description].except("machine_translations")
        )
        fill_in_i18n_editor(
          :participatory_process_description,
          "#participatory_process-description-tabs",
          **attributes[:description].except("machine_translations")
        )
        fill_in_i18n_editor(
          :participatory_process_announcement,
          "#participatory_process-announcement-tabs",
          **attributes[:announcement].except("machine_translations")
        )
        fill_in_i18n(:participatory_process_developer_group, "#participatory_process-developer_group-tabs", **attributes[:developer_group].except("machine_translations"))
        fill_in_i18n(:participatory_process_local_area, "#participatory_process-local_area-tabs", **attributes[:local_area].except("machine_translations"))
        fill_in_i18n(:participatory_process_meta_scope, "#participatory_process-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
        fill_in_i18n(:participatory_process_target, "#participatory_process-target-tabs", **attributes[:target].except("machine_translations"))
        fill_in_i18n(:participatory_process_participatory_scope, "#participatory_process-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
        fill_in_i18n(:participatory_process_participatory_structure, "#participatory_process-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))

        fill_in :participatory_process_slug, with: "slug"
        fill_in :participatory_process_hashtag, with: "#hashtag"
        fill_in :participatory_process_weight, with: 1
      end

      within ".new_participatory_process" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a participatory_process", versioning: true do
      within "tr", text: translated(participatory_process.title) do
        click_on translated(participatory_process.title)
      end

      within_admin_sidebar_menu do
        click_on "About this process"
      end

      fill_in_i18n(
        :participatory_process_title,
        "#participatory_process-title-tabs",
        **attributes[:title].except("machine_translations")
      )
      fill_in_i18n(
        :participatory_process_subtitle,
        "#participatory_process-subtitle-tabs",
        **attributes[:subtitle].except("machine_translations")
      )
      fill_in_i18n_editor(
        :participatory_process_short_description,
        "#participatory_process-short_description-tabs",
        **attributes[:short_description].except("machine_translations")
      )
      fill_in_i18n_editor(
        :participatory_process_description,
        "#participatory_process-description-tabs",
        **attributes[:description].except("machine_translations")
      )
      fill_in_i18n_editor(
        :participatory_process_announcement,
        "#participatory_process-announcement-tabs",
        **attributes[:announcement].except("machine_translations")
      )
      fill_in_i18n(:participatory_process_developer_group, "#participatory_process-developer_group-tabs", **attributes[:developer_group].except("machine_translations"))
      fill_in_i18n(:participatory_process_local_area, "#participatory_process-local_area-tabs", **attributes[:local_area].except("machine_translations"))
      fill_in_i18n(:participatory_process_meta_scope, "#participatory_process-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
      fill_in_i18n(:participatory_process_target, "#participatory_process-target-tabs", **attributes[:target].except("machine_translations"))
      fill_in_i18n(:participatory_process_participatory_scope, "#participatory_process-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
      fill_in_i18n(:participatory_process_participatory_structure, "#participatory_process-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))

      fill_in_datepicker :participatory_process_end_date_date, with: Time.new.utc.strftime("%d/%m/%Y")

      within ".edit_participatory_process" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Process steps" do
    let(:attributes) { attributes_for(:participatory_process_step, participatory_process:) }
    let!(:process_step) { create(:participatory_process_step, participatory_process:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
      within_admin_sidebar_menu do
        click_on "Phases"
      end
    end

    it "creates a new participatory_process", versioning: true do
      click_on "New phase"

      fill_in_i18n(
        :participatory_process_step_title,
        "#participatory_process_step-title-tabs",
        **attributes[:title].except("machine_translations")
      )
      fill_in_i18n_editor(
        :participatory_process_step_description,
        "#participatory_process_step-description-tabs",
        **attributes[:description].except("machine_translations")
      )
      fill_in_i18n(:participatory_process_step_cta_text, "#participatory_process_step-cta_text-tabs", **attributes[:cta_text].except("machine_translations"))

      find_by_id("participatory_process_step_start_date_date").click

      fill_in_datepicker :participatory_process_step_start_date_date, with: Time.new.utc.strftime("%d/%m/%Y")
      fill_in_timepicker :participatory_process_step_start_date_time, with: Time.new.utc.strftime("%H:%M")
      fill_in_datepicker :participatory_process_step_end_date_date, with: (Time.new.utc + 2.days).strftime("%d/%m/%Y")
      fill_in_timepicker :participatory_process_step_end_date_time, with: (Time.new.utc + 4.hours).strftime("%H:%M")

      within ".new_participatory_process_step" do
        click_on "Create"
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a participatory_process_step", versioning: true do
      within "#steps" do
        within "tr", text: translated(process_step.title) do
          click_on "Edit"
        end
      end

      within ".edit_participatory_process_step" do
        fill_in_i18n(
          :participatory_process_step_title,
          "#participatory_process_step-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n_editor(
          :participatory_process_step_description,
          "#participatory_process_step-description-tabs",
          **attributes[:description].except("machine_translations")
        )
        fill_in_i18n(:participatory_process_step_cta_text, "#participatory_process_step-cta_text-tabs", **attributes[:cta_text].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
