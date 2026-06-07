# frozen_string_literal: true

require "spec_helper"

require "decidim/forms/test/shared_examples/questionnaire_admin_access"

describe "Admin manages elections questions" do
  let(:current_organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: current_organization) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "elections") }
  let(:manifest_name) { "elections" }
  let!(:election) { create(:election, component: current_component) }

  include_context "when managing a component as an admin"

  it_behaves_like "questionnaire admin access", denied_error: 404

  it "opens a questions tab" do
    visit questions_edit_path
    expect(page).to have_text("Question must have at least two answers in order go to the next step.")
  end

  context "when an admin user add a question" do
    it "adds a question with response options" do
      visit questions_edit_path
      question_body = ["This is the first question", "This is the second question"]
      question_description = ["This is the first question description"]
      response_options_body = [
        ["This is the Q1 first option", "This is the Q1 second option", "This is the Q1 third option"],
        ["This is the Q2 first option", "This is the Q2 second option", "This is the Q2 third option"]
      ]

      click_on "Add question"
      click_on "Add question"
      expand_all_questions
      within "form.edit_questions" do
        page.all(".questionnaire-question").each_with_index do |question, idx|
          within question do
            fill_in find_nested_form_field_locator("body_en"), with: question_body[idx]
          end

          fill_in_editor find_nested_form_field_locator("description_en"), with: question_description[0]
        end

        page.all(".questionnaire-question").each do |question|
          within question do
            select "Single option", from: "Type"
            click_on "Add response option"
          end
        end

        page.all(".questionnaire-question").each_with_index do |question, question_idx|
          question.all(".questionnaire-question-response-option").each_with_index do |question_response_option, response_option_idx|
            within question_response_option do
              fill_in find_nested_form_field_locator("body_en"), with: response_options_body[question_idx][response_option_idx]
            end
          end
        end
      end

      click_on "Save and continue"

      expect(page).to have_callout("Questions updated successfully.")

      visit questions_edit_path
      expand_all_questions

      expect(page).to have_css("input[value='This is the first question']")
      expect(page).to have_text("This is the first question description")
      expect(page).to have_css("input[value='This is the Q1 first option']")
      expect(page).to have_css("input[value='This is the Q1 second option']")
      expect(page).to have_css("input[value='This is the Q1 third option']")
      expect(page).to have_css("input[value='This is the second question']")
      expect(page).to have_css("input[value='This is the Q2 first option']")
      expect(page).to have_css("input[value='This is the Q2 second option']")
      expect(page).to have_css("input[value='This is the Q2 third option']")
    end
  end

  context "when reordering questions with drag and drop", :js do
    let!(:question1) do
      create(:election_question, election:, body: first_body, position: 0)
    end

    let!(:question2) do
      create(:election_question, election:, body: second_body, position: 1)
    end

    let!(:question3) do
      create(:election_question, election:, body: third_body, position: 2)
    end

    let(:first_body) do
      { en: "First", ca: "Primera", es: "Primera" }
    end

    let(:second_body) do
      { en: "Second", ca: "Segona", es: "Segunda" }
    end

    let(:third_body) do
      { en: "Third", ca: "Tercera", es: "Tercera" }
    end

    before do
      visit questions_edit_path
      expand_all_questions
    end

    it "allows moving questions using drag and drop" do
      question_cards = all(".questionnaire-question")

      question_cards.each do |card|
        question_id = card[:id].split("_").last
        question_id = question_id.gsub("-field", "")
        expect(card.find("input[name='questions[#{question_id}][body_en]']").value).to be_present
      end

      page.execute_script(<<~JS)
        var questions = document.querySelectorAll('.questionnaire-question');
        var container = questions[0].parentNode;
        var second = questions[1];
        var first = questions[0];

        container.insertBefore(second, first);

        var updatedQuestions = container.querySelectorAll('.questionnaire-question');
        updatedQuestions.forEach(function(question, index) {
          var positionInput = question.querySelector('input[name$="[position]"]');
          if (positionInput) positionInput.value = index;
        });
      JS

      sleep 0.5

      question_cards.each do |card|
        question_id = card[:id].split("_").last
        question_id = question_id.gsub("-field", "")
        expect(card.find("input[name='questions[#{question_id}][body_en]']").value).to be_present
      end
    end

    it "persists drag and drop changes when saving" do
      response_options_body = [
        ["This is the Q1 first option", "This is the Q1 second option", "This is the Q1 third option"],
        ["This is the Q2 first option", "This is the Q2 second option", "This is the Q2 third option"],
        ["This is the Q3 first option", "This is the Q3 second option", "This is the Q3 third option"]
      ]

      page.all(".questionnaire-question").each do |question|
        within question do
          select "Single option", from: "Type"
        end
      end

      page.all(".questionnaire-question").each_with_index do |question, question_idx|
        question.all(".questionnaire-question-response-option").each_with_index do |question_response_option, response_option_idx|
          within question_response_option do
            fill_in find_nested_form_field_locator("body_en"), with: response_options_body[question_idx][response_option_idx]
          end
        end
      end

      page.execute_script(<<~JS)
        var questions = document.querySelectorAll('.questionnaire-question');
        var container = questions[0].parentNode;
        var second = questions[1];

        container.appendChild(second);

        var updatedQuestions = container.querySelectorAll('.questionnaire-question');
        updatedQuestions.forEach(function(question, index) {
          var positionInput = question.querySelector('input[name$="[position]"]');
          if (positionInput) positionInput.value = index;
        });
      JS

      sleep 0.5

      click_on "Save"
      expect(page).to have_callout("Questions updated successfully")

      # Returned to the saved questions to see their different positions
      visit questions_edit_path
      expand_all_questions

      question_cards = all(".questionnaire-question")

      within question_cards[0] do
        question_id = question_cards[0][:id].split("_").last.gsub("-field", "")
        expect(find("input[name='questions[#{question_id}][body_en]']").value).to eq("First")
      end
      within question_cards[1] do
        question_id = question_cards[1][:id].split("_").last.gsub("-field", "")
        expect(find("input[name='questions[#{question_id}][body_en]']").value).to eq("Third")
      end
      within question_cards[2] do
        question_id = question_cards[2][:id].split("_").last.gsub("-field", "")
        expect(find("input[name='questions[#{question_id}][body_en]']").value).to eq("Second")
      end
    end
  end

  context "when admin user deletes a question" do
    let!(:question) { create(:election_question, :with_response_options, body: { en: "first question" }, election:) }
    let!(:second_question) { create(:election_question, :with_response_options, body: { en: "second question" }, election:) }

    it "deletes a question with response options" do
      visit questions_edit_path
      expand_all_questions

      expect(page).to have_css("input[value='first question']")
      expect(page).to have_css("input[value='second question']")
      within "#accordion-questionnaire_question_#{question.id}-field" do
        accept_confirm do
          click_on "Remove"
        end
      end

      click_on "Save and continue"

      expect(page).to have_callout("Questions updated successfully.")

      visit questions_edit_path
      expand_all_questions

      expect(page).to have_no_css("input[value='first question']")
      expect(page).to have_css("input[value='second question']")
    end
  end

  context "when the election has started" do
    let!(:started_election) { create(:election, :published, :ongoing, component: current_component) }
    let!(:question) { create(:election_question, :with_response_options, election: started_election) }

    it "denies access to the questions edit page" do
      visit Decidim::EngineRouter.admin_proxy(current_component).edit_questions_election_path(started_election)

      expect(page).to have_text("You are not authorized to perform this action")
    end
  end

  context "when admin user sets max_choices for multiple_option question" do
    it "creates a question with max_choices" do
      visit questions_edit_path

      click_on "Add question"
      expand_all_questions

      within "form.edit_questions" do
        within page.all(".questionnaire-question").first do
          fill_in find_nested_form_field_locator("body_en"), with: "Select up to 2 options"
          select "Multiple option", from: "Type"

          3.times { click_on "Add response option" }

          page.all(".questionnaire-question-response-option").each_with_index do |option, idx|
            within option do
              fill_in find_nested_form_field_locator("body_en"), with: "Option #{idx + 1}"
            end
          end

          select "2", from: "Maximum number of choices"
        end
      end

      click_on "Save and continue"

      expect(page).to have_callout("Questions updated successfully.")

      visit questions_edit_path
      expand_all_questions

      expect(page).to have_css("input[value='Select up to 2 options']")
      expect(election.questions.last.max_choices).to eq(2)
    end

    it "updates max_choices on existing question" do
      question = create(:election_question, :with_response_options,
                        election:,
                        question_type: "multiple_option",
                        max_choices: nil)

      visit questions_edit_path
      find("#questionnaire_question_#{question.id}-button").click

      within "#accordion-questionnaire_question_#{question.id}-field" do
        select "2", from: "Maximum number of choices"
      end

      click_on "Save and continue"

      expect(page).to have_callout("Questions updated successfully.")
      expect(question.reload.max_choices).to eq(2)
    end

    it "shows 'Any' option for max_choices when unset" do
      question = create(:election_question, :with_response_options,
                        election:,
                        question_type: "multiple_option")

      visit questions_edit_path
      find("#questionnaire_question_#{question.id}-button").click

      within "#accordion-questionnaire_question_#{question.id}-field" do
        expect(page).to have_select("Maximum number of choices", selected: "Any")
      end
    end
  end

  private

  def find_nested_form_field_locator(attribute, visible: :visible)
    find_nested_form_field(attribute, visible:)["id"]
  end

  def find_nested_form_field(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:, match: :first)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end

  def expand_all_questions
    click_on "Expand all questions"
  end

  def questions_edit_path
    Decidim::EngineRouter.admin_proxy(current_component).edit_questions_election_path(election)
  end

  def manage_questions_path
    questions_edit_path
  end
end
