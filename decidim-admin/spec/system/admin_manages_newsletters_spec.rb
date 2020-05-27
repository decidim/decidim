# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletters", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, name: "Sarah Kerrigan", organization: organization) }
  let!(:deliverable_users) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "newsletter index" do
    let(:recipients_count) { deliverable_users.size }

    it "shows the number of users subscribed to the newsletter" do
      visit decidim_admin.newsletters_path

      within ".subscribed_count" do
        expect(page).to have_content(recipients_count)
      end
    end
  end

  describe "creates and previews a newsletter" do
    it "allows a newsletter to be created" do
      visit decidim_admin.newsletters_path

      within ".secondary-nav" do
        find(".button.new").click
      end

      within "#image_text_cta" do
        click_link "Use this template"
      end

      within ".new_newsletter" do
        fill_in_i18n(
          :newsletter_subject,
          "#newsletter-subject-tabs",
          en: "A fancy newsletter for %{name}",
          es: "Un correo electrónico muy chulo para %{name}",
          ca: "Un correu electrònic flipant per a %{name}"
        )

        fill_in_i18n_editor(
          :newsletter_settings_introduction,
          "#newsletter-settings--introduction-tabs",
          en: "Hello %{name}! Relevant content.",
          es: "Hola, %{name}! Contenido relevante.",
          ca: "Hola, %{name}! Contingut rellevant."
        )

        fill_in_i18n(
          :newsletter_settings_cta_text,
          "#newsletter-settings--cta_text-tabs",
          en: "Hello %{name}! Relevant content."
        )

        fill_in_i18n(
          :newsletter_settings_cta_url,
          "#newsletter-settings--cta_url-tabs",
          en: "Hello %{name}! Relevant content."
        )

        fill_in_i18n_editor(
          :newsletter_settings_body,
          "#newsletter-settings--body-tabs",
          en: "Hello %{name}! Relevant content.",
          es: "Hola, %{name}! Contenido relevante.",
          ca: "Hola, %{name}! Contingut rellevant."
        )

        attach_file(
          "Main image",
          Decidim::Dev.asset("city2.jpeg")
        )

        find("*[type=submit]").click
      end

      expect(page).to have_content("PREVIEW")
      expect(page).to have_content("A fancy newsletter for #{user.name}")
    end
  end

  describe "previews a newsletter" do
    let!(:newsletter) do
      create(:newsletter,
             organization: organization,
             subject: {
               en: "A fancy newsletter for %{name}",
               es: "Un correo electrónico muy chulo para %{name}",
               ca: "Un correu electrònic flipant per a %{name}"
             },
             body: {
               en: "Hello %{name}! Relevant content.",
               es: "Hola, %{name}! Contenido relevante.",
               ca: "Hola, %{name}! Contingut rellevant."
             })
    end

    it "previews a newsletter" do
      visit decidim_admin.newsletter_path(newsletter)

      expect(page).to have_content("A fancy newsletter for Sarah Kerrigan")
      expect(page).to have_css("iframe.email-preview[src=\"#{decidim_admin.preview_newsletter_path(newsletter)}\"]")

      visit decidim_admin.preview_newsletter_path(newsletter)
      expect(page).to have_content("Hello Sarah Kerrigan! Relevant content.")
    end
  end

  describe "update newsletter" do
    let!(:newsletter) { create(:newsletter, organization: organization) }

    it "allows a newsletter to be updated" do
      visit decidim_admin.newsletters_path
      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        click_link "Edit"
      end

      within ".edit_newsletter" do
        fill_in_i18n(
          :newsletter_subject,
          "#newsletter-subject-tabs",
          en: "A fancy newsletter",
          es: "Un correo electrónico muy chulo",
          ca: "Un correu electrònic flipant"
        )

        fill_in_i18n_editor(
          :newsletter_settings_body,
          "#newsletter-settings--body-tabs",
          en: "Relevant content.",
          es: "Contenido relevante.",
          ca: "Contingut rellevant."
        )

        find("*[type=submit]").click
      end

      expect(page).to have_content("PREVIEW")
      expect(page).to have_content("A fancy newsletter")
    end
  end

  describe "select newsletter recipients" do
    let!(:newsletter) { create(:newsletter, organization: organization) }

    context "when all users are selected" do
      let(:recipients_count) { deliverable_users.size }

      it "sends to all users" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            find(:css, "#newsletter_send_to_all_users").set(true)
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          within ".button--double" do
            accept_confirm { find("*", text: "Deliver").click }
          end

          expect(page).to have_content("NEWSLETTERS")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("Has been sent to: All users")
          expect(page).to have_content("5 / 5")
        end
      end
    end

    context "when followers are selected" do
      let!(:participatory_processes) { create_list(:participatory_process, 2, organization: organization) }
      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: participatory_processes.first, user: follower)
        end
      end
      let(:recipients_count) { followers.size }

      it "sends to followers" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            uncheck("Send to all users")
            check("Send to followers")
            uncheck("Send to participants")
            within ".participatory_processes-block" do
              select translated(participatory_processes.first.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          within ".button--double" do
            accept_confirm { find("*", text: "Deliver").click }
          end

          expect(page).to have_content("NEWSLETTERS")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("5 / 5")
        end
      end
    end

    context "when participants are selected" do
      let(:recipients_count) { deliverable_users.size }
      let!(:component) { create(:dummy_component, organization: newsletter.organization) }

      let!(:participants) do
        deliverable_users.each do |participant|
          create(:dummy_resource, component: component, author: participant, published_at: Time.current)
        end
      end

      it "sends to participants" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            uncheck("Send to all users")
            uncheck("Send to followers")
            check("Send to participants")
            within ".participatory_processes-block" do
              select translated(component.participatory_space.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          within ".button--double" do
            accept_confirm { find("*", text: "Deliver").click }
          end

          expect(page).to have_content("NEWSLETTERS")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("5 / 5")
        end
      end
    end

    context "when selecting both followers and participants" do
      let(:recipients_count) { (followers + participants).size }
      let!(:component) { create(:dummy_component, organization: newsletter.organization) }
      let!(:deliverable_users2) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization: organization) }

      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: component.participatory_space, user: follower)
        end
      end

      let!(:participants) do
        deliverable_users2.each do |participant|
          create(:dummy_resource, component: component, author: participant, published_at: Time.current)
        end
      end

      it "sends to followers and participants" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            uncheck("Send to all users")
            check("Send to followers")
            check("Send to participants")
            within ".participatory_processes-block" do
              select translated(component.participatory_space.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          within ".button--double" do
            accept_confirm { find("*", text: "Deliver").click }
          end

          expect(page).to have_content("NEWSLETTERS")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("10 / 10")
        end
      end
    end
  end

  describe "deleting a newsletter" do
    let!(:newsletter) { create(:newsletter, organization: organization) }

    it "deletes a newsletter" do
      visit decidim_admin.newsletters_path

      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_content("successfully")
      expect(page).to have_no_css("tr[data-newsletter-id=\"#{newsletter.id}\"]")
    end
  end
end
