# frozen_string_literal: true

require "spec_helper"

shared_examples_for "create questionnaires" do
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end

  it "creates a questionnaire" do
    visit_create_questionnaire_path

    title = {
      en: "My super questionnaire"
    }

    description = {
      en: "<p>New description</p>",
      ca: "<p>Nova descripció</p>",
      es: "<p>Nueva descripción</p>"
    }

    tos = {
      en: "<p>My TOS</p>"
    }

    within "form.new_questionnaire" do
      fill_in_i18n(:questionnaire_title, "#questionnaire-title-tabs", title)
      fill_in_i18n_editor(:questionnaire_description, "#questionnaire-description-tabs", description)
      fill_in_i18n_editor(:questionnaire_tos, "#questionnaire-tos-tabs", tos)

      click_button "Create"
    end

    expect(page).to have_admin_callout("successfully")

    expect(page).to have_content(title[:en])
  end

  context "with answers" do
    it "cannot create new questionnaires" do
      create :answer, questionnaire: questionnaire

      visit manage_component_path(component)

      expect(page).not_to have_content("Create")
    end
  end

  private

  def find_nested_form_field_locator(attribute, visible: true)
    find_nested_form_field(attribute, visible: visible)["id"]
  end

  def find_nested_form_field(attribute, visible: true)
    current_scope.find(nested_form_field_selector(attribute), visible: visible)
  end

  def have_nested_field(attribute, with:)
    have_field find_nested_form_field_locator(attribute), with: with
  end

  def have_no_nested_field(attribute, with:)
    have_no_field(find_nested_form_field_locator(attribute), with: with)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end
end
