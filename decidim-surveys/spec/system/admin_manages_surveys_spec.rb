# frozen_string_literal: true

require "spec_helper"

describe "Admin manages surveys" do
  let(:manifest_name) { "surveys" }
  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:,
           published_at: nil)
  end
  let!(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create(:survey, component:, published_at: Time.current, questionnaire:) }

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
      expect(page).to have_content("No surveys match your search criteria or there is not any survey open.")
    end

    it "allows to answer survey" do
      visit questionnaire_public_path
      expect(page).to have_no_field(id: "questionnaire_responses_0")
    end

    context "when the survey has answers" do
      let!(:answer) { create(:answer, question:, questionnaire:) }

      it "shows warning message" do
        click_on "Manage questions"
        expect(page).to have_content("The form is not published")
      end

      it "allows editing questions" do
        click_on "Manage questions"
        click_on "Expand all"
        expect(page).to have_css("#questions_questions_#{question.id}_body_en")
        expect(page).to have_no_selector("#questions_questions_#{question.id}_body_en[disabled]")
      end

      it "deletes answers after editing" do
        click_on "Manage questions"

        click_on "Expand all"

        within "#accordion-questionnaire_question_#{question.id}-field" do
          find_nested_form_field("body_en").fill_in with: "Have you been writing specs today?"
        end
        click_on "Save"

        expect(page).to have_admin_callout "Survey questions successfully saved"
        expect(questionnaire.answers).to be_empty
      end

      context "when publishing the survey" do
        let!(:participatory_process) do
          create(:participatory_process, organization:)
        end
        let(:participatory_space_path) do
          decidim_admin_participatory_processes.components_path(participatory_process)
        end
        let(:components_path) { participatory_space_path }

        before do
          survey.update!(clean_after_publish: true)
          visit components_path
        end

        context "when clean_after_publish is set to true" do
          context "when deletes previous answers after publishing" do
            it "show popup with an alert" do
              find(:css, ".action-icon--publish").click
              expect(page).to have_content("Confirm")
            end

            it "deletes previous answers" do
              click_on translated_attribute(component.name)
              click_on "Edit"
              expect(survey.clean_after_publish).to be true

              perform_enqueued_jobs do
                Decidim::Admin::PublishComponent.call(component, user)
              end

              expect(questionnaire.answers).to be_empty
            end
          end
        end

        context "when clean_after_publish is set to false" do
          before do
            survey.update!(clean_after_publish: false)
          end

          it "does not delete previous answers after publishing" do
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
