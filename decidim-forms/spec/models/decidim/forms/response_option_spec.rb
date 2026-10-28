# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe ResponseOption do
      subject { response_option }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question_type) { "single_option" }
      let(:question) { create(:questionnaire_question, questionnaire:, question_type:) }
      let(:response) { create(:response, question:, questionnaire:) }
      let(:display_conditions) { create_list(:display_condition, 2, response_option:) }
      let(:response_option) { build(:response_option, question:, body: { en: "A statement", ca: "Una afirmació", es: "Una afirmación" }) }

      it { is_expected.to be_valid }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "uses the question's response_options association as the inverse" do
        subject.save!

        expect(question.response_options.first.question).to be(question)
      end

      it "has an association of display_conditions" do
        expect(subject.display_conditions).to eq(display_conditions)
      end

      it "has an association of choices" do
        choices = create_list(:response_choice, 2, response:, response_option:)

        expect(subject.choices).to match_array(choices)
      end

      it "uses the choices association as the inverse of the response option" do
        create(:response_choice, response:, response_option:)

        expect(response_option.choices.first.response_option).to be(response_option)
      end

      describe "#translated_body" do
        it "returns the translated body of the response option" do
          expect(subject.translated_body).to eq(subject.body["en"])
        end
      end
    end
  end
end
