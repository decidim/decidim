# frozen_string_literal: true

shared_examples "editable survey answers" do
  let(:options) do
    [
      { "body" => Decidim::Faker::Localized.sentence },
      { "body" => Decidim::Faker::Localized.sentence },
      { "body" => Decidim::Faker::Localized.sentence }
    ]
  end

  let(:rows) do
    [
      { "body" => Decidim::Faker::Localized.sentence },
      { "body" => Decidim::Faker::Localized.sentence },
      { "body" => Decidim::Faker::Localized.sentence }
    ]
  end

  let!(:survey) { create(:survey, :published, :allow_edit, :announcement, :allow_answers, :allow_unregistered, component:, questionnaire:) }
  let!(:question) { short_answer_question }

  let!(:short_answer_question) { create(:questionnaire_question, position: 0, questionnaire:, question_type: :short_answer) }
  let!(:long_answer_question) { create(:questionnaire_question, position: 1, questionnaire:, question_type: :long_answer) }
  let!(:single_option_question) { create(:questionnaire_question, position: 3, questionnaire:, question_type: :single_option, options:) }
  let!(:multiple_option_question) { create(:questionnaire_question, position: 4, questionnaire:, question_type: :multiple_option, options:) }
  let!(:matrix_single_question) { create(:questionnaire_question, position: 6, questionnaire:, question_type: :matrix_single, options:, rows: [rows.first]) }
  let!(:matrix_multiple_question) { create(:questionnaire_question, position: 7, questionnaire:, question_type: :matrix_multiple, options:, rows:) }
  # let!(:sorting_question) { create(:questionnaire_question, position: 5, questionnaire:, question_type: :sorting, options:) }

  before do
    visit_component
    click_on translated_attribute(questionnaire.title)

    fill_in "questionnaire_responses_0", with: "My first answer"
    fill_in "questionnaire_responses_1", with: "My long answer"

    choose :questionnaire_responses_2_choices_0_body
    check :questionnaire_responses_3_choices_0_body
    choose :questionnaire_responses_4_matrix_row_0_choice_0_body

    check :questionnaire_responses_5_matrix_row_0_choice_0_body
    check :questionnaire_responses_5_matrix_row_1_choice_0_body
    check :questionnaire_responses_5_matrix_row_2_choice_0_body

    check "questionnaire_tos_agreement"
    accept_confirm { click_on "Submit" }
  end

  it "restricts the change of an answer when editing is disabled" do
    expect(page).to have_content("Edit your answers")

    survey.update!(allow_editing_answers: false)

    click_on "Edit your answers"

    expect(page).to have_content("You are not allowed to edit your answers.")
  end

  it "restricts the change of an answer when form is closed" do
    expect(page).to have_content("Edit your answers")

    survey.update!(ends_at: 1.day.ago)

    click_on "Edit your answers"

    expect(page).to have_content("You are not allowed to edit your answers.")
  end

  it "allows to change the response of a text field" do
    expect(page).to have_content("Edit your answers")
    click_on "Edit your answers"

    expect(page).to have_field("questionnaire_responses_0", with: "My first answer")
    expect(page).to have_field("questionnaire_responses_1", with: "My long answer")

    expect(page).to have_checked_field(:questionnaire_responses_2_choices_0_body)
    expect(page).to have_checked_field(:questionnaire_responses_3_choices_0_body)
    expect(page).to have_checked_field(:questionnaire_responses_4_matrix_row_0_choice_0_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_0_choice_0_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_1_choice_0_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_2_choice_0_body)

    fill_in "questionnaire_responses_0", with: "My first answer has changed"
    fill_in "questionnaire_responses_1", with: "My long answer has changed"

    choose :questionnaire_responses_2_choices_2_body
    check :questionnaire_responses_3_choices_2_body
    choose :questionnaire_responses_4_matrix_row_0_choice_2_body

    check :questionnaire_responses_5_matrix_row_0_choice_2_body
    check :questionnaire_responses_5_matrix_row_1_choice_2_body
    check :questionnaire_responses_5_matrix_row_2_choice_2_body

    check "questionnaire_tos_agreement"
    accept_confirm { click_on "Submit" }

    expect(page).to have_content("Edit your answers")
    click_on "Edit your answers"

    expect(page).to have_field("questionnaire_responses_0", with: "My first answer has changed")
    expect(page).to have_field("questionnaire_responses_1", with: "My long answer has changed")

    expect(page).to have_checked_field(:questionnaire_responses_2_choices_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_3_choices_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_4_matrix_row_0_choice_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_0_choice_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_1_choice_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_2_choice_2_body)
  end
end
