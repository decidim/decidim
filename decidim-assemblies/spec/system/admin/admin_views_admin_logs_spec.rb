# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  include_context "when admin administrating an assembly"

  describe "Assembly members" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.edit_assembly_path(assembly)
      within_admin_sidebar_menu do
        click_on "Members"
      end
    end

    let(:attributes) { attributes_for(:assembly_member, assembly:) }
    let!(:assembly_member) { create(:assembly_member, assembly:) }

    it "creates a new assembly member", versioning: true do
      click_on "New assembly member"

      fill_in_datepicker :assembly_member_designation_date_date, with: Time.current.strftime("%d/%m/%Y")

      within ".new_assembly_member" do
        fill_in(:assembly_member_full_name, with: attributes[:full_name])
        fill_in(:assembly_member_gender, with: attributes[:gender])
        fill_in(:assembly_member_birthplace, with: attributes[:birthplace])
      end

      dynamically_attach_file(:assembly_member_non_user_avatar, Decidim::Dev.asset("avatar.jpg")) do
        expect(page).to have_content("You should get the consent of the persons before publishing them as a member")
      end

      within ".new_assembly_member" do
        select "President", from: :assembly_member_position

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates an assembly member", versioning: true do
      visit current_path

      within "#assembly_members tr", text: assembly_member.full_name do
        click_on "Edit"
      end

      within ".edit_assembly_member" do
        fill_in(:assembly_member_full_name, with: attributes[:full_name])
        fill_in(:assembly_member_gender, with: attributes[:gender])
        fill_in(:assembly_member_birthplace, with: attributes[:birthplace])

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Assembly" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    let!(:assembly) { create(:assembly, :with_content_blocks, organization:, blocks_manifests: [:announcement]) }

    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }

    let(:attributes) { attributes_for(:assembly, :with_content_blocks, organization:, blocks_manifests: [:announcement]) }

    it "creates a new assembly", versioning: true do
      click_on "New assembly"
      within ".new_assembly" do
        fill_in_i18n(:assembly_title, "#assembly-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:assembly_subtitle, "#assembly-subtitle-tabs", **attributes[:subtitle].except("machine_translations"))
        fill_in_i18n_editor(:assembly_short_description, "#assembly-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_description, "#assembly-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_purpose_of_action, "#assembly-purpose_of_action-tabs", **attributes[:purpose_of_action].except("machine_translations"))
        fill_in_i18n_editor(:assembly_composition, "#assembly-composition-tabs", **attributes[:composition].except("machine_translations"))
        fill_in_i18n_editor(:assembly_internal_organisation, "#assembly-internal_organisation-tabs", **attributes[:internal_organisation].except("machine_translations"))
        fill_in_i18n_editor(:assembly_announcement, "#assembly-announcement-tabs", **attributes[:announcement].except("machine_translations"))
        fill_in_i18n_editor(:assembly_closing_date_reason, "#assembly-closing_date_reason-tabs", **attributes[:closing_date_reason].except("machine_translations"))

        fill_in_i18n(:assembly_participatory_scope, "#assembly-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
        fill_in_i18n(:assembly_participatory_structure, "#assembly-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))
        fill_in_i18n(:assembly_meta_scope, "#assembly-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
        fill_in_i18n(:assembly_local_area, "#assembly-local_area-tabs", **attributes[:local_area].except("machine_translations"))
        fill_in_i18n(:assembly_target, "#assembly-target-tabs", **attributes[:target].except("machine_translations"))

        fill_in :assembly_slug, with: "slug"
        fill_in :assembly_hashtag, with: "#hashtag"
        fill_in :assembly_weight, with: 1
      end

      dynamically_attach_file(:assembly_hero_image, image1_path)
      dynamically_attach_file(:assembly_banner_image, image2_path)

      within ".new_assembly" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a new assembly", versioning: true do
      within "tr", text: translated(assembly.title) do
        click_on "Configure"
      end

      within ".edit_assembly" do
        fill_in_i18n(:assembly_title, "#assembly-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:assembly_subtitle, "#assembly-subtitle-tabs", **attributes[:subtitle].except("machine_translations"))
        fill_in_i18n_editor(:assembly_short_description, "#assembly-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_description, "#assembly-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_purpose_of_action, "#assembly-purpose_of_action-tabs", **attributes[:purpose_of_action].except("machine_translations"))
        fill_in_i18n_editor(:assembly_composition, "#assembly-composition-tabs", **attributes[:composition].except("machine_translations"))
        fill_in_i18n_editor(:assembly_internal_organisation, "#assembly-internal_organisation-tabs", **attributes[:internal_organisation].except("machine_translations"))
        fill_in_i18n_editor(:assembly_announcement, "#assembly-announcement-tabs", **attributes[:announcement].except("machine_translations"))
        fill_in_i18n_editor(:assembly_closing_date_reason, "#assembly-closing_date_reason-tabs", **attributes[:closing_date_reason].except("machine_translations"))

        fill_in_i18n(:assembly_participatory_scope, "#assembly-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
        fill_in_i18n(:assembly_participatory_structure, "#assembly-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))
        fill_in_i18n(:assembly_meta_scope, "#assembly-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
        fill_in_i18n(:assembly_local_area, "#assembly-local_area-tabs", **attributes[:local_area].except("machine_translations"))
        fill_in_i18n(:assembly_target, "#assembly-target-tabs", **attributes[:target].except("machine_translations"))

        fill_in :assembly_slug, with: "slug"
        fill_in :assembly_hashtag, with: "#hashtag"
        fill_in :assembly_weight, with: 1
      end

      dynamically_attach_file(:assembly_hero_image, image1_path)
      dynamically_attach_file(:assembly_banner_image, image2_path)

      within ".edit_assembly" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
      expect(page).to have_content("aaa")
    end
  end

  describe "Assembly admin" do
    let(:attributes) { attributes_for(:user, organization:) }
    let(:other_user) { create(:user, organization:, email: "my_email@example.org") }

    let!(:assembly_admin) do
      create(:assembly_admin,
             :confirmed,
             organization:,
             assembly:)
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.edit_assembly_path(assembly)
      within_admin_sidebar_menu do
        click_on "Assembly admins"
      end
    end

    it "creates a new assembly admin", versioning: true do
      click_on "New assembly admin"

      within ".new_assembly_user_role" do
        fill_in :assembly_user_role_email, with: other_user.email
        fill_in :assembly_user_role_name, with: attributes[:name]
        select "Administrator", from: :assembly_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates an assembly admin", versioning: true do
      create(:assembly_user_role, assembly:, user: other_user)
      visit current_path
      within "#assembly_admins" do
        within "#assembly_admins tr", text: other_user.email do
          click_on "Edit"
        end
      end

      within ".edit_assembly_user_roles" do
        select "Collaborator", from: :assembly_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Assembly type" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_types_path
    end

    let!(:assembly_type) { create(:assemblies_type, organization:) }
    let(:attributes) { attributes_for(:assemblies_type) }

    it "can create new assemblies types", versioning: true do
      click_on "New assembly type", match: :first

      within ".new_assembly_type" do
        fill_in_i18n(:assemblies_type_title, "#assemblies_type-title-tabs", **attributes[:title].except("machine_translations"))
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "can edit them", versioning: true do
      visit current_path
      within "tr", text: translated(assembly_type.title) do
        click_on "Edit"
      end

      within ".edit_assembly_type" do
        fill_in_i18n :assemblies_type_title, "#assemblies_type-title-tabs", **attributes[:title].except("machine_translations")

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
