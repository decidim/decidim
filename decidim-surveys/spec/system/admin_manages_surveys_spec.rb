# frozen_string_literal: true

require "spec_helper"

describe "Admin manages surveys", type: :system do
  let(:manifest_name) { "surveys" }
  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:,
           published_at: nil)
  end
  let!(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create :survey, component:, questionnaire: }

  include_context "when managing a component as an admin"

  it_behaves_like "manage questionnaires"
  it_behaves_like "manage questionnaire answers"
  it_behaves_like "export survey user answers"
  it_behaves_like "manage announcements"

  context "when survey is not published" do
    before do
      component.unpublish!
    end

    let!(:question) { create(:questionnaire_question, questionnaire:) }

    it "allows to preview survey" do
      visit questionnaire_edit_path
      expect(page).to have_link("Preview", href: [questionnaire_public_path, "surveys/#{survey.id}"].join)
    end

    it "shows a warning message" do
      visit questionnaire_public_path
      expect(page).to have_content("This form is not published yet")
    end

    it "allows to answer survey" do
      visit questionnaire_public_path
      expect(page).to have_selector("input#questionnaire_responses_0")
    end

    context "when the survey has answers" do
      let!(:answer) { create(:answer, question:, questionnaire:) }

      it "shows warning message" do
        visit questionnaire_edit_path
        expect(page).to have_content("The form is not published")
      end

      it "allows editing questions" do
        visit questionnaire_edit_path
        click_button "Expand all"
        expect(page).to have_selector("#questionnaire_questions_#{question.id}_body_en")
        expect(page).to have_no_selector("#questionnaire_questions_#{question.id}_body_en[disabled]")
      end

      it "deletes answers after editing" do
        visit questionnaire_edit_path

        click_button "Expand all"

        within "form.edit_questionnaire" do
          within "#questionnaire_question_#{question.id}-field" do
            find_nested_form_field("body_en").fill_in with: "Have you been writing specs today?"
          end
          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")
        expect(questionnaire.answers).to be_empty
      end

      context "when publishing the survey" do
        let(:clean_after_publish) { true }

        before do
          component.update!(
            settings: {
              clean_after_publish:
            }
          )
        end

        context "when clean_after_publish is set to true" do
          it "deletes previous answers afer publishing" do
            expect(survey.clean_after_publish?).to be true

            perform_enqueued_jobs do
              Decidim::Admin::PublishComponent.call(component, user)
            end

            expect(questionnaire.answers).to be_empty
          end
        end

        context "when clean_after_publish is set to false" do
          let(:clean_after_publish) { false }

          it "does not delete previous answers afer publishing" do
            expect(survey.clean_after_publish?).to be false

            perform_enqueued_jobs do
              Decidim::Admin::PublishComponent.call(component, user)
            end

            expect(questionnaire.answers).not_to be_empty
          end
        end
      end
    end
  end

  def questionnaire_edit_path
    manage_component_path(component)
  end

  def questionnaire_public_path
    main_component_path(component)
  end

  it_behaves_like "uses questionnaire templates", :survey

  private

  def find_nested_form_field(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end
end
