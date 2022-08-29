# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe RegistrationSerializer do
    describe "#serialize" do
      subject { described_class.new(registration) }

      let!(:registration) { create(:registration) }

      context "when there are not a questionnaire" do
        it "includes the id" do
          expect(subject.serialize).to include(id: registration.id)
        end

        it "includes the registration code" do
          expect(subject.serialize).to include(code: registration.code)
        end

        it "includes the user" do
          expect(subject.serialize[:user]).to(
            include(name: registration.user.name)
          )
          expect(subject.serialize[:user]).to(
            include(email: registration.user.email)
          )
        end
      end

      context "when questionnaire enabled" do
        let(:meeting) { create :meeting, :with_registrations_enabled }
        let(:serialized) { subject.serialize }
        let!(:user) { create(:user, organization: meeting.organization) }
        let!(:registration) { create(:registration, meeting:, user:) }

        let!(:questions) { create_list :questionnaire_question, 3, questionnaire: meeting.questionnaire }
        let!(:answers) do
          questions.map do |question|
            create :answer, questionnaire: meeting.questionnaire, question:, user:
          end
        end

        let!(:multichoice_question) { create :questionnaire_question, questionnaire: meeting.questionnaire, question_type: "multiple_option" }
        let!(:multichoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
        let!(:multichoice_answer) do
          create :answer, questionnaire: meeting.questionnaire, question: multichoice_question, user:, body: nil
        end
        let!(:multichoice_answer_choices) do
          multichoice_answer_options.map do |answer_option|
            create :answer_choice, answer: multichoice_answer, answer_option:, body: answer_option.body[I18n.locale.to_s]
          end
        end

        let!(:singlechoice_question) { create :questionnaire_question, questionnaire: meeting.questionnaire, question_type: "single_option" }
        let!(:singlechoice_answer_options) { create_list :answer_option, 2, question: singlechoice_question }
        let!(:singlechoice_answer) do
          create :answer, questionnaire: meeting.questionnaire, question: singlechoice_question, user:, body: nil
        end
        let!(:singlechoice_answer_choice) do
          answer_option = singlechoice_answer_options.first
          create :answer_choice, answer: singlechoice_answer, answer_option:, body: answer_option.body[I18n.locale.to_s]
        end

        let!(:singlechoice_free_question) { create :questionnaire_question, questionnaire: meeting.questionnaire, question_type: "single_option" }
        let!(:singlechoice_free_answer_options) do
          options = create_list :answer_option, 2, question: singlechoice_free_question
          options << create(:answer_option, :free_text_enabled, question: singlechoice_free_question)

          options
        end
        let!(:singlechoice_free_answer) do
          create :answer, questionnaire: meeting.questionnaire, question: singlechoice_free_question, user:, body: nil
        end
        let!(:singlechoice_free_answer_choice) do
          answer_option = singlechoice_free_answer_options.find(&:free_text)
          create(
            :answer_choice,
            answer: singlechoice_free_answer,
            answer_option:,
            body: answer_option.body[I18n.locale.to_s],
            custom_body: "Free text answer"
          )
        end

        subject { described_class.new(registration) }

        it "includes the answer for each question" do
          expect(serialized[:registration_form_answers]).to include(
            "#{questions.first.position + 1}. #{translated(questions.first.body, locale: I18n.locale)}" => answers.first.body
          )
          expect(serialized[:registration_form_answers]).to include(
            "#{questions.last.position + 1}. #{translated(questions.last.body, locale: I18n.locale)}" => answers.last.body
          )
          expect(serialized[:registration_form_answers]).to include(
            "#{multichoice_question.position + 1}. #{translated(multichoice_question.body, locale: I18n.locale)}" => [multichoice_answer_choices.first.body, multichoice_answer_choices.last.body]
          )
          expect(serialized[:registration_form_answers]).to include(
            "#{singlechoice_question.position + 1}. #{translated(singlechoice_question.body, locale: I18n.locale)}" => [singlechoice_answer_choice.body]
          )
          expect(serialized[:registration_form_answers]).to include(
            "#{singlechoice_free_question.position + 1}. #{translated(singlechoice_free_question.body, locale: I18n.locale)}" => ["#{singlechoice_free_answer_choice.body} (Free text answer)"]
          )
        end
      end
    end
  end
end
