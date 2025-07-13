# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe DisplayCondition do
      subject { display_condition }

      let(:questionnaire) { create(:questionnaire) }
      let(:condition_question) { create(:questionnaire_question, questionnaire:, position: 2) }
      let(:question) { create(:questionnaire_question, questionnaire:, position: 3) }
      let(:condition_type) { :responded }
      let(:display_condition) do
        build(
          :display_condition,
          question:,
          condition_question:,
          condition_type:
        )
      end

      let(:display_condition_equal) do
        build(
          :display_condition,
          :equal,
          question:,
          condition_question:,
          response_option:
        )
      end

      let(:display_condition_match) do
        build(
          :display_condition,
          :match,
          question:,
          condition_question:,
          condition_value: { en: "To be", es: "o no", ca: "ser" }
        )
      end

      let(:choice_body) do
        {
          en: "To be or not to be, that is the question",
          ca: "Ser o no ser, aquesta és la qüestió",
          es: "Ser o no ser, he ahí el dilema"
        }
      end
      let(:response_option) { create(:response_option, question: condition_question, body: choice_body) }

      describe "associations" do
        it "has a question association" do
          expect(subject.question).to eq(question)
        end

        it "has a condition_question association" do
          expect(subject.condition_question).to eq(condition_question)
        end

        context "when condition_type is :equal" do
          let(:display_condition) { display_condition_equal }
          let(:response_option) { create(:response_option, question: condition_question) }

          it "has an response_option association" do
            expect(subject.response_option).to eq(response_option)
          end
        end
      end

      shared_examples "common conditions" do
        context "when condition_type is :responded" do
          let(:condition_type) { :responded }

          context "and form is empty" do
            let(:response_form) { nil }

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and body is empty" do
            let(:response_body) { nil }

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and body has text" do
            let(:response_body) { "any text" }

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end
        end

        context "when condition_type is :not_responded" do
          let(:condition_type) { :not_responded }

          context "and form is empty" do
            let(:response_form) { nil }

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and body is empty" do
            let(:response_body) { nil }

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and body has text" do
            let(:response_body) { "any text" }

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end
        end

        context "when condition_type is :match" do
          let(:condition_type) { :match }
          let(:display_condition) { display_condition_match }

          context "and body is empty" do
            let(:response_body) { nil }

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and body contains the text in :en" do
            let(:response_body) { "To be or not to be, that is the question" }

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and body do not contain the text in :en" do
            let(:response_body) { "this is the question" }

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and body contains the text in :ca" do
            let(:response_body) { "Ser o no ser, aquesta és la qüestió" }

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and body do not contain the text in :ca" do
            let(:response_body) { "Aquesta és la questió" }

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and body contains the text in :es" do
            let(:response_body) { "Ser o no ser, he ahí el dilema" }

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and body do not contain the text in :es" do
            let(:response_body) { "Esa es la questión" }

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end
        end
      end

      shared_examples "conditions with choices" do
        context "when condition_type is :equal" do
          let(:condition_type) { :equal }
          let(:display_condition) { display_condition_equal }

          context "and choices include the response option" do
            let(:choice_attributes) do
              { response_option_id: response_option.id }
            end

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and choices do not include the response option" do
            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end
        end

        context "when condition_type is :match" do
          let(:condition_type) { :match }
          let(:display_condition) { display_condition_match }

          context "and choices do not include the response option" do
            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and choices have unrelated text" do
            let(:choice_attributes) do
              {
                response_option_id: response_option.id,
                body: "another text"
              }
            end

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and choices are empty" do
            let(:choice_attributes) do
              {
                response_option_id: response_option.id,
                body: ""
              }
            end

            it "is not fulfilled" do
              expect(subject.fulfilled?(response_form)).to be false
            end
          end

          context "and choices include the response option in :en" do
            let(:choice_attributes) do
              {
                response_option_id: response_option.id,
                body: choice_body[:en]
              }
            end

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and choices include the response option in :ca" do
            let(:choice_attributes) do
              {
                response_option_id: response_option.id,
                body: choice_body[:ca]
              }
            end

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and choices include the response option in :es" do
            let(:choice_attributes) do
              {
                response_option_id: response_option.id,
                body: choice_body[:es]
              }
            end

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end

          context "and choices are include in the custom_body" do
            let(:choice_attributes) do
              {
                response_option_id: response_option.id,
                custom_body: choice_body[:es]
              }
            end

            it "is fulfilled" do
              expect(subject.fulfilled?(response_form)).to be true
            end
          end
        end
      end

      describe "#fulfilled?" do
        let(:response_body) { nil }
        let(:choice_attributes) do
          {
            response_option_id: 314_159_265_359
          }
        end
        let(:attributes) do
          {
            body: response_body,
            choices: [
              ResponseChoiceForm.from_params(choice_attributes)
            ]
          }
        end
        let(:response_form) { ResponseForm.from_params(attributes) }

        context "when condition question is a text" do
          it_behaves_like "common conditions"
        end

        context "when condition question has options" do
          let(:condition_question) do
            create(:questionnaire_question,
                   :with_response_options,
                   question_type: :single_option,
                   questionnaire:,
                   position: 2)
          end

          it_behaves_like "common conditions"
          it_behaves_like "conditions with choices"
        end

        context "when condition question is a matrix" do
          let(:condition_question) do
            create(:questionnaire_question,
                   :with_response_options,
                   question_type: :matrix_single,
                   questionnaire:,
                   position: 2)
          end

          it_behaves_like "common conditions"
          it_behaves_like "conditions with choices"
        end
      end

      describe "#to_html_data" do
        let(:html_data) { subject.to_html_data }

        it "returns a hash" do
          expect(html_data).to be_a(Hash)
        end

        it "has an 'id' attribute with the display_condition id" do
          expect(html_data[:id]).to eq(subject.id)
        end

        it "has a 'condition' attribute with the display_condition's condition question id" do
          expect(html_data[:condition]).to eq(subject.condition_question.id)
        end

        it "has a 'mandatory' attribute with the display_condition's 'mandatory' value" do
          expect(html_data[:mandatory]).to eq(subject.mandatory)
        end

        context "when the display condition has a related response_option" do
          let(:display_condition) { display_condition_equal }
          let(:response_option) { create(:response_option, question: condition_question) }

          it "has an 'option' attribute with the display_condition's response_option id" do
            expect(html_data[:option]).to eq(subject.response_option.id)
          end
        end

        context "when the display condition has a condition_value" do
          let(:display_condition) { display_condition_match }

          it "has a 'value' attribute with the display_condition's condition_value translated to current locale" do
            expect(html_data[:value]).to eq(subject.condition_value[I18n.locale.to_s])
          end
        end
      end
    end
  end
end
