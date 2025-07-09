# frozen_string_literal: true

require "spec_helper"

describe "Admin manages user block templates" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_templates.block_user_templates_path
  end

  it_behaves_like "needs admin TOS accepted" do
    let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: nil, organization:) }
  end

  describe "listing templates" do
    let!(:template) { create(:template, :user_block, organization:) }

    before do
      visit decidim_admin_templates.block_user_templates_path
    end

    it "shows a table with the templates info" do
      within ".user_block-templates" do
        expect(page).to have_i18n_content(template.name)
      end
    end
  end

  describe "creating a user block template" do
    before do
      within ".layout-content" do
        click_on("New template")
      end
    end

    it "creates a new template block user template" do
      within ".new_user_block_template" do
        fill_in_i18n(
          :template_name,
          "#template-name-tabs",
          en: "My template",
          es: "Mi plantilla",
          ca: "La meva plantilla"
        )
        fill_in_i18n(
          :template_description,
          "#template-description-tabs",
          en: "Description",
          es: "Descripción",
          ca: "Descripció"
        )
        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
    end
  end

  describe "updating a template" do
    let!(:template) { create(:template, :user_block, organization:) }

    before do
      visit decidim_admin_templates.block_user_templates_path
      click_on translated(template.name)
    end

    it "updates a template" do
      fill_in_i18n(
        :template_name,
        "#template-name-tabs",
        en: "My new name",
        es: "Mi nuevo nombre",
        ca: "El meu nou nom"
      )

      within ".edit_user_block_template" do
        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "[data-content]" do
        expect(page).to have_current_path decidim_admin_templates.block_user_templates_path
        expect(page).to have_content("My new name")
      end
    end
  end

  describe "updating a template with invalid values" do
    let!(:template) { create(:template, :user_block, organization:) }

    before do
      visit decidim_admin_templates.block_user_templates_path
      click_on translated(template.name)
    end

    it "does not update the template" do
      fill_in_i18n(
        :template_name,
        "#template-name-tabs",
        en: "",
        es: "",
        ca: ""
      )

      within ".edit_user_block_template" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "copying a template" do
    let!(:template) { create(:template, :user_block, organization:) }

    before do
      visit decidim_admin_templates.block_user_templates_path
    end

    it "copies the template" do
      within "tr", text: translated(template.name) do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content(template.name["en"], count: 2)
    end
  end

  describe "destroying a template" do
    let!(:template) { create(:template, :user_block, organization:) }

    before do
      visit decidim_admin_templates.block_user_templates_path
    end

    it "destroys the template" do
      within "tr", text: translated(template.name) do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_no_i18n_content(template.name)
    end
  end
end
