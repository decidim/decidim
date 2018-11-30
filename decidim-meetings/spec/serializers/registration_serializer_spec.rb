# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe RegistrationSerializer do
    describe "#serialize" do
      let!(:registration) { create(:registration) }
      let!(:subject) { described_class.new(registration) }

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

      context "when questtionaire enabled" do
        let(:meeting) { create :meeting, :with_registrations_enabled }
        let!(:user) { create(:user, organization: meeting.organization) }
        let!(:registration) { create(:registration, meeting: meeting, user: user) }

        let!(:questions) { create_list :questionnaire_question, 3, questionnaire: meeting.questionnaire }
        let!(:answers) do
          questions.map do |question|
            create :answer, questionnaire: meeting.questionnaire, question: question, user: user
          end
        end

        let!(:multichoice_question) { create :questionnaire_question, questionnaire: meeting.questionnaire, question_type: "multiple_option" }
        let!(:multichoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
        let!(:multichoice_answer) do
          create :answer, questionnaire: meeting.questionnaire, question: multichoice_question, user: user, body: nil
        end
        let!(:multichoice_answer_choices) do
          multichoice_answer_options.map do |answer_option|
            create :answer_choice, answer: multichoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
          end
        end

        let!(:singlechoice_question) { create :questionnaire_question, questionnaire: meeting.questionnaire, question_type: "single_option" }
        let!(:singlechoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
        let!(:singlechoice_answer) do
          create :answer, questionnaire: meeting.questionnaire, question: singlechoice_question, user: user, body: nil
        end
        let!(:singlechoice_answer_choice) do
          answer_option = singlechoice_answer_options.first
          create :answer_choice, answer: singlechoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
        end

        let!(:subject) { described_class.new(registration) }
        let(:serialized) { subject.serialize }

        it "includes the answer for each question" do
          expect(serialized[:registration_form_answers]).to include(
            "1. #{translated(questions.first.body, locale: I18n.locale)}" => answers.first.body
          )
          expect(serialized[:registration_form_answers]).to include(
            "3. #{translated(questions.last.body, locale: I18n.locale)}" => answers.last.body
          )
          expect(serialized[:registration_form_answers]).to include(
            "4. #{translated(multichoice_question.body, locale: I18n.locale)}" => multichoice_answer_choices.map(&:body)
          )

          expect(serialized[:registration_form_answers]).to include(
            "5. #{translated(singlechoice_question.body, locale: I18n.locale)}" => [singlechoice_answer_choice.body]
          )
        end
      end
    end
  end
end
