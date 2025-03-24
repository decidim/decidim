# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has questionnaire" do
  context "when the user is not logged in" do
    it "does not allow responding the questionnaire" do
      visit questionnaire_public_path
      see_questionnaire_questions

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description, strip_tags: true)

      expect(page).to have_no_css(".form.response-questionnaire")

      within "[data-question-readonly]" do
        expect(page).to have_i18n_content(question.body)
      end
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "and there are no questions" do
      before do
        questionnaire.questions.delete_all
      end

      it "shows an empty page with a message" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_content("No questions configured for this form yet.")
      end
    end

    it "allows responding the questionnaire" do
      visit questionnaire_public_path

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description, strip_tags: true)

      see_questionnaire_questions

      fill_in question.body["en"], with: "My first response"

      check "questionnaire_tos_agreement"

      accept_confirm do
        click_on "Submit"
      end

      expect(page).to have_admin_callout(callout_success)

      visit questionnaire_public_path
      see_questionnaire_questions

      expect(page).to have_content("You have already responded this form.")
      expect(page).to have_no_i18n_content(question.body)
    end

    context "and there is a mandatory question" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "short_response",
          position: 0,
          mandatory: true
        )
      end

      before do
        visit questionnaire_public_path
      end

      it "it renders the asterisk as a separated element" do
        see_questionnaire_questions
        within "label.response-questionnaire__question-label" do
          expect(page).to have_content(translated_attribute(question.body).to_s)
          within "span.label-required.has-tip" do
            expect(page).to have_content("*")
            expect(page).to have_content("Required field")
          end
        end
      end
    end

    context "with multiple steps" do
      let!(:separator) { create(:questionnaire_question, questionnaire:, position: 1, question_type: :separator) }
      let!(:question2) { create(:questionnaire_question, questionnaire:, position: 2) }

      before do
        visit questionnaire_public_path
        see_questionnaire_questions
      end

      it "allows responding the first questionnaire" do
        expect(page).to have_content("Step 1 of 2")

        within ".response-questionnaire__submit", match: :first do
          expect(page).to have_no_content("Back")
        end

        response_first_questionnaire

        expect(page).to have_no_css(".success.flash")
      end

      it "allows revisiting previously-responded questionnaires with my responses" do
        response_first_questionnaire

        click_on "Back"

        expect(page).to have_content("Step 1 of 2")
        expect(page).to have_field("questionnaire_responses_0", with: "My first response")
      end

      it "finishes the submission when responding the last questionnaire" do
        response_first_questionnaire

        check "questionnaire_tos_agreement"
        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout(callout_success)

        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_content("You have already responded this form.")
      end

      def response_first_questionnaire
        within "#step-0" do
          expect(page).to have_no_css("#questionnaire_tos_agreement")

          fill_in question.body["en"], with: "My first response"
          click_on "Continue"
        end
        expect(page).to have_content("Step 2 of 2")
      end
    end

    it "requires confirmation when exiting mid-responding" do
      visit questionnaire_public_path
      see_questionnaire_questions

      fill_in question.body["en"], with: "My first response"

      click_on translated_attribute(component.name)

      expect(page).to have_current_path(questionnaire_public_path)
    end

    context "when the questionnaire has already been responded by someone else" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "single_option",
          position: 0,
          options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        response = create(:response, id: 1, questionnaire:, question:)

        response.choices.create!(
          response_option: Decidim::Forms::ResponseOption.first,
          body: "Lalalilo"
        )
      end

      it "does not leak defaults from other responses" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_no_field(type: "radio", checked: true)
      end
    end

    shared_examples_for "a correctly ordered questionnaire" do
      it "displays the questions ordered by position starting with one" do
        form_fields = all(".response-questionnaire__question")

        expect(form_fields[0]).to have_i18n_content(question.body)
        expect(form_fields[1]).to have_i18n_content(other_question.body)
        2.times do |index|
          expect(form_fields[index]).to have_css("[data-response-idx='#{index + 1}']")
        end
      end
    end

    context "and submitting a fresh form" do
      let!(:other_question) { create(:questionnaire_question, questionnaire:, position: 1) }

      before do
        visit questionnaire_public_path
        see_questionnaire_questions
      end

      it_behaves_like "a correctly ordered questionnaire"
    end

    context "and rendering a form after errors" do
      let!(:other_question) { create(:questionnaire_question, questionnaire:, position: 1) }

      before do
        visit questionnaire_public_path
        see_questionnaire_questions
        accept_confirm { click_on "Submit" }
      end

      it_behaves_like "a correctly ordered questionnaire"
    end

    shared_context "when a non multiple choice question is mandatory" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "short_response",
          position: 0,
          mandatory: true
        )
      end

      before do
        visit questionnaire_public_path
        see_questionnaire_questions

        check "questionnaire_tos_agreement"
      end
    end

    shared_examples_for "question has a character limit" do
      context "when max_characters value is positive" do
        let(:max_characters) { 30 }

        it "shows a message indicating number of characters left" do
          visit questionnaire_public_path
          see_questionnaire_questions

          expect(page).to have_content("30 characters left")
        end
      end

      context "when max_characters value is 0" do
        let(:max_characters) { 0 }

        it "does not show message indicating number of characters left" do
          visit questionnaire_public_path

          expect(page).to have_no_content("characters left")
        end
      end
    end

    describe "leaving a blank question (without js)", driver: :rack_test do
      include_context "when a non multiple choice question is mandatory"

      before do
        click_on "Submit"
      end

      it "submits the form and shows errors" do
        expect(page).to have_admin_callout(callout_failure)
        expect(page).to have_content("cannot be blank")
      end
    end

    describe "leaving a blank question (with js)" do
      include_context "when a non multiple choice question is mandatory"

      before do
        accept_confirm { click_on "Submit" }
      end

      it "shows errors without submitting the form" do
        expect(page).to have_no_css ".alert.flash"
        different_error = I18n.t("decidim.forms.questionnaires.response.max_choices_alert")
        expect(different_error).to eq("There are too many choices selected")
        expect(page).to have_no_content(different_error)

        expect(page).to have_content("cannot be blank")
      end
    end

    describe "leaving a blank multiple choice question" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "single_option",
          position: 0,
          mandatory: true,
          options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        visit questionnaire_public_path
        see_questionnaire_questions

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }
      end

      it "submits the form and shows errors" do
        expect(page).to have_admin_callout(callout_failure)
        expect(page).to have_content("cannot be blank")
      end
    end

    context "when a question has a rich text description" do
      let!(:question) { create(:questionnaire_question, questionnaire:, position: 0, description: { en: "<b>This question is important</b>" }) }

      it "properly interprets HTML descriptions" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_css("b", text: "This question is important")
      end
    end

    describe "free text options" do
      let(:response_option_bodies) { Array.new(3) { Decidim::Faker::Localized.sentence } }
      let(:max_characters) { 0 }
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type:,
          max_characters:,
          position: 1,
          options: [
            { "body" => response_option_bodies[0] },
            { "body" => response_option_bodies[1] },
            { "body" => response_option_bodies[2], "free_text" => true }
          ]
        )
      end

      let!(:other_question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "multiple_option",
          max_choices: 2,
          position: 2,
          options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        visit questionnaire_public_path
        see_questionnaire_questions
      end

      context "when question is single_option type" do
        let(:question_type) { "single_option" }

        it "renders them as radio buttons with attached text fields disabled by default" do
          expect(page).to have_css(".js-radio-button-collection input[type=radio]", count: 3)

          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", disabled: true, count: 1)

          choose response_option_bodies[2]["en"]

          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", disabled: false, count: 1)
        end

        it "saves the free text in a separate field if submission correct" do
          choose response_option_bodies[2]["en"]
          fill_in "questionnaire_responses_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout(callout_success)
          expect(Decidim::Forms::Response.first.choices.first.custom_body).to eq("Cacatua")
        end

        it "preserves the previous custom body if submission not correct" do
          check other_question.response_options.first.body["en"]
          check other_question.response_options.second.body["en"]
          check other_question.response_options.third.body["en"]

          choose response_option_bodies[2]["en"]
          fill_in "questionnaire_responses_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout("There was a problem responding")
          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", with: "Cacatua")
        end

        it_behaves_like "question has a character limit"
      end

      context "when question is multiple_option type" do
        let(:question_type) { "multiple_option" }

        it "renders them as check boxes with attached text fields disabled by default" do
          expect(page.first(".js-check-box-collection")).to have_field(type: "checkbox", count: 3)

          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", disabled: true, count: 1)

          check response_option_bodies[2]["en"]

          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", disabled: false, count: 1)
        end

        it "saves the free text in a separate field if submission correct" do
          check response_option_bodies[2]["en"]
          fill_in "questionnaire_responses_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout(callout_success)
          expect(Decidim::Forms::Response.first.choices.first.custom_body).to eq("Cacatua")
        end

        it "preserves the previous custom body if submission not correct" do
          check "questionnaire_responses_1_choices_0_body"
          check "questionnaire_responses_1_choices_1_body"
          check "questionnaire_responses_1_choices_2_body"

          check response_option_bodies[2]["en"]
          fill_in "questionnaire_responses_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout("There was a problem responding")
          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", with: "Cacatua")
        end

        it_behaves_like "question has a character limit"
      end
    end

    context "when question type is long response" do
      let(:max_characters) { 0 }
      let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "long_response", max_characters:) }

      it "renders the response as a textarea" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_css("textarea#questionnaire_responses_0")
      end

      it_behaves_like "question has a character limit"
    end

    context "when question type is short response" do
      let(:max_characters) { 0 }
      let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "short_response", max_characters:) }

      it "renders the response as a text field" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_field(id: "questionnaire_responses_0")
      end

      it_behaves_like "question has a character limit"
    end

    context "when question type is single option" do
      let(:response_options) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "single_option", options: response_options) }

      it "renders responses as a collection of radio buttons" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_css(".js-radio-button-collection input[type=radio]", count: 2)

        choose response_options[0]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout(callout_success)

        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_content("You have already responded this form.")
        expect(page).to have_no_i18n_content(question.body)
      end
    end

    context "when question type is multiple option" do
      let(:response_options) { Array.new(3) { { "body" => Decidim::Faker::Localized.sentence } } }
      let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "multiple_option", options: response_options) }

      it "renders responses as a collection of radio buttons" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_css(".js-check-box-collection input[type=checkbox]", count: 3)

        expect(page).to have_no_content("Max choices:")

        check response_options[0]["body"][:en]
        check response_options[1]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout(callout_success)

        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_content("You have already responded this form.")
        expect(page).to have_no_i18n_content(question.body)
      end

      it "respects the max number of choices" do
        question.update!(max_choices: 2)

        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_content("Max choices: 2")

        check response_options[0]["body"][:en]
        check response_options[1]["body"][:en]
        check response_options[2]["body"][:en]

        expect(page).to have_content("too many choices")

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout("There was a problem responding")
        expect(page).to have_content("are too many")

        uncheck response_options[2]["body"][:en]

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout(callout_success)
      end
    end

    context "when question type is sorting" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "sorting",
          options: [
            { "body" => { "en" => "chocolate" } },
            { "body" => { "en" => "like" } },
            { "body" => { "en" => "We" } },
            { "body" => { "en" => "dark" } },
            { "body" => { "en" => "all" } }
          ]
        )
      end

      it "renders the question responses as a collection of divs sortable on drag and drop" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_css("div.response-questionnaire__sorting.js-collection-input", count: 5)

        %w(We all like dark chocolate).each do |term|
          expect(page).to have_content(term)
        end
      end

      it "properly saves valid sortings" do
        visit questionnaire_public_path
        see_questionnaire_questions

        %w(We all like dark chocolate).reverse.each do |text|
          find("div.response-questionnaire__sorting", text:).drag_to(find("div.response-questionnaire__sorting", match: :first))
        end

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout(callout_success)
        expect(Decidim::Forms::Response.first.choices.pluck(:position, :body)).to eq(
          [[0, "We"], [1, "all"], [2, "like"], [3, "dark"], [4, "chocolate"]]
        )
      end
    end

    context "when question type is matrix_single" do
      let(:matrix_rows) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:response_options) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:mandatory) { false }

      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "matrix_single",
          rows: matrix_rows,
          options: response_options,
          mandatory:
        )
      end

      it "renders the question responses as a collection of radio buttons" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_css(".js-radio-button-collection input[type=radio]", count: 4)

        expect(page).to have_content(matrix_rows.map { |row| row["body"]["en"] }.join("\n"))
        expect(page).to have_content(response_options.map { |option| option["body"]["en"] }.join(" "))

        radio_buttons = page.all(".js-radio-button-collection input[type=radio]")

        choose radio_buttons.first[:id]
        choose radio_buttons.last[:id]

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout(callout_success)

        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_content("You have already responded this form.")
        expect(page).to have_no_i18n_content(question.body)

        first_choice, last_choice = Decidim::Forms::Response.last.choices.pluck(:decidim_response_option_id, :decidim_question_matrix_row_id)

        expect(first_choice).to eq([question.response_options.first.id, question.matrix_rows.first.id])
        expect(last_choice).to eq([question.response_options.last.id, question.matrix_rows.last.id])
      end

      it "preserves the chosen responses if submission not correct" do
        visit questionnaire_public_path
        see_questionnaire_questions

        radio_buttons = page.all(".js-radio-button-collection input[type=radio]")
        choose radio_buttons[1][:id]

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout("There was a problem responding")

        radio_buttons = page.all(".js-radio-button-collection input[type=radio]")
        expect(radio_buttons.pluck(:checked)).to eq([nil, "true", nil, nil])
      end

      context "when the question is mandatory and the response is not complete" do
        let!(:mandatory) { true }

        it "shows an error if the question is mandatory and the response is not complete" do
          visit questionnaire_public_path
          see_questionnaire_questions

          radio_buttons = page.all(".js-radio-button-collection input[type=radio]")
          choose radio_buttons[0][:id]

          check "questionnaire_tos_agreement"
          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout("There was a problem responding")
          expect(page).to have_content("Choices are not complete")
        end
      end
    end

    context "when question type is matrix_multiple" do
      let(:matrix_rows) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:response_options) { Array.new(3) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:max_choices) { nil }
      let(:mandatory) { false }

      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          question_type: "matrix_multiple",
          rows: matrix_rows,
          options: response_options,
          max_choices:,
          mandatory:
        )
      end

      it "renders the question responses as a collection of check boxes" do
        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_css(".js-check-box-collection input[type=checkbox]", count: 6)

        expect(page).to have_content(matrix_rows.map { |row| row["body"]["en"] }.join("\n"))
        expect(page).to have_content(response_options.map { |option| option["body"]["en"] }.join(" "))

        checkboxes = page.all(".js-check-box-collection input[type=checkbox]")

        check checkboxes[0][:id]
        check checkboxes[1][:id]
        check checkboxes[3][:id]

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

        expect(page).to have_admin_callout(callout_success)

        visit questionnaire_public_path
        see_questionnaire_questions

        expect(page).to have_content("You have already responded this form.")
        expect(page).to have_no_i18n_content(question.body)

        first_choice, second_choice, third_choice = Decidim::Forms::Response.last.choices.pluck(:decidim_response_option_id, :decidim_question_matrix_row_id)

        expect(first_choice).to eq([question.response_options.first.id, question.matrix_rows.first.id])
        expect(second_choice).to eq([question.response_options.second.id, question.matrix_rows.first.id])
        expect(third_choice).to eq([question.response_options.first.id, question.matrix_rows.last.id])
      end

      context "when the question has max_choices defined" do
        let!(:max_choices) { 2 }

        it "respects the max number of choices" do
          visit questionnaire_public_path
          see_questionnaire_questions

          expect(page).to have_content("Max choices: 2")

          checkboxes = page.all(".js-check-box-collection input[type=checkbox]")

          check checkboxes[0][:id]
          check checkboxes[1][:id]
          check checkboxes[2][:id]

          expect(page).to have_content("too many choices")

          check checkboxes[3][:id]
          check checkboxes[4][:id]

          expect(page).to have_content("too many choices")

          check checkboxes[5][:id]

          uncheck checkboxes[0][:id]

          expect(page).to have_content("too many choices")

          check "questionnaire_tos_agreement"

          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout("There was a problem responding")
          expect(page).to have_content("are too many")

          checkboxes = page.all(".js-check-box-collection input[type=checkbox]")

          uncheck checkboxes[5][:id]

          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout(callout_success)
        end
      end

      context "when the question is mandatory and the response is not complete" do
        let!(:mandatory) { true }

        it "shows an error" do
          visit questionnaire_public_path
          see_questionnaire_questions

          checkboxes = page.all(".js-check-box-collection input[type=checkbox]")
          check checkboxes[0][:id]

          check "questionnaire_tos_agreement"
          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout("There was a problem responding")
          expect(page).to have_content("Choices are not complete")
        end
      end

      context "when the submission is not correct" do
        let!(:max_choices) { 2 }

        it "preserves the chosen responses" do
          visit questionnaire_public_path
          see_questionnaire_questions

          checkboxes = page.all(".js-check-box-collection input[type=checkbox]")
          check checkboxes[0][:id]
          check checkboxes[1][:id]
          check checkboxes[2][:id]
          check checkboxes[5][:id]

          check "questionnaire_tos_agreement"
          accept_confirm { click_on "Submit" }

          expect(page).to have_admin_callout("There was a problem responding")

          checkboxes = page.all(".js-check-box-collection input[type=checkbox]")
          expect(checkboxes.pluck(:checked)).to eq(["true", "true", "true", nil, nil, "true"])
        end
      end
    end

    describe "display conditions" do
      let(:response_options) do
        3.times.to_a.map do |x|
          {
            "body" => Decidim::Faker::Localized.sentence,
            "free_text" => x == 2
          }
        end
      end
      let(:condition_question_options) { [] }
      let!(:question) { create(:questionnaire_question, questionnaire:, position: 2) }
      let!(:conditioned_question_id) { "#questionnaire_responses_1" }
      let!(:condition_question) do
        create(:questionnaire_question,
               questionnaire:,
               question_type: condition_question_type,
               position: 1,
               options: condition_question_options)
      end

      context "when a question has a display condition" do
        context "when condition is of type 'responded'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "responded",
                   question:,
                   condition_question:)
          end

          before do
            visit questionnaire_public_path
            see_questionnaire_questions
          end

          context "when the condition_question type is short response" do
            let!(:condition_question_type) { "short_response" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_responses_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: ""
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is long response" do
            let!(:condition_question_type) { "long_response" }
            let!(:conditioned_question_id) { "#questionnaire_responses_0" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_responses_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: ""
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)

              choose condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)

              uncheck condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'not_responded'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "not_responded",
                   question:,
                   condition_question:)
          end

          before do
            visit questionnaire_public_path
            see_questionnaire_questions
          end

          context "when the condition_question type is short response" do
            let!(:condition_question_type) { "short_response" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)

              fill_in "questionnaire_responses_0", with: ""
              change_focus

              expect_question_to_be_visible(true)
            end
          end

          context "when the condition_question type is long response" do
            let!(:condition_question_type) { "long_response" }
            let!(:conditioned_question_id) { "#questionnaire_responses_0" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)

              fill_in "questionnaire_responses_0", with: ""
              change_focus

              expect_question_to_be_visible(true)
            end
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              choose condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              check condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(false)

              uncheck condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'equal'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "equal",
                   question:,
                   condition_question:,
                   response_option: condition_question.response_options.first)
          end

          before do
            visit questionnaire_public_path
            see_questionnaire_questions
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)

              choose condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)

              uncheck condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'not_equal'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "not_equal",
                   question:,
                   condition_question:,
                   response_option: condition_question.response_options.first)
          end

          before do
            visit questionnaire_public_path
            see_questionnaire_questions
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(true)

              choose condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { response_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(true)

              uncheck condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.response_options.second.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'match'" do
          let!(:condition_value) { { en: "something" } }
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "match",
                   question:,
                   condition_question:,
                   condition_value:)
          end

          before do
            visit questionnaire_public_path
            see_questionnaire_questions
          end

          context "when the condition_question type is short response" do
            let!(:condition_question_type) { "short_response" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_responses_0", with: "Are not we all expecting #{condition_value[:en]}?"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: "Now upcase #{condition_value[:en].upcase}!"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is long response" do
            let!(:condition_question_type) { "long_response" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_responses_0", with: "Are not we all expecting #{condition_value[:en]}?"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: "Now upcase #{condition_value[:en].upcase}!"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_responses_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { response_options }
            let!(:condition_value) { { en: condition_question.response_options.first.body["en"].split.second.upcase } }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.response_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end

          context "when the condition_question type is single option with free text" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { response_options }
            let!(:condition_value) { { en: "forty two" } }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.response_options.third.body["en"]
              fill_in "questionnaire_responses_0_choices_2_custom_body", with: "The response is #{condition_value[:en]}"
              change_focus

              expect_question_to_be_visible(true)

              choose condition_question.response_options.first.body["en"]
              expect_question_to_be_visible(false)

              choose condition_question.response_options.third.body["en"]
              fill_in "questionnaire_responses_0_choices_2_custom_body", with: "oh no not 42 again"
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { response_options }
            let!(:condition_value) { { en: "forty two" } }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.response_options.third.body["en"]
              fill_in "questionnaire_responses_0_choices_2_custom_body", with: "The response is #{condition_value[:en]}"
              change_focus

              expect_question_to_be_visible(true)

              check condition_question.response_options.first.body["en"]
              expect_question_to_be_visible(true)

              uncheck condition_question.response_options.third.body["en"]
              expect_question_to_be_visible(false)

              check condition_question.response_options.third.body["en"]
              fill_in "questionnaire_responses_0_choices_2_custom_body", with: "oh no not 42 again"
              change_focus

              expect_question_to_be_visible(false)
            end
          end
        end
      end

      context "when a question has multiple display conditions" do
        before do
          visit questionnaire_public_path
          see_questionnaire_questions
        end

        context "when all conditions are mandatory" do
          let!(:condition_question_type) { "single_option" }
          let!(:condition_question_options) { response_options }
          let!(:display_conditions) do
            [
              create(:display_condition,
                     condition_type: "responded",
                     question:,
                     condition_question:,
                     mandatory: true),
              create(:display_condition,
                     condition_type: "not_equal",
                     question:,
                     condition_question:,
                     mandatory: true,
                     response_option: condition_question.response_options.second)
            ]
          end

          it "is displayed only if all conditions are fulfilled" do
            expect_question_to_be_visible(false)

            choose condition_question.response_options.second.body["en"]

            expect_question_to_be_visible(false)

            choose condition_question.response_options.first.body["en"]

            expect_question_to_be_visible(true)
          end
        end

        context "when all conditions are non-mandatory" do
          let!(:condition_question_type) { "multiple_option" }
          let!(:condition_question_options) { response_options }
          let!(:display_conditions) do
            [
              create(:display_condition,
                     condition_type: "equal",
                     question:,
                     condition_question:,
                     mandatory: false,
                     response_option: condition_question.response_options.first),
              create(:display_condition,
                     condition_type: "not_equal",
                     question:,
                     condition_question:,
                     mandatory: false,
                     response_option: condition_question.response_options.third)
            ]
          end

          it "is displayed if any of the conditions is fulfilled" do
            expect_question_to_be_visible(false)

            check condition_question.response_options.first.body["en"]

            expect_question_to_be_visible(true)

            uncheck condition_question.response_options.first.body["en"]
            check condition_question.response_options.second.body["en"]

            expect_question_to_be_visible(true)

            check condition_question.response_options.first.body["en"]

            expect_question_to_be_visible(true)
          end
        end

        context "when a mandatory question has conditions that have not been fulfilled" do
          let!(:condition_question_type) { "short_response" }
          let!(:question) { create(:questionnaire_question, questionnaire:, position: 2, mandatory: true) }
          let!(:display_conditions) do
            [
              create(:display_condition,
                     condition_type: "match",
                     question:,
                     condition_question:,
                     condition_value: { en: "hey", es: "ey", ca: "ei" },
                     mandatory: true)
            ]
          end

          it "does not throw error" do
            visit questionnaire_public_path
            see_questionnaire_questions

            fill_in condition_question.body["en"], with: "My first response"

            check "questionnaire_tos_agreement"

            accept_confirm { click_on "Submit" }

            expect(page).to have_admin_callout(callout_success)
          end
        end
      end
    end

    private

    def expect_question_to_be_visible(visible)
      expect(page).to have_css(conditioned_question_id, visible:)
    end

    def change_focus
      check "questionnaire_tos_agreement"
    end
  end
end
