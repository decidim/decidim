# coding: utf-8
# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletters", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:deliverable_users) { create_list(:user, 5, newsletter_notifications: true, organization: organization) }

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

      find("#newsletters .actions .new").click

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

      expect(page).to have_content("Preview")
      expect(page).to have_content("A fancy newsletter for #{user.name}")

      within ".email-preview" do
        expect(page).to have_content("Hello #{user.name}! Relevant content.")
      end
    end
  end

  describe "update newsletter" do
    let!(:newsletter) { create(:newsletter, organization: organization)}

    it "allows a newsletter to be updated" do
      visit decidim_admin.newsletters_path
      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        click_link "Edit"
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

      expect(page).to have_content("Preview")
      expect(page).to have_content("A fancy newsletter")

      within ".email-preview" do
        expect(page).to have_content("Relevant content.")
      end
    end
  end

  describe "deliver a newsletter" do
    let!(:newsletter) { create(:newsletter, organization: organization)}

    it "allows a newsletter to be created" do
      visit decidim_admin.newsletter_path(newsletter)

      within ".actions" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("Newsletters")
      expect(page).to have_content("successfully")

      within ".newsletters tbody" do
        expect(page).to have_content("5 / 5")
      end
    end
  end

  describe "destroy a newsletter" do
    let!(:newsletter) { create(:newsletter, organization: organization)}

    it "destroys a newsletter" do
      visit decidim_admin.newsletters_path

      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        click_link "Destroy"
      end

      expect(page).to have_content("successfully")
      expect(page).to have_no_css("tr[data-newsletter-id=\"#{newsletter.id}\"]")
    end
  end
end
