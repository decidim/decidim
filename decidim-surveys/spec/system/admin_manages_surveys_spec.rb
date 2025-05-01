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
  let!(:survey) { create(:survey, :published, :clean_after_publish, component:, questionnaire:) }

  include_context "when managing a component as an admin"

  it_behaves_like "manage questionnaires"
  it_behaves_like "manage questionnaire responses"
  it_behaves_like "export survey user responses"
  it_behaves_like "manage announcements"

  context "with a new survey" do
    before do
      click_on "Questions"
    end

    it_behaves_like "uses questionnaire templates", :survey
  end

  context "when survey is not published" do
    before do
      component.unpublish!
    end

    let!(:question) { create(:questionnaire_question, questionnaire:) }

    it "allows to preview survey" do
      visit manage_questions_path
      expect(page).to have_link("Preview", href: [questionnaire_public_path, "surveys/#{survey.id}"].join)
    end

    it "shows a warning message" do
      visit questionnaire_public_path
      expect(page).to have_content("No surveys match your search criteria or there is not any survey open.")
    end

    it "allows to response survey" do
      visit questionnaire_public_path
      expect(page).to have_no_field(id: "questionnaire_responses_0")
    end

    context "when the survey has responses" do
      let!(:response) { create(:response, question:, questionnaire:) }

      it "shows warning message" do
        click_on "Questions"
        expect(page).to have_content("The form is not published")
      end

      it "allows editing questions" do
        click_on "Questions"
        click_on "Expand all"
        expect(page).to have_css("#questions_questions_#{question.id}_body_en")
        expect(page).to have_no_selector("#questions_questions_#{question.id}_body_en[disabled]")
      end

      it "deletes responses after published" do
        click_on "Questions"
        click_on "Expand all"

        within "#accordion-questionnaire_question_#{question.id}-field" do
          find_nested_form_field("body_en").fill_in with: "Have you been writing specs today?"
        end
        click_on "Save"
        expect(page).to have_admin_callout "Survey questions successfully saved"

        all("a", text: translated_attribute(component.name))[0].click
        click_on "Unpublish"
        expect(page).to have_admin_callout "Survey successfully unpublished"

        accept_confirm { click_on("Publish") }
        expect(page).to have_admin_callout "Survey successfully published"
        expect(questionnaire.responses).to be_empty
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
          visit components_path
        end

        context "when clean_after_publish is set to true" do
          context "when deletes previous responses after publishing" do
            it "show popup with an alert" do
              all("a", text: translated_attribute(component.name))[0].click
              click_on "Unpublish"
              click_on "Publish"
              expect(page).to have_content("Confirm")
            end

            it "deletes previous responses" do
              all("a", text: translated_attribute(component.name))[0].click
              click_on "Edit"
              expect(survey.clean_after_publish).to be true

              perform_enqueued_jobs do
                Decidim::Admin::PublishComponent.call(component, user)
              end

              expect(questionnaire.responses).to be_empty
            end
          end
        end

        context "when clean_after_publish is set to false" do
          let!(:survey) { create(:survey, :published, clean_after_publish: false, component:, questionnaire:) }

          it "does not delete previous responses after publishing" do
            expect(survey.clean_after_publish?).to be false

            perform_enqueued_jobs do
              Decidim::Admin::PublishComponent.call(component, user)
            end

            expect(questionnaire.responses).not_to be_empty
          end
        end
      end

      context "when publishing the questions' responses" do
        context "and the survey is open" do
          let!(:survey) { create(:survey, :published, :allow_responses, component:, questionnaire:) }

          it "does not show the 'Publish responses' button" do
            visit manage_questions_path
            click_on "Responses"

            expect(page).to have_no_content "Publish responses"
          end
        end

        context "and the survey is closed" do
          let!(:survey) { create(:survey, :published, component:, questionnaire:) }

          it "shows the 'Publish responses' button" do
            visit manage_questions_path
            click_on "Responses"
            expect(page).to have_content "Publish responses"
          end
        end

        context "and the questions are unsupported" do
          let!(:question) { create(:questionnaire_question, questionnaire:) }
          let!(:question1) { create(:questionnaire_question, question_type: "short_response", questionnaire:) }
          let!(:question2) { create(:questionnaire_question, question_type: "long_response", questionnaire:) }
          let!(:question3) { create(:questionnaire_question, question_type: "files", questionnaire:) }
          let!(:question4) { create(:questionnaire_question, question_type: "separator", questionnaire:) }

          let!(:response) { create(:response, question:, questionnaire:) }
          let!(:response1) { create(:response, question: question1, questionnaire:) }
          let!(:response2) { create(:response, question: question2, questionnaire:) }
          let!(:response3) { create(:response, question: question3, questionnaire:) }
          let!(:response4) { create(:response, question: question4, questionnaire:) }

          before do
            visit manage_questions_path
            click_on "Responses"
            click_on "Publish responses"
          end

          it "has not the buttons for publishing them" do
            within ".item__edit-form" do
              expect(page).to have_no_content "Not published"
            end
          end

          it "does not show the separator question type" do
            within ".item__edit-form" do
              expect(page).to have_css("li", count: 4)
            end
          end
        end

        context "and the questions are supported" do
          let(:question_single_option) { create(:questionnaire_question, :with_response_options, position: 0, question_type: "single_option", questionnaire:) }

          let(:question_multiple_option) { create(:questionnaire_question, :with_response_options, position: 1, question_type: "multiple_option", questionnaire:) }

          let(:question_matrix_single) { create(:questionnaire_question, :with_response_options, position: 2, question_type: "matrix_single", questionnaire:) }
          let!(:question_matrix_row_single1) { create(:question_matrix_row, question: question_matrix_single) }
          let!(:question_matrix_row_single2) { create(:question_matrix_row, question: question_matrix_single) }
          let!(:question_matrix_row_single3) { create(:question_matrix_row, question: question_matrix_single) }

          let(:question_matrix_multiple) { create(:questionnaire_question, :with_response_options, position: 3, question_type: "matrix_multiple", questionnaire:) }
          let!(:question_matrix_row_multiple1) { create(:question_matrix_row, question: question_matrix_multiple) }
          let!(:question_matrix_row_multiple2) { create(:question_matrix_row, question: question_matrix_multiple) }
          let!(:question_matrix_row_multiple3) { create(:question_matrix_row, question: question_matrix_multiple) }

          let(:question_sorting) { create(:questionnaire_question, :with_response_options, position: 4, question_type: "sorting", questionnaire:) }

          before do
            10.times do
              response = create(:response, question: question_single_option, questionnaire:)
              response_option = question_single_option.response_options.sample
              create(:response_choice, response_option:, response:, matrix_row: nil)

              response = create(:response, question: question_multiple_option, questionnaire:)
              response_option = question_multiple_option.response_options.sample
              create(:response_choice, response_option:, response:, matrix_row: nil)

              response = create(:response, question: question_matrix_single, questionnaire:)
              response_option = question_matrix_single.response_options.sample
              matrix_row = question_matrix_single.matrix_rows.sample
              create(:response_choice, response_option:, response:, matrix_row:)

              response = create(:response, question: question_matrix_multiple, questionnaire:)
              response_option = question_matrix_multiple.response_options.sample
              matrix_row = question_matrix_multiple.matrix_rows.sample
              create(:response_choice, response_option:, response:, matrix_row:)

              response = create(:response, question: question_sorting, questionnaire:)
              response_option = question_sorting.response_options.sample
              position = (0..(question_sorting.response_options.count - 1)).to_a.sample
              create(:response_choice, response_option:, response:, position:, matrix_row: nil)
            end

            visit manage_questions_path
            click_on "Responses"
            click_on "Publish responses"
          end

          # We do not do this in separate examples as the performance would be bad
          it "allows publishing and unpublishing the questions responses" do
            # shows the charts for each of the questions
            expect(page.html).to include('new Chartkick["ColumnChart"]("chart-1"')
            expect(page.html).to include('new Chartkick["ColumnChart"]("chart-2"')
            expect(page.html).to include('new Chartkick["ColumnChart"]("chart-3"')
            expect(page.html).to include('new Chartkick["ColumnChart"]("chart-4"')
            expect(page.html).to include('new Chartkick["BarChart"]("chart-5"')

            # has the buttons for publishing them
            within ".item__edit-form" do
              expect(page).to have_content "Not published"
            end

            # publishes them
            page.find("[for='publish_response_#{question_single_option.id}']").click

            within ".item__edit-form" do
              expect(page).to have_content "Published"
            end

            # Is still published on page reload
            visit current_path

            within ".item__edit-form" do
              expect(page).to have_content "Published"
            end

            # unpublishes them
            page.find("[for='publish_response_#{question_single_option.id}']").click

            within ".item__edit-form" do
              expect(page).to have_content "Not published"
            end

            # Is still not published on page reload
            visit current_path

            within ".item__edit-form" do
              expect(page).to have_content "Not published"
            end
          end
        end
      end
    end
  end

  context "when updates the questionnaire" do
    let(:description) do
      {
        en: "<p>New description</p>",
        ca: "<p>Nova descripció</p>",
        es: "<p>Nueva descripción</p>"
      }
    end
    let!(:questionnaire) { create(:questionnaire, description:) }
    let!(:survey) { create(:survey, :published, component:, questionnaire:) }

    it "updates the questionnaire description" do
      visit questionnaire_public_path
      choose "All"

      expect(page).to have_content("New description")
    end
  end

  def manage_questions_path
    Decidim::EngineRouter.admin_proxy(component).edit_questions_questions_survey_path(survey)
  end

  def update_component_settings_or_attributes
    survey.update!(allow_responses: true)
  end

  def see_questionnaire_questions
    choose "All"
    click_on decidim_sanitize_translated(questionnaire.title)
  end

  def questionnaire_public_path
    main_component_path(component)
  end

  private

  def find_nested_form_field(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end
end
