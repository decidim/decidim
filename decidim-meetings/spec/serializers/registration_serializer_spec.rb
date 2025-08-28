# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe RegistrationSerializer do
    describe "#serialize" do
      subject { described_class.new(registration) }

      context "when there are not a questionnaire" do
        let(:meeting) { create(:meeting, questionnaire: nil) }
        let!(:registration) { create(:registration, meeting:) }

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
        let(:meeting) { create(:meeting, :with_registrations_enabled) }
        let(:serialized) { subject.serialize }
        let!(:user) { create(:user, organization: meeting.organization) }
        let!(:registration) { create(:registration, meeting:, user:) }

        let!(:questions) { create_list(:questionnaire_question, 3, questionnaire: meeting.questionnaire) }
        let!(:responses) do
          questions.map do |question|
            create(:response, questionnaire: meeting.questionnaire, question:, user:)
          end
        end

        let!(:multichoice_question) { create(:questionnaire_question, questionnaire: meeting.questionnaire, question_type: "multiple_option") }
        let!(:multichoice_response_options) { create_list(:response_option, 2, question: multichoice_question) }
        let!(:multichoice_response) do
          create(:response, questionnaire: meeting.questionnaire, question: multichoice_question, user:, body: nil)
        end
        let!(:multichoice_response_choices) do
          multichoice_response_options.map do |response_option|
            create(:response_choice, response: multichoice_response, response_option:, body: response_option.body[I18n.locale.to_s])
          end
        end

        let!(:singlechoice_question) { create(:questionnaire_question, questionnaire: meeting.questionnaire, question_type: "single_option") }
        let!(:singlechoice_response_options) { create_list(:response_option, 2, question: singlechoice_question) }
        let!(:singlechoice_response) do
          create(:response, questionnaire: meeting.questionnaire, question: singlechoice_question, user:, body: nil)
        end
        let!(:singlechoice_response_choice) do
          response_option = singlechoice_response_options.first
          create(:response_choice, response: singlechoice_response, response_option:, body: response_option.body[I18n.locale.to_s])
        end

        let!(:singlechoice_free_question) { create(:questionnaire_question, questionnaire: meeting.questionnaire, question_type: "single_option") }
        let!(:singlechoice_free_response_options) do
          options = create_list(:response_option, 2, question: singlechoice_free_question)
          options << create(:response_option, :free_text_enabled, question: singlechoice_free_question)

          options
        end
        let!(:singlechoice_free_response) do
          create(:response, questionnaire: meeting.questionnaire, question: singlechoice_free_question, user:, body: nil)
        end
        let!(:singlechoice_free_response_choice) do
          response_option = singlechoice_free_response_options.find(&:free_text)
          create(
            :response_choice,
            response: singlechoice_free_response,
            response_option:,
            body: response_option.body[I18n.locale.to_s],
            custom_body: "Free text response"
          )
        end

        subject { described_class.new(registration) }

        it "includes the response for each question" do
          expect(serialized[:registration_form_responses]).to include(
            "#{questions.first.position + 1}. #{translated(questions.first.body, locale: I18n.locale)}" => responses.first.body
          )
          expect(serialized[:registration_form_responses]).to include(
            "#{questions.last.position + 1}. #{translated(questions.last.body, locale: I18n.locale)}" => responses.last.body
          )
          expect(serialized[:registration_form_responses]).to include(
            "#{multichoice_question.position + 1}. #{translated(multichoice_question.body, locale: I18n.locale)}" => [multichoice_response_choices.first.body, multichoice_response_choices.last.body]
          )
          expect(serialized[:registration_form_responses]).to include(
            "#{singlechoice_question.position + 1}. #{translated(singlechoice_question.body, locale: I18n.locale)}" => [singlechoice_response_choice.body]
          )
          expect(serialized[:registration_form_responses]).to include(
            "#{singlechoice_free_question.position + 1}. #{translated(singlechoice_free_question.body, locale: I18n.locale)}" => ["#{singlechoice_free_response_choice.body} (Free text response)"]
          )
        end
      end
    end
  end
end
