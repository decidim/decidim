# frozen_string_literal: true

require "spec_helper"

describe "Question ordering", "#reorder_questions" do
  let(:manifest_name) { "surveys" }
  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:,
           published_at: nil)
  end
  let!(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create(:survey, :published, :clean_after_publish, component:, questionnaire:) }
  let!(:first_question) { create(:questionnaire_question, questionnaire:, body: { en: "First question" }, position: 0) }
  let!(:second_question) { create(:questionnaire_question, questionnaire:, body: { en: "Second question" }, position: 1) }

  include_context "when managing a component as an admin"

  before do
    within "tr", text: decidim_sanitize_translated(survey.title) do
      find("button[data-controller='dropdown']").click
      click_on "Questions"
    end
  end

  it "shows questions in the correct order" do
    expect(page).to have_content("First question #1")
    expect(page).to have_content("Second question #2")
  end

  it "updates positions after adding a new question", :js do
    click_on "Add question"

    expect(page).to have_content("First question #1")
    expect(page).to have_content("Second question #2")
    expect(page).to have_content("Question #3")
  end

  it "can add and save new questions with correct positions", :js do
    click_on "Add question"

    expand_all_questions

    within ".questionnaire-question:last-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Third question"
    end

    click_on "Save"
    expect(page).to have_callout("Survey questions successfully saved.")

    expect(page).to have_content("First question #1")
    expect(page).to have_content("Second question #2")
    expect(page).to have_content("Third question #3")
  end

  it "allows reordering a newly added question", :js do
    create_and_fill_third_question

    drag_latest_question_to_first

    ordered_headers = question_headers
    expect(ordered_headers[0]).to include("Third question #1")
    expect(ordered_headers[1]).to include("First question #2")
    expect(ordered_headers[2]).to include("Second question #3")
  end

  it "persists the reordered questions after saving", :js do
    create_and_fill_third_question

    drag_latest_question_to_first

    click_on "Save"
    expect(page).to have_callout("Survey questions successfully saved.")

    ordered_headers = question_headers
    expect(ordered_headers[0]).to include("Third question #1")
    expect(ordered_headers[1]).to include("First question #2")
    expect(ordered_headers[2]).to include("Second question #3")
  end

  def expand_all_questions
    find(".button.expand-all").click
  end

  def find_nested_form_field_locator(attribute, visible: :visible)
    find_nested_form_field(attribute, visible:)["id"]
  end

  def find_nested_form_field(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end

  def create_and_fill_third_question
    click_on "Add question"

    expand_all_questions

    within ".questionnaire-question:last-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Third question"
    end
  end

  def drag_latest_question_to_first
    draggable_questions = all(".questionnaire-question .card-divider")
    draggable_questions.last.drag_to(draggable_questions.first)
  end

  def question_headers
    all(".questionnaire-question .card-divider").map(&:text)
  end
end
