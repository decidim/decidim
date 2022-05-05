# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe UserAnswersSerializer do
      subject do
        described_class.new(questionnaire.answers)
      end

      let!(:questionable) { create(:dummy_resource) }
      let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }
      let!(:user) { create(:user, organization: questionable.organization) }
      let!(:questions) { create_list :questionnaire_question, 3, questionnaire: questionnaire }
      let!(:answers) do
        questions.map do |question|
          create :answer, questionnaire: questionnaire, question: question, user: user
        end
      end

      let!(:multichoice_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option" }
      let!(:multichoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
      let!(:multichoice_answer) do
        create :answer, questionnaire: questionnaire, question: multichoice_question, user: user, body: nil
      end
      let!(:multichoice_answer_choices) do
        multichoice_answer_options.map do |answer_option|
          create :answer_choice, answer: multichoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
        end
      end

      let!(:singlechoice_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "single_option" }
      let!(:singlechoice_answer_options) { create_list :answer_option, 2, question: singlechoice_question }
      let!(:singlechoice_answer) do
        create :answer, questionnaire: questionnaire, question: singlechoice_question, user: user, body: nil
      end
      let!(:singlechoice_answer_choice) do
        answer_option = singlechoice_answer_options.first
        create :answer_choice, answer: singlechoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s], custom_body: "Free text"
      end

      let!(:matrixmultiple_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "matrix_multiple" }
      let!(:matrixmultiple_answer_options) { create_list :answer_option, 3, question: matrixmultiple_question }
      let!(:matrixmultiple_rows) { create_list :question_matrix_row, 3, question: matrixmultiple_question }
      let!(:matrixmultiple_answer) do
        create :answer, questionnaire: questionnaire, question: matrixmultiple_question, user: user, body: nil
      end
      let!(:matrixmultiple_answer_choices) do
        matrixmultiple_rows.map do |row|
          [
            create(:answer_choice, answer: matrixmultiple_answer, answer_option: matrixmultiple_answer_options.first, matrix_row: row, body: matrixmultiple_answer_options.first.body[I18n.locale.to_s]),
            create(:answer_choice, answer: matrixmultiple_answer, answer_option: matrixmultiple_answer_options.last, matrix_row: row, body: matrixmultiple_answer_options.last.body[I18n.locale.to_s])
          ]
        end.flatten
      end

      let!(:files_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "files" }
      let!(:files_answer) do
        create :answer, :with_attachments, questionnaire: questionnaire, question: files_question, user: user, body: nil
      end

      before do
        questions.each_with_index do |question, idx|
          question.update!(position: idx)
        end
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "includes the answer for each question" do
          questions.each_with_index do |question, idx|
            expect(serialized).to include(
              "#{question.position + 1}. #{translated(question.body, locale: I18n.locale)}" => answers[idx].body
            )
          end

          serialized_matrix_answer = matrixmultiple_rows.to_h do |row|
            key = translated(row.body, locale: I18n.locale)
            choices = matrixmultiple_answer_options.map do |option|
              matrixmultiple_answer_choices.find { |choice| choice.matrix_row == row && choice.answer_option == option }
            end

            [key, choices.map { |choice| choice&.body }]
          end

          serialized_files_answer = files_answer.attachments.map(&:url)

          expect(serialized).to include(
            "#{multichoice_question.position + 1}. #{translated(multichoice_question.body, locale: I18n.locale)}" => [multichoice_answer_choices.first.body, multichoice_answer_choices.last.body]
          )

          expect(serialized).to include(
            "#{singlechoice_question.position + 1}. #{translated(singlechoice_question.body, locale: I18n.locale)}" => ["#{translated(singlechoice_answer_choice.body)} (Free text)"]
          )

          expect(serialized).to include(
            "#{matrixmultiple_question.position + 1}. #{translated(matrixmultiple_question.body, locale: I18n.locale)}" => serialized_matrix_answer
          )

          expect(serialized).to include(
            "#{files_question.position + 1}. #{translated(files_question.body, locale: I18n.locale)}" => serialized_files_answer
          )
        end

        context "and includes the attributes" do
          let!(:an_answer) { create(:answer, questionnaire: questionnaire, question: questions.sample, user: user) }

          it "the id of the answer" do
            key = I18n.t(:id, scope: "decidim.forms.user_answers_serializer")
            expect(serialized[key]).to eq an_answer.session_token
          end

          it "the creation of the answer" do
            key = I18n.t(:created_at, scope: "decidim.forms.user_answers_serializer")
            expect(serialized[key]).to eq an_answer.created_at.to_s(:db)
          end

          it "the IP hash of the user" do
            key = I18n.t(:ip_hash, scope: "decidim.forms.user_answers_serializer")
            expect(serialized[key]).to eq an_answer.ip_hash
          end

          it "the user status" do
            key = I18n.t(:user_status, scope: "decidim.forms.user_answers_serializer")
            expect(serialized[key]).to eq "Registered"
          end

          context "when user is not registered" do
            before do
              questionnaire.answers.first.update!(decidim_user_id: nil)
            end

            it "the user status is unregistered" do
              key = I18n.t(:user_status, scope: "decidim.forms.user_answers_serializer")
              expect(serialized[key]).to eq "Unregistered"
            end
          end
        end

        context "when conditional question is not answered by user" do
          let!(:conditional_question) { create(:questionnaire_question, :conditioned, questionnaire: questionnaire, position: 4) }

          it "includes conditional question as empty" do
            expect(serialized).to include("5. #{translated(conditional_question.body, locale: I18n.locale)}" => "")
          end
        end
      end
    end
  end
end
