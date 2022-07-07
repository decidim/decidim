# frozen_string_literal: true

require "spec_helper"

# rubocop:disable Rails/SkipsModelValidations

shared_examples_for "uses questionnaire templates" do |_questionnaire_for|
  describe "choose a template" do
    context "when there are no templates" do
      before do
        questionnaire.update_columns(
          created_at: 1.day.ago,
          updated_at: Time.zone.now
        )
      end

      it "doesn't show the template selection screen" do
        expect(page).to have_no_content("Choose template")
      end
    end

    context "when there are templates" do
      let!(:templates) { create_list(:questionnaire_template, 6, :with_questions, organization: questionnaire.questionnaire_for.organization) }
      let(:template) { templates.first }
      let(:question) { template.templatable.questions.first }

      context "when it is an existing questionnaire" do
        before do
          questionnaire.update_columns(
            created_at: 1.day.ago,
            updated_at: Time.zone.now
          )
        end

        it "doesn't show the template selection screen" do
          expect(page).to have_no_content("Choose template")
        end
      end

      context "when it is a newly created questionnaire" do
        before do
          questionnaire.update_columns(
            created_at: Time.zone.now,
            updated_at: Time.zone.now,
            title: {},
            description: {},
            tos: {}
          )
          visit questionnaire_edit_path
        end

        it "shows the template choosing screen" do
          expect(page).to have_content("Choose template")
        end

        it "loads the templates in the select" do
          page.find("input[name='select-template']").click

          within "#template-list", visible: :hidden do
            expect(page).to have_selector("option", visible: :hidden, count: 6)
          end
        end

        it "displays the preview when a template is selected" do
          select(template.name["en"], from: "select-template")

          within ".questionnaire-template-preview" do
            expect(page).to have_i18n_content(template.name)
            expect(page).to have_i18n_content(question.body)
          end
        end
      end
    end
  end

  describe "apply a template" do
    let!(:templates) { create_list(:questionnaire_template, 6, :with_questions, organization: questionnaire.questionnaire_for.organization) }
    let(:template) { templates.first }
    let(:question) { template.templatable.questions.first }
    let(:questionnaire_question) { questionnaire.questions.first }

    before do
      questionnaire.update_columns(
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
        title: {},
        description: {},
        tos: {}
      )
      visit questionnaire_edit_path

      select(template.name["en"], from: "select-template")

      within ".create-from-template" do
        find("*[type=submit]").click
      end
    end

    it "copies the template data to the questionnaire on submit" do
      within "form.edit_questionnaire" do
        click_button "Expand all"
        expect(page.find("#questionnaire_title_en").value).to eq(template.templatable.title["en"])
        expect(page.find("#questionnaire_questions_#{questionnaire_question.id}_body_en").value).to eq(question.body["en"])
      end
    end
  end
end

# rubocop:enable Rails/SkipsModelValidations
