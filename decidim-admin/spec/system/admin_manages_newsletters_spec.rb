# frozen_string_literal: true

require "spec_helper"
%w(conferences initiatives).each do |space|
  require "decidim/#{space}/test/factories.rb"
end

describe "Admin manages newsletters" do
  let(:organization) { create(:organization) }
  let!(:attributes) { attributes_for(:newsletter, organization:) }
  let(:user) { create(:user, :admin, :confirmed, name: "Sarah Kerrigan", organization:) }
  let!(:deliverable_users) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "newsletter index" do
    let(:recipients_count) { deliverable_users.size }

    it "shows the number of users subscribed to the newsletter" do
      visit decidim_admin.newsletters_path

      within "span[data-subscribed-count]" do
        expect(page).to have_content(recipients_count)
      end
    end
  end

  describe "creates and previews a newsletter" do
    it "allows a newsletter to be created" do
      visit decidim_admin.newsletters_path

      find(".button.new").click

      within "#image_text_cta" do
        click_on "Use this template"
      end

      within ".new_newsletter" do
        fill_in_i18n(
          :newsletter_subject,
          "#newsletter-subject-tabs",
          **attributes[:subject].except("machine_translations")
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
      end

      dynamically_attach_file(:newsletter_images_main_image, Decidim::Dev.asset("city2.jpeg"))

      within ".new_newsletter" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("Preview")
      expect(page).to have_content(translated(attributes[:subject]))

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:subject])} newsletter")
    end
  end

  describe "previews a newsletter" do
    let!(:newsletter) do
      create(:newsletter,
             organization:,
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
      expect(page).to have_css("iframe[data-email-preview][src=\"#{decidim_admin.preview_newsletter_path(newsletter)}\"]")

      visit decidim_admin.preview_newsletter_path(newsletter)
      expect(page).to have_content("Hello Sarah Kerrigan! Relevant content.")
    end

    context "when admin clicks on the 'send me a test email' button" do
      it "sends a test email" do
        visit decidim_admin.newsletter_path(newsletter)

        perform_enqueued_jobs do
          click_on "Send me a test email"
        end

        expect(page).to have_content("Newsletter has been sent")
        expect(last_email.subject).to include("A fancy newsletter for")
      end
    end

    context "when admin clicks on the 'send me a test email' button in the index page" do
      it "sends a test email" do
        visit decidim_admin.newsletters_path

        within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
          find("button[data-component='dropdown']").click
          perform_enqueued_jobs do
            click_on "Send me a test email"
          end
        end

        expect(page).to have_content("Newsletter has been sent")
        expect(last_email.subject).to include("A fancy newsletter for")
      end
    end
  end

  describe "update newsletter" do
    let!(:newsletter) { create(:newsletter, organization:) }

    it "allows a newsletter to be updated" do
      visit decidim_admin.newsletters_path
      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end

      within ".edit_newsletter" do
        fill_in_i18n(
          :newsletter_subject,
          "#newsletter-subject-tabs",
          **attributes[:subject].except("machine_translations")
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

      expect(page).to have_content("Preview")
      expect(page).to have_content(translated(attributes[:subject]))

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:subject])} newsletter")
    end
  end

  describe "select newsletter recipients" do
    let!(:participatory_process) { create(:participatory_process, organization:, skip_injection: true) }
    let!(:assembly) { create(:assembly, organization:, skip_injection: true) }
    let!(:conference) { create(:conference, organization:, skip_injection: true) }
    let!(:initiative) { create(:initiative, organization:, skip_injection: true) }

    let!(:newsletter) { create(:newsletter, organization:) }
    let(:spaces) { [participatory_process, assembly, conference, initiative] }
    let!(:component) { create(:dummy_component, participatory_space: participatory_process) }

    def select_all
      spaces.each do |space|
        plural_name = space.model_name.route_key
        select_id = "##{plural_name}-spaces-select"

        next unless has_css?(select_id)

        tom_select(select_id, option_id: "all")
      end
    end

    def select_verification_type(types)
      select_id = "#verification-types-select"

      return unless has_css?(select_id)

      option_ids = Array(types)
      tom_select(select_id, option_id: option_ids)
    end

    context "when all users are selected" do
      let(:recipients_count) { deliverable_users.size }

      it "sends to all users", :slow do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            choose("Send to all users")
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          within "form.newsletter_deliver .item__edit-sticky" do
            accept_confirm { click_on("Deliver newsletter") }
          end

          expect(page).to have_content("Newsletters")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("Has been sent to: All users")
          expect(page).to have_content("5 / 5")
        end
      end
    end

    context "when verified users selected" do
      let!(:verification_type_first) { create(:authorization, :granted, user: deliverable_users.first, organization:, name: "id_documents") }
      let!(:verification_type_last) { create(:authorization, :granted, user: deliverable_users.last, organization:, name: "postal_letter") }

      before do
        organization.update!(
          available_authorizations: [verification_type_first.name, verification_type_last.name]
        )
      end

      context "with one verification type" do
        let(:recipients_count) { 1 }

        it "sends newsletter to users verified with one type", :slow do
          visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)

          within(".newsletter_deliver") do
            choose("Send to verified users")
            select_verification_type(verification_type_first.name) # Одна авторизация передается как строка
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          click_on("Confirm recipients")

          expect(page).to have_content(deliverable_users.first.name)
          expect(page).to have_no_content(deliverable_users.last.name)
          expect(page).to have_content(deliverable_users.first.email)
          expect(page).to have_no_content(deliverable_users.last.email)

          perform_enqueued_jobs do
            accept_confirm { click_on("Deliver newsletter") }

            expect(page).to have_content("Newsletters")
            expect(page).to have_admin_callout("successfully")
          end

          within "tbody" do
            expect(page).to have_content("Has been sent to: Verified users")
            expect(page).to have_content("1 / 1")
          end
        end
      end

      context "with two verification types" do
        let(:recipients_count) { 2 }

        it "sends newsletter to users verified with both types", :slow do
          visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)

          within(".newsletter_deliver") do
            choose("Send to verified users")
            select_verification_type([verification_type_first.name, verification_type_last.name]) # Несколько авторизаций передаются как массив
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          click_on("Confirm recipients")

          expect(page).to have_content(deliverable_users.first.name)
          expect(page).to have_content(deliverable_users.last.name)
          expect(page).to have_content(deliverable_users.first.email)
          expect(page).to have_content(deliverable_users.last.email)

          perform_enqueued_jobs do
            accept_confirm { click_on("Deliver newsletter") }

            expect(page).to have_content("Newsletters")
            expect(page).to have_admin_callout("successfully")
          end

          within "tbody" do
            expect(page).to have_content("Has been sent to: Verified users")
            expect(page).to have_content("2 / 2")
          end
        end
      end
    end

    context "when followers are selected" do
      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: component.participatory_space, user: follower)
        end
      end
      let(:recipients_count) { followers.size }

      it "sends to followers", :slow do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            check("Send to followers")
            select_all
          end

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          click_on("Confirm recipients")

          deliverable_users.each do |user|
            expect(page).to have_content(user.name)
            expect(page).to have_content(user.email)
          end

          accept_confirm { click_on("Deliver newsletter") }

          expect(page).to have_content("Newsletters")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("5 / 5")
        end
      end

      context "when the followers count varies" do
        let!(:followers) do
          deliverable_users.first(3).each do |follower|
            create(:follow, followable: component.participatory_space, user: follower)
          end
        end

        it "has a working user counter" do
          visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
          expect(page).to have_content("This newsletter will be send to 5 users.")
          check("Send to followers")
          select_all
          expect(page).to have_content("This newsletter will be send to 3 users.")
        end
      end
    end

    context "when participants are selected" do
      let(:recipients_count) { deliverable_users.size }

      let!(:participants) do
        deliverable_users.each do |participant|
          create(:dummy_resource, component:, author: participant, published_at: Time.current)
        end
      end

      it "has a working user counter" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        expect(page).to have_content("This newsletter will be send to 5 users.")
        check("Send to participants")

        expect(find("input[name='newsletter[send_to_participants]']")).to be_checked

        plural_name = assembly.model_name.route_key
        select_id = "##{plural_name}-spaces-select"
        tom_select(select_id, option_id: translated(assembly.title))
        expect(page).to have_content("This newsletter will be send to 0 users.")
      end

      it "sends to participants", :slow do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        check("Send to participants")

        expect(find("input[name='newsletter[send_to_participants]']")).to be_checked

        select_all

        expect(page).to have_content("This newsletter will be send to 5 users.")

        click_on("Confirm recipients")

        deliverable_users.each do |user|
          expect(page).to have_content(user.name)
          expect(page).to have_content(user.email)
        end

        perform_enqueued_jobs do
          accept_confirm { click_on("Deliver newsletter") }

          expect(page).to have_content("Newsletters")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("5 / 5")
        end
      end
    end

    context "when selecting both followers and participants" do
      let(:recipients_count) { (followers + participants).size }
      let!(:deliverable_users2) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization:) }

      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: component.participatory_space, user: follower)
        end
      end

      let!(:participants) do
        deliverable_users2.each do |participant|
          create(:dummy_resource, component:, author: participant, published_at: Time.current)
        end
      end

      it "sends to followers and participants", :slow do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        check("Send to participants")
        check("Send to followers")
        select_all

        within "#recipients_count" do
          expect(page).to have_content(recipients_count)
        end

        click_on("Confirm recipients")

        perform_enqueued_jobs do
          accept_confirm { click_on("Deliver newsletter") }
          expect(page).to have_content("Newsletters")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("10 / 10")
        end
      end
    end

    context "when private members are selected" do
      context "with private members" do
        let!(:participatory_process) { create(:participatory_process, organization:, skip_injection: true, private_space: true) }
        let!(:private_users) do
          create_list(:participatory_space_private_user, 30) do |private_user|
            private_user.user = create(:user, :confirmed, newsletter_notifications_at: Time.current, organization:)
            private_user.privatable_to = participatory_process
            private_user.save!
          end
        end

        let(:recipients_count) { private_users.size }

        it "sends to private members", :slow do
          visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
          check("Send to private members")

          expect(find("input[name='newsletter[send_to_private_members]']")).to be_checked

          select_all

          within "#recipients_count" do
            expect(page).to have_content(recipients_count)
          end

          click_on("Confirm recipients")

          # The users are paginated
          expect(page).to have_content("Results per page")
          expect(page).to have_content("Next")

          perform_enqueued_jobs do
            accept_confirm { click_on("Deliver newsletter") }
            expect(page).to have_content("Newsletters")
            expect(page).to have_admin_callout("successfully")
          end

          within "tbody" do
            expect(page).to have_content("30 / 30")
          end
        end
      end

      context "when the private members count is 0" do
        it "does not display any recipients", :slow do
          visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
          check("Send to private members")

          expect(find("input[name='newsletter[send_to_private_members]']")).to be_checked

          select_all

          within "#recipients_count" do
            expect(page).to have_content("0")
          end

          click_on("Confirm recipients")

          # Check that no users are displayed
          expect(page).to have_no_content("Results per page")
          expect(page).to have_no_content("Next")
          within "tbody" do
            expect(page).to have_no_css("tr")
          end
        end
      end
    end
  end

  describe "deleting a newsletter" do
    let!(:newsletter) { create(:newsletter, organization:) }

    it "deletes a newsletter" do
      visit decidim_admin.newsletters_path

      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_content("successfully")
      expect(page).to have_no_css("tr[data-newsletter-id=\"#{newsletter.id}\"]")
    end
  end
end
