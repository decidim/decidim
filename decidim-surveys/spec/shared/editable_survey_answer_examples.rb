# frozen_string_literal: true

shared_examples "editable survey answers" do
  let(:options) do
    [
      { "body" => Decidim::Faker::Localized.sentence },
      { "body" => Decidim::Faker::Localized.sentence },
      { "body" => Decidim::Faker::Localized.sentence }
    ]
  end
  let(:sort_options) do
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
  let!(:single_option_question) { create(:questionnaire_question, position: 2, questionnaire:, question_type: :single_option, options:) }
  let!(:multiple_option_question) { create(:questionnaire_question, position: 3, questionnaire:, question_type: :multiple_option, options:) }
  let!(:matrix_single_question) { create(:questionnaire_question, position: 4, questionnaire:, question_type: :matrix_single, options:, rows: [rows.first]) }
  let!(:matrix_multiple_question) { create(:questionnaire_question, position: 5, questionnaire:, question_type: :matrix_multiple, options:, rows:) }
  let!(:file_question) { create(:questionnaire_question, position: 6, questionnaire:, question_type: :files) }
  let!(:sorting_question) { create(:questionnaire_question, position: 7, questionnaire:, question_type: :sorting, options: sort_options) }

  let(:answer_options) { sorting_question.answer_options }
  let(:drag_drop_script) do
    <<~JS
      var first = document.querySelectorAll('.answer-questionnaire__sorting')[0];
      var last = document.querySelectorAll('.answer-questionnaire__sorting')[2];
      last.parentNode.insertBefore(first, last.nextSibling);
      var event = new Event('sortupdate', {bubbles: true});
      document.querySelector('.js-sortable-check-box-collection').dispatchEvent(event);
    JS
  end

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

    dynamically_attach_file("questionnaire_responses_6_add_documents", Decidim::Dev.asset("city.jpeg"))

    page.execute_script "window.scrollBy(0,1800)"
    within ".js-sortable-check-box-collection" do
      drag_and_drop(first: answer_options.first, second: answer_options.second, last: answer_options.last)
    end

    check "questionnaire_tos_agreement"
    click_on "Submit"
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
    expect(page).to have_content("city.jpeg")

    fill_in "questionnaire_responses_0", with: "My first answer has changed"
    fill_in "questionnaire_responses_1", with: "My long answer has changed"

    choose :questionnaire_responses_2_choices_2_body
    check :questionnaire_responses_3_choices_2_body
    choose :questionnaire_responses_4_matrix_row_0_choice_2_body

    uncheck :questionnaire_responses_5_matrix_row_0_choice_0_body
    uncheck :questionnaire_responses_5_matrix_row_1_choice_0_body
    uncheck :questionnaire_responses_5_matrix_row_2_choice_0_body
    check :questionnaire_responses_5_matrix_row_0_choice_2_body
    check :questionnaire_responses_5_matrix_row_1_choice_2_body
    check :questionnaire_responses_5_matrix_row_2_choice_2_body

    dynamically_attach_file("questionnaire_responses_6_add_documents", Decidim::Dev.asset("city2.jpeg"), remove_before: true)

    page.execute_script "window.scrollBy(0,1800)"

    drag_and_drop(first: answer_options.second, second: answer_options.last, last: answer_options.first)

    check "questionnaire_tos_agreement"
    click_on "Submit"

    expect(page).to have_content("Edit your answers")
    click_on "Edit your answers"

    expect(page).to have_field("questionnaire_responses_0", with: "My first answer has changed")
    expect(page).to have_field("questionnaire_responses_1", with: "My long answer has changed")

    expect(page).to have_checked_field(:questionnaire_responses_2_choices_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_3_choices_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_4_matrix_row_0_choice_2_body)
    expect(page).to have_unchecked_field(:questionnaire_responses_5_matrix_row_0_choice_0_body)
    expect(page).to have_unchecked_field(:questionnaire_responses_5_matrix_row_1_choice_0_body)
    expect(page).to have_unchecked_field(:questionnaire_responses_5_matrix_row_2_choice_0_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_0_choice_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_1_choice_2_body)
    expect(page).to have_checked_field(:questionnaire_responses_5_matrix_row_2_choice_2_body)
    expect(page).to have_content("city2.jpeg")

    page.execute_script "window.scrollBy(0,1800)"
    within ".js-sortable-check-box-collection" do
      expect(decidim_escape_translated(answer_options.last.body)).to appear_before(decidim_escape_translated(answer_options.first.body))
      expect(decidim_escape_translated(answer_options.first.body)).to appear_before(decidim_escape_translated(answer_options.second.body))
    end
  end

  private

  # This method allows you to drag and drop 3 elements, dragging first element in last position
  # Each named argument refers to the order in which each element is expected to be found
  def drag_and_drop(first:, second:, last:)
    expect(decidim_escape_translated(first.body)).to appear_before(decidim_escape_translated(second.body))
    expect(decidim_escape_translated(second.body)).to appear_before(decidim_escape_translated(last.body))
    page.execute_script drag_drop_script
    expect(decidim_escape_translated(second.body)).to appear_before(decidim_escape_translated(last.body))
    expect(decidim_escape_translated(last.body)).to appear_before(decidim_escape_translated(first.body))
  end
end
