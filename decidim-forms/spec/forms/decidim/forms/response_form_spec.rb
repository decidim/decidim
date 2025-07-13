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
              subject.add_documents = uploaded_files
            end

            it "is valid" do
              expect(subject).to be_valid
            end
          end

          context "when there are no uploaded files" do
            before do
              subject.add_documents = nil
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
    end
  end
end
