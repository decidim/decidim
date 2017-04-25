# coding: utf-8
# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletters", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, name: "Sarah Kerrigan", organization: organization) }
  let!(:deliverable_users) { create_list(:user, 5, :confirmed, newsletter_notifications: true, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  describe "creates and previews a newsletter" do
    it "allows a newsletter to be created" do
      visit decidim_admin.newsletters_path

      within ".secondary-nav" do
        find(".button.new").click
      end

      within ".new_newsletter" do
        fill_in_i18n(
          :newsletter_subject,
          "#subject-tabs",
          en: "A fancy newsletter for %{name}",
          es: "Un correo electrónico muy chulo para %{name}",
          ca: "Un correu electrònic flipant per a %{name}"
        )

        fill_in_i18n_editor(
          :newsletter_body,
          "#body-tabs",
          en: "Hello %{name}! Relevant content.",
          es: "Hola, %{name}! Contenido relevante.",
          ca: "Hola, %{name}! Contingut rellevant."
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
    let!(:newsletter) { create(:newsletter, organization: organization)}

    it "allows a newsletter to be updated" do
      visit decidim_admin.newsletters_path
      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        page.find('.action-icon.edit').click
      end

      within ".edit_newsletter" do
        fill_in_i18n(
          :newsletter_subject,
          "#subject-tabs",
          en: "A fancy newsletter",
          es: "Un correo electrónico muy chulo",
          ca: "Un correu electrònic flipant"
        )

        fill_in_i18n_editor(
          :newsletter_body,
          "#body-tabs",
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

  describe "deliver a newsletter" do
    let!(:newsletter) { create(:newsletter, organization: organization)}

    it "allows a newsletter to be created" do
      visit decidim_admin.newsletter_path(newsletter)

      within ".button--double" do
        find("*", text: "Deliver").click
      end

      accept_alert_dialogue

      expect(page).to have_content("NEWSLETTERS")
      expect(page).to have_content("successfully")

      within "tbody" do
        expect(page).to have_content("5 / 5")
      end
    end
  end

  describe "destroy a newsletter" do
    let!(:newsletter) { create(:newsletter, organization: organization)}

    it "destroys a newsletter" do
      visit decidim_admin.newsletters_path

      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        page.find('.action-icon.action-icon--remove').click
      end

      accept_alert_dialogue

      expect(page).to have_content("successfully")
      expect(page).to have_no_css("tr[data-newsletter-id=\"#{newsletter.id}\"]")
    end
  end
end
