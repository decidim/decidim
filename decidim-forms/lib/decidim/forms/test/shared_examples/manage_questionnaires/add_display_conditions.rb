# frozen_string_literal: true

require "spec_helper"

shared_examples_for "add display conditions" do
  context "when adding display conditions to a question" do
    let!(:response_options) do
      3.times.to_a.map do |x|
        {
          "body" => Decidim::Faker::Localized.sentence,
          "free_text" => x == 2
        }
      end
    end

    context "when questionnaire has only one question" do
      let!(:question) { create(:questionnaire_question, questionnaire:, body:, question_type: "short_response") }

      before do
        click_on "Save"
        visit_manage_questions_and_expand_all
      end

      it "does not display an add display condition button" do
        expect(page).to have_no_button("Add display condition")
      end

      context "when creating a new question" do
        it "disables the add display condition button if the question has not been saved" do
          click_on "Add question"
          expand_all_questions

          expect(page).to have_button("Add display condition", disabled: true)
        end
      end
    end

    context "when questionnaire has more than one question" do
      let!(:question_short_response) do
        create(:questionnaire_question,
               position: 0,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "short_response")
      end
      let!(:question_long_response) do
        create(:questionnaire_question,
               position: 1,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "long_response")
      end
      let!(:question_single_option) do
        create(:questionnaire_question,
               position: 2,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "single_option",
               options: response_options)
      end
      let!(:question_multiple_option) do
        create(:questionnaire_question,
               position: 3,
               questionnaire:,
               body: Decidim::Faker::Localized.sentence,
               question_type: "multiple_option",
               options: response_options)
      end

      let(:questions) { [question_short_response, question_long_response, question_single_option, question_multiple_option] }

      before do
        click_on "Save"
        visit_manage_questions_and_expand_all
      end

      context "when clicking add display condition button" do
        it "adds a new display condition form with all correct elements" do
          within_add_display_condition do
            expect(page).to have_select("Question")
            expect(page).to have_select("Condition")
            expect(page).to have_css("[id$=mandatory]")

            select question_single_option.body["en"], from: "Question"
            select "Responded", from: "Condition"

            expect(page).to have_no_select("Response option")
            expect(page).to have_no_css("[id$=condition_value_en]", visible: :visible)

            select question_single_option.body["en"], from: "Question"
            select "Equal", from: "Condition"

            expect(page).to have_select("Response option")
            expect(page).to have_no_css("[id$=condition_value_en]", visible: :visible)
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
              select question_short_response.body["en"], from: "Question"

              options = ["Select a condition type", "Responded", "Not responded", "Includes text"]

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

              options = ["Select a condition type", "Responded", "Not responded", "Equal", "Not equal", "Includes text"]

              option_elements = page.all("select[id$=condition_type] option")
              option_elements = option_elements.to_a.reject { |option| option[:style].match? "display: none" }

              expect(option_elements.map(&:text)).to match_array(options)
            end
          end
        end

        it "fills response_options select with correct options" do
          within_add_display_condition do
            select question_single_option.body["en"], from: "Question"
            select "Equal", from: "Condition"

            options = response_options.map { |option| option["body"]["en"] }
            options << "Select response option"

            expect(page).to have_select("Response option", options:, wait: 5)
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
            expect(page).to have_css("[id$=mandatory]")
            expect(page).to have_no_css("[id$=mandatory][checked]")
          end
        end

        it "can be removed" do
          within_add_display_condition do
            click_on "Remove"
          end

          click_on "Save"

          expect(page).to have_admin_callout("successfully")
        end
      end
    end
  end
end
