# frozen_string_literal: true

require "spec_helper"

shared_examples_for "add display conditions" do
  context "when adding display conditions to a question" do
    let!(:answer_options) do
      3.times.to_a.map do |x|
        {
          "body" => Decidim::Faker::Localized.sentence,
          "free_text" => x == 2
        }
      end
    end

    context "when questionnaire has only one question" do
      let!(:question) { create(:questionnaire_question, questionnaire:, body:, question_type: "short_answer") }

      before do
        visit_questionnaire_edit_path_and_expand_all
      end

      it "doesn't display an add display condition button" do
        expect(page).to have_no_button("Add display condition")
      end

      context "when creating a new question" do
        it "disables the add display condition button if the question hasn't been saved" do
          within "form.edit_questionnaire" do
            click_button "Add question"
            expand_all_questions

            expect(page).to have_button("Add display condition", disabled: true)
          end
        end
      end
    end

    context "when questionnaire has more than one question" do
      let!(:question_short_answer) do
        create(:questionnaire_question,
               position: 0,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "short_answer")
      end
      let!(:question_long_answer) do
        create(:questionnaire_question,
               position: 1,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "long_answer")
      end
      let!(:question_single_option) do
        create(:questionnaire_question,
               position: 2,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "single_option",
               options: answer_options)
      end
      let!(:question_multiple_option) do
        create(:questionnaire_question,
               position: 3,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "multiple_option",
               options: answer_options)
      end

      let(:questions) { [question_short_answer, question_long_answer, question_single_option, question_multiple_option] }

      before do
        visit_questionnaire_edit_path_and_expand_all
      end

      context "when clicking add display condition button" do
        it "adds a new display condition form with all correct elements" do
          within "form.edit_questionnaire" do
            within_add_display_condition do
              expect(page).to have_select("Question")
              expect(page).to have_select("Condition")
              expect(page).to have_selector("[id$=mandatory]")

              select question_single_option.body["en"], from: "Question"
              select "Answered", from: "Condition"

              expect(page).to have_no_select("Answer option")
              expect(page).to have_no_css("[id$=condition_value_en]", visible: :visible)

              select question_single_option.body["en"], from: "Question"
              select "Equal", from: "Condition"

              expect(page).to have_select("Answer option")
              expect(page).to have_no_css("[id$=condition_value_en]", visible: :visible)
            end
          end
        end

        it "fills condition_question select with saved questions from questionnaire" do
          within_add_display_condition do
            options = questions.map { |question| question["body"]["en"] }
            options << "Select a question"
            expect(page).to have_select("Question", options:)

            within "select[id$=decidim_condition_question_id]" do
              elements = page.all("option[data-type]")
              expect(elements.map { |element| element[:"data-type"] }).to match_array(questions.map(&:question_type))
              expect(page.find("option[value='#{questions.last.id}']")).to be_disabled
            end
          end
        end

        context "when a text question is selected" do
          it "fills condition_type select with correct options" do
            within_add_display_condition do
              select question_short_answer.body["en"], from: "Question"

              options = ["Select a condition type", "Answered", "Not answered", "Includes text"]

              option_elements = page.all("select[id$=condition_type] option")
              option_elements = option_elements.to_a.reject { |option| option[:style].match? "display: none" }

              expect(option_elements.map(&:text)).to match_array(options)
            end
          end
        end

        context "when an options question is selected" do
          it "fills condition_type select with correct options" do
            within_add_display_condition do
              select question_single_option.body["en"], from: "Question"

              options = ["Select a condition type", "Answered", "Not answered", "Equal", "Not equal", "Includes text"]

              option_elements = page.all("select[id$=condition_type] option")
              option_elements = option_elements.to_a.reject { |option| option[:style].match? "display: none" }

              expect(option_elements.map(&:text)).to match_array(options)
            end
          end
        end

        it "fills answer_options select with correct options" do
          within_add_display_condition do
            select question_single_option.body["en"], from: "Question"
            select "Equal", from: "Condition"

            options = answer_options.map { |option| option["body"]["en"] }
            options << "Select answer option"

            expect(page).to have_select("Answer option", options:, wait: 5)
          end
        end

        it "loads an empty value field" do
          within_add_display_condition do
            select question_single_option.body["en"], from: "Question"
            select "Includes text", from: "Condition"
            expect(page).to have_nested_field("condition_value_en", with: "")
          end
        end

        it "loads a mandatory field with false value" do
          within_add_display_condition do
            expect(page).to have_selector("[id$=mandatory]")
            expect(page).to have_no_selector("[id$=mandatory][checked]")
          end
        end

        it "can be removed" do
          within_add_display_condition do
            click_button "Remove"
          end

          click_button "Save"

          expect(page).to have_admin_callout("successfully")
        end
      end
    end
  end
end
