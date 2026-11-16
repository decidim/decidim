# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe ResponseForm do
      subject do
        described_class.from_model(response).with_context(context)
      end

      let(:context) do
        {
          responses:
        }
      end
      let(:responses) { [] }
      let(:mandatory) { false }
      let(:question_type) { "short_response" }
      let(:max_choices) { nil }
      let(:max_characters) { 0 }

      let!(:questionable) { create(:dummy_resource) }
      let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }
      let!(:user) { create(:user, organization: questionable.organization) }

      let(:options) do
        [
          { "body" => Decidim::Faker::Localized.sentence },
          { "body" => Decidim::Faker::Localized.sentence },
          { "body" => Decidim::Faker::Localized.sentence }
        ]
      end

      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire:,
          mandatory:,
          question_type:,
          max_choices:,
          max_characters:,
          options:
        )
      end

      let(:body) { Decidim::Faker::Localized.sentence }
      let!(:response) { build(:response, user:, questionnaire:, question:, body:) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the question is mandatory" do
        let(:mandatory) { true }

        context "and question type is not multiple choice" do
          let(:question_type) { "long_response" }

          it "is not valid if body is not present" do
            subject.body = nil
            expect(subject).not_to be_valid

            subject.body = ""
            expect(subject).not_to be_valid
          end
        end

        context "and question type is multiple choice" do
          let(:question_type) { "multiple_option" }

          it "is not valid if choices are empty" do
            subject.choices = []
            expect(subject).not_to be_valid
          end
        end

        context "and question type is files" do
          let(:question_type) { "files" }
          let(:uploaded_files) do
            [
              Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
              Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")
            ]
          end

          context "when the body is empty" do
            before do
              subject.body = nil
              subject.add_attachments = uploaded_files
            end

            it "is valid" do
              expect(subject).to be_valid
            end
          end

          context "when there are no uploaded files" do
            before do
              subject.add_attachments = nil
            end

            it "is not valid if there are no files" do
              expect(subject).not_to be_valid
            end
          end
        end

        context "and question has display conditions" do
          let(:question_type) { "short_response" }
          let!(:condition_question) { create(:questionnaire_question, questionnaire:, question_type:) }
          let!(:display_condition) { create(:display_condition, question:, condition_question:, condition_type: :responded) }
          let(:the_response) { "" }
          let(:attributes) do
            {
              question_id: condition_question.id,
              body: the_response
            }
          end

          before do
            subject.body = nil
          end

          context "and display_conditions are not fulfilled" do
            it "is valid" do
              expect(subject).to be_valid
            end
          end

          context "and display_conditions are fulfilled" do
            let(:responses) do
              [ResponseForm.from_params(attributes)]
            end
            let(:the_response) { "The response" }

            it "is not valid" do
              expect(subject).not_to be_valid
            end
          end
        end
      end

      context "when the question has max_choices set" do
        let(:question_type) { "multiple_option" }

        let(:max_choices) { 2 }

        it "is valid if few enough options checked" do
          subject.choices = [
            { "response_option_id" => "1", "body" => "foo" },
            { "response_option_id" => "2", "body" => "bar" }
          ]

          expect(subject).to be_valid
        end

        it "is not valid if too many options checked" do
          subject.choices = [
            { "response_option_id" => "1", "body" => "foo" },
            { "response_option_id" => "2", "body" => "bar" },
            { "response_option_id" => "3", "body" => "baz" }
          ]

          expect(subject).not_to be_valid
        end

        context "and it is a matrix_multiple question" do
          let(:question_type) { "matrix_multiple" }

          let(:max_choices) { 2 }

          it "is valid if few enough options checked" do
            subject.choices = [
              { "response_option_id" => "1", "body" => "foo", "matrix_row_id" => "1" },
              { "response_option_id" => "2", "body" => "bar", "matrix_row_id" => "1" }
            ]

            expect(subject).to be_valid
          end

          it "is not valid if too many options checked" do
            subject.choices = [
              { "response_option_id" => "1", "body" => "foo", "matrix_row_id" => "1" },
              { "response_option_id" => "2", "body" => "bar", "matrix_row_id" => "1" },
              { "response_option_id" => "3", "body" => "baz", "matrix_row_id" => "1" }
            ]

            expect(subject).not_to be_valid
          end
        end
      end

      context "when the question is sorting" do
        let(:question_type) { "sorting" }

        it "is valid if all options checked" do
          subject.choices = [
            { "response_option_id" => "1", "body" => "foo" },
            { "response_option_id" => "2", "body" => "bar" },
            { "response_option_id" => "3", "body" => "baz" }
          ]

          expect(subject).to be_valid
        end

        it "is not valid if not all options checked" do
          subject.choices = [
            { "response_option_id" => "1", "body" => "foo" },
            { "response_option_id" => "2", "body" => "bar" }
          ]

          expect(subject).not_to be_valid
        end
      end

      context "when the question type is matrix" do
        let(:question_type) { "matrix_multiple" }

        before do
          subject.choices = [
            { "response_option_id" => "1", "body" => "foo", "matrix_row_id" => "3" },
            { "response_option_id" => "2", "body" => "bar", "matrix_row_id" => "2" },
            { "response_option_id" => "3", "body" => "baz", "matrix_row_id" => "1" }
          ]
        end

        it "is valid when defining attribute matrix_row_id for each choice" do
          expect(subject).to be_valid
        end

        it "saves correct matrix_row_id for each choice" do
          expect(subject.choices.map(&:matrix_row_id)).to eq [3, 2, 1]
        end
      end

      context "when the question has a character limit" do
        let(:max_characters) { 30 }

        context "when the question has a text response" do
          let(:question_type) { "short_response" }
          let!(:response) { build(:response, user:, questionnaire:, question:, body: "This response is very very very long") }

          it "is not valid if the response is too long" do
            expect(subject).not_to be_valid
          end
        end

        context "when the option has choices" do
          let(:question_type) { "multiple_option" }
          let(:body) { nil }
          let(:options) do
            [
              { "body" => Decidim::Faker::Localized.sentence },
              { "body" => Decidim::Faker::Localized.sentence },
              { "body" => Decidim::Faker::Localized.sentence, "free_text" => "1" }
            ]
          end

          it "is not valid if a free_text response is too long" do
            subject.choices = [
              { "response_option_id" => "1", "body" => "foo" },
              { "response_option_id" => "3", "custom_body" => "I am a very long string that will exceed character limit" }
            ]

            expect(subject).not_to be_valid
          end
        end
      end

      describe "#value" do
        subject(:form) { described_class.from_model(Decidim::Forms::Response.new(question:)) }

        let(:question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type:) }
        let(:options) { question.response_options }
        let(:rows) { create_list(:question_matrix_row, 2, question:) }

        context "with a text question" do
          let(:question_type) { "short_response" }

          it "returns the body and nil when blank" do
            form.body = "hello"
            expect(form.value).to eq("hello")
            form.body = " "
            expect(form.value).to be_nil
          end
        end

        context "with a single option question" do
          let(:question_type) { "single_option" }

          it "returns one choice with its free text" do
            form.choices = [{ "response_option_id" => options[1].id, "body" => "B", "custom_body" => "mine" }]
            expect(form.value).to eq("option" => options[1].id, "text" => "mine")
          end

          it "is nil when nothing is selected" do
            form.choices = [{ "response_option_id" => options[1].id }]
            expect(form.value).to be_nil
          end
        end

        context "with a multiple option question" do
          let(:question_type) { "multiple_option" }

          it "keeps the selected choices only and drops blank free text" do
            form.choices = [{ "response_option_id" => options[0].id, "body" => "A", "custom_body" => "" }, { "response_option_id" => options[2].id }]
            expect(form.value).to eq([{ "option" => options[0].id }])
          end
        end

        context "with a sorting question" do
          let(:question_type) { "sorting" }

          it "uses the array order as rank" do
            form.choices = [{ "response_option_id" => options[2].id, "body" => "C" }, { "response_option_id" => options[0].id, "body" => "A" }, { "response_option_id" => options[1].id, "body" => "B" }]
            expect(form.value).to eq([{ "option" => options[2].id }, { "option" => options[0].id }, { "option" => options[1].id }])
          end
        end

        context "with a matrix single question" do
          let(:question_type) { "matrix_single" }

          it "keys the choices by row id" do
            form.choices = [
              { "response_option_id" => options[0].id, "body" => "A", "matrix_row_id" => rows[0].id },
              { "response_option_id" => options[1].id, "body" => "B", "matrix_row_id" => rows[1].id, "custom_body" => "mine" }
            ]
            expect(form.value).to eq(rows[0].id.to_s => { "option" => options[0].id }, rows[1].id.to_s => { "option" => options[1].id, "text" => "mine" })
          end
        end

        context "with a matrix multiple question" do
          let(:question_type) { "matrix_multiple" }

          it "keys arrays of choices by row id" do
            form.choices = [
              { "response_option_id" => options[0].id, "body" => "A", "matrix_row_id" => rows[0].id },
              { "response_option_id" => options[1].id, "body" => "B", "matrix_row_id" => rows[0].id }
            ]
            expect(form.value).to eq(rows[0].id.to_s => [{ "option" => options[0].id }, { "option" => options[1].id }])
          end
        end

        context "with a files question" do
          let(:question_type) { "files" }

          it { expect(form.value).to be_nil }
        end

        context "with a title and description" do
          let(:question_type) { "title_and_description" }

          it "ignores the posted body" do
            form.body = "title-and-description"
            expect(form.value).to be_nil
          end
        end
      end

      describe "#map_model" do
        subject(:form) { described_class.from_model(response) }

        let(:question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type:) }
        let(:options) { question.response_options }
        let(:response) { create(:response, questionnaire:, question:, body: nil, value:) }

        context "with a sorting response" do
          let(:question_type) { "sorting" }
          let(:value) { [{ "option" => options[2].id }, { "option" => options[0].id }, { "option" => options[1].id }] }

          it "builds selected choices in rank order with the option labels" do
            expect(form.selected_choices.map(&:response_option_id)).to eq([options[2].id, options[0].id, options[1].id])
            expect(form.choices.first.body).to eq(options[2].body["en"])
            expect(form.choices.map(&:position)).to all(be_nil)
          end
        end

        context "with a matrix multiple response" do
          let(:question_type) { "matrix_multiple" }
          let(:row) { create(:question_matrix_row, question:) }
          let(:value) { { row.id.to_s => [{ "option" => options[0].id, "text" => "mine" }] } }

          it "restores the row, the option and the free text" do
            expect(form.selected_choices.map { |choice| [choice.matrix_row_id, choice.response_option_id, choice.custom_body] }).to eq([[row.id, options[0].id, "mine"]])
          end
        end

        context "with a deleted option" do
          let(:question_type) { "multiple_option" }
          let(:value) { [{ "option" => options[0].id + 1000, "label" => "Gone" }] }

          it "keeps the choice selected with the stored label" do
            expect(form.selected_choices.sole.body).to eq("Gone")
          end
        end

        context "with a text response" do
          let(:question_type) { "short_response" }
          let(:value) { "hello" }

          it { expect(form.body).to eq("hello") }
        end

        context "without a value" do
          let(:question_type) { "multiple_option" }
          let(:value) { nil }

          it { expect(form.choices).to be_empty }
        end

        context "with a legacy text response that has no value yet" do
          let(:question_type) { "short_response" }
          let(:response) { create(:response, questionnaire:, question:, body: "legacy", value: nil) }

          it { expect(form.body).to eq("legacy") }
        end

        context "with legacy choices that have no value yet" do
          let(:question_type) { "matrix_multiple" }
          let(:row) { create(:question_matrix_row, question:) }
          let(:value) { nil }

          before { create(:response_choice, response:, response_option: options[1], matrix_row: row, body: "Legacy", custom_body: "mine") }

          it "restores the row, the option and the free text from the legacy choices" do
            expect(form.selected_choices.map { |choice| [choice.matrix_row_id, choice.response_option_id, choice.custom_body] }).to eq([[row.id, options[1].id, "mine"]])
          end
        end
      end
    end
  end
end
