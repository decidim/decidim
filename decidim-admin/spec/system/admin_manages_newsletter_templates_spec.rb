# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletter templates" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, name: "Sarah Kerrigan", organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "newsletter templates index" do
    it "lists the available templates" do
      visit decidim_admin.newsletters_path

      find(".button.new").click

      expect(page).to have_content("Basic (only text)")
      expect(page).to have_content("Image, text and Call To Action button")
    end
  end

  describe "previewing a newsletter template" do
    it "allows the user to preview a template" do
      visit decidim_admin.newsletters_path

      find(".button.new").click

      within "#basic_only_text" do
        click_link "Preview"
      end

      expect(page).to have_content("Preview template: Basic (only text)")

      within_frame do
        expect(page).to have_content("Dummy text for body")
      end
    end

    it "lets the user use the template to create a newsletter" do
      visit decidim_admin.newsletters_path

      find(".button.new").click

      within "#basic_only_text" do
        click_link "Preview"
      end

      click_link "Use this template"

      expect(page).to have_content("New newsletter")
    end
  end

  describe "previewing a newsletter template iframe" do
    shared_examples "working newsletter template iframe" do |template_id|
      it "changes the footer links correctly" do
        visit decidim_admin.preview_newsletter_template_path(template_id)
        expect(page).to have_link("notifications page", href: "#")
        expect(page).to have_link("Unsubscribe", href: "#")
        expect(page).to have_link(organization.name, href: "#", count: 2)
      end
    end

    it_behaves_like "working newsletter template iframe", :basic_only_text
    it_behaves_like "working newsletter template iframe", :image_text_cta
  end
end
