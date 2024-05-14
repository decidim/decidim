# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  include_context "when admin administrating a conference"

  describe "Speaker" do
    let(:attributes) { attributes_for(:conference_speaker, conference:) }
    let!(:conference_speaker) { create(:conference_speaker, conference:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_conferences.edit_conference_path(conference)
      within_admin_sidebar_menu do
        click_on "Speakers"
      end
    end

    it "creates a new conference speaker", versioning: true do
      click_on "New speaker"

      within ".new_conference_speaker" do
        fill_in(:conference_speaker_full_name, with: attributes[:full_name])
        fill_in_i18n(
          :conference_speaker_position,
          "#conference_speaker-position-tabs",
          **attributes[:position].except("machine_translations")
        )
        fill_in_i18n(
          :conference_speaker_affiliation,
          "#conference_speaker-affiliation-tabs",
          **attributes[:affiliation].except("machine_translations")
        )

        fill_in_i18n_editor(
          :conference_speaker_short_bio,
          "#conference_speaker-short_bio-tabs",
          **attributes[:short_bio].except("machine_translations")
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a conference speaker", versioning: true do
      visit current_path

      within "#conference_speakers tr", text: conference_speaker.full_name do
        click_on "Edit"
      end

      within ".edit_conference_speaker" do
        fill_in(:conference_speaker_full_name, with: attributes[:full_name])
        fill_in_i18n(
          :conference_speaker_position,
          "#conference_speaker-position-tabs",
          **attributes[:position].except("machine_translations")
        )
        fill_in_i18n(
          :conference_speaker_affiliation,
          "#conference_speaker-affiliation-tabs",
          **attributes[:affiliation].except("machine_translations")
        )

        fill_in_i18n_editor(
          :conference_speaker_short_bio,
          "#conference_speaker-short_bio-tabs",
          **attributes[:short_bio].except("machine_translations")
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Media link" do
    let!(:attributes) { attributes_for(:media_link, conference:) }
    let!(:media_link) { create(:media_link, conference:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_conferences.edit_conference_path(conference)
      within_admin_sidebar_menu do
        click_on "Media Links"
      end
    end

    it "creates a new media link", versioning: true do
      click_on "New media link"

      within "[data-content]" do
        within ".new_media_link" do
          fill_in_i18n(
            :conference_media_link_title,
            "#conference_media_link-title-tabs",
            **attributes[:title].except("machine_translations")
          )

          fill_in :conference_media_link_link, with: "https://decidim.org"
          fill_in :conference_media_link_weight, with: 2
          fill_in_datepicker :conference_media_link_date_date, with: "24/10/2018"
        end

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a conference media links", versioning: true do
      within "#media_links tr", text: translated(media_link.title) do
        click_on "Edit"
      end

      within ".edit_media_link" do
        fill_in_i18n(
          :conference_media_link_title,
          "#conference_media_link-title-tabs",
          **attributes[:title].except("machine_translations")
        )

        fill_in :conference_media_link_link, with: "https://decidim.org"
        fill_in :conference_media_link_weight, with: 2
        fill_in_datepicker :conference_media_link_date_date, with: 1.month.ago.strftime("%d/%m/%Y")

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Conference" do
    let(:attributes) { attributes_for(:conference) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_conferences.conferences_path
    end

    it "creates a new conference", versioning: true do
      click_on "New conference"

      within ".new_conference" do
        fill_in_i18n(
          :conference_title,
          "#conference-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n(
          :conference_slogan,
          "#conference-slogan-tabs",
          **attributes[:slogan].except("machine_translations")
        )
        fill_in_i18n_editor(
          :conference_short_description,
          "#conference-short_description-tabs",
          **attributes[:short_description].except("machine_translations")
        )
        fill_in_i18n_editor(
          :conference_description,
          "#conference-description-tabs",
          **attributes[:description].except("machine_translations")
        )
        fill_in_i18n_editor(
          :conference_objectives,
          "#conference-objectives-tabs",
          **attributes[:objectives].except("machine_translations")
        )

        fill_in :conference_weight, with: 1
        fill_in :conference_slug, with: "slug"
        fill_in :conference_hashtag, with: "#hashtag"
      end

      within ".new_conference" do
        fill_in_datepicker :conference_start_date_date, with: 1.month.ago.strftime("%d/%m/%Y")
        fill_in_datepicker :conference_end_date_date, with: (1.month.ago + 3.days).strftime("%d/%m/%Y")

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a conference", versioning: true do
      within "tr", text: translated(conference.title) do
        click_on "Configure"
      end
      fill_in_i18n(
        :conference_title,
        "#conference-title-tabs",
        **attributes[:title].except("machine_translations")
      )
      fill_in_i18n(
        :conference_slogan,
        "#conference-slogan-tabs",
        **attributes[:slogan].except("machine_translations")
      )
      fill_in_i18n_editor(
        :conference_short_description,
        "#conference-short_description-tabs",
        **attributes[:short_description].except("machine_translations")
      )
      fill_in_i18n_editor(
        :conference_description,
        "#conference-description-tabs",
        **attributes[:description].except("machine_translations")
      )
      fill_in_i18n_editor(
        :conference_objectives,
        "#conference-objectives-tabs",
        **attributes[:objectives].except("machine_translations")
      )

      within ".edit_conference" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Partner" do
    let!(:conference_partner) { create(:partner, conference:) }
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }
    let!(:attributes) { attributes_for(:partner, conference:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_conferences.edit_conference_path(conference)
      within_admin_sidebar_menu do
        click_on "Partners"
      end
    end

    it "creates a conference partner", versioning: true do
      click_on "New partner"
      dynamically_attach_file(:conference_partner_logo, image1_path)

      within ".new_partner" do
        fill_in(:conference_partner_name, with: attributes[:name])

        select("Collaborator", from: :conference_partner_partner_type)

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a conference partners", versioning: true do
      visit current_path

      within "#partners tr", text: conference_partner.name do
        click_on "Edit"
      end

      within ".edit_partner" do
        fill_in(:conference_partner_name, with: attributes[:name])

        select("Collaborator", from: :conference_partner_partner_type)

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Registration type" do
    let!(:registration_type) { create(:registration_type, conference:) }
    let(:attributes) { attributes_for(:registration_type, conference:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_conferences.edit_conference_path(conference)
      within_admin_sidebar_menu do
        click_on "Registration Types"
      end
    end

    it "creates a conference registration types", versioning: true do
      click_on "New registration type"

      within ".new_registration_type" do
        fill_in_i18n(
          :conference_registration_type_title,
          "#conference_registration_type-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n_editor(
          :conference_registration_type_description,
          "#conference_registration_type-description-tabs",
          **attributes[:description].except("machine_translations")
        )

        fill_in(:conference_registration_type_weight, with: 4)

        find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a conference registration types", versioning: true do
      visit current_path

      within "#registration_types tr", text: translated(registration_type.title) do
        click_on "Edit"
      end

      within ".edit_registration_type" do
        fill_in_i18n(
          :conference_registration_type_title,
          "#conference_registration_type-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n_editor(
          :conference_registration_type_description,
          "#conference_registration_type-description-tabs",
          **attributes[:description].except("machine_translations")
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "Roles" do
    let(:attributes) { attributes_for(:user, organization:) }
    let(:other_user) { create(:user, organization:, email: "my_email@example.org") }
    let(:conference) { create(:conference, organization:) }

    let!(:conference_admin) do
      create(:conference_admin,
             :confirmed,
             organization:,
             conference:)
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_conferences.conference_user_roles_path(conference_slug: conference.slug)
      within_admin_sidebar_menu do
        click_on "Conference admins"
      end
    end

    it "creates a new Conference admin", versioning: true do
      click_on "New conference admin"

      within ".new_conference_user_role" do
        fill_in :conference_user_role_email, with: other_user.email
        fill_in :conference_user_role_name, with: attributes[:name]
        select "Administrator", from: :conference_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates an assembly admin", versioning: true do
      create(:conference_user_role, conference:, user: other_user)
      visit current_path
      within "#conference_admins" do
        within "#conference_admins tr", text: other_user.email do
          click_on "Edit"
        end
      end

      within ".edit_conference_user_roles" do
        select "Collaborator", from: :conference_user_role_role

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
