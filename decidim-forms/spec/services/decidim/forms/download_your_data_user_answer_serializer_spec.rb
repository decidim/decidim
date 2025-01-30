# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe DownloadYourDataUserAnswersSerializer do
      include Decidim::TranslationsHelper

      subject do
        described_class.new(questionnaire.answers.first)
      end

      let!(:questionnaire) { create(:questionnaire) }
      let!(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        context "when question is files" do
          let!(:question) { create(:questionnaire_question, questionnaire:, question_type: :files) }
          let!(:answer) { create(:answer, :with_attachments, questionnaire:, question:, user:) }

          it "includes the answer id" do
            expect(serialized).to include(id: answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: answer.user.email)
            )
          end

          it "includes the questionnaire information" do
            expect(serialized[:questionnaire]).to(
              include(id: questionnaire.id)
            )
            expect(serialized[:questionnaire]).to(
              include(title: translated_attribute(questionnaire.title))
            )
            expect(serialized[:questionnaire]).to(
              include(description: translated_attribute(questionnaire.description))
            )
            expect(serialized[:questionnaire]).to(
              include(tos: translated_attribute(questionnaire.tos))
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(question.description))
            )
          end

          it "includes the answer" do
            expect(serialized[:answer]).to include_blob_urls(*answer.attachments.map(&:file).map(&:blob))
          end
        end

        context "when question is shortanswer" do
          let!(:question) { create(:questionnaire_question, questionnaire:) }
          let!(:answer) { create(:answer, questionnaire:, question:, user:) }

          it "includes the answer id" do
            expect(serialized).to include(id: answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: answer.user.email)
            )
          end

          it "includes the questionnaire information" do
            expect(serialized[:questionnaire]).to(
              include(id: questionnaire.id)
            )
            expect(serialized[:questionnaire]).to(
              include(title: translated_attribute(questionnaire.title))
            )
            expect(serialized[:questionnaire]).to(
              include(description: translated_attribute(questionnaire.description))
            )
            expect(serialized[:questionnaire]).to(
              include(tos: translated_attribute(questionnaire.tos))
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(question.description))
            )
          end

          it "includes the answer" do
            expect(serialized).to include(answer: answer.body)
          end
        end

        context "when question is multiple choice" do
          let!(:multichoice_question) { create(:questionnaire_question, questionnaire:, question_type: "multiple_option") }
          let!(:multichoice_answer_options) { create_list(:answer_option, 2, question: multichoice_question) }
          let!(:multichoice_answer) do
            create(:answer, questionnaire:, question: multichoice_question, user:, body: nil)
          end
          let!(:multichoice_answer_choices) do
            multichoice_answer_options.map do |answer_option|
              create(:answer_choice, answer: multichoice_answer, answer_option:, body: answer_option.body[I18n.locale.to_s])
            end
          end

          it "includes the answer id" do
            expect(serialized).to include(id: multichoice_answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: multichoice_answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: multichoice_answer.user.email)
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: multichoice_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(multichoice_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(multichoice_question.description))
            )
          end

          it "includes the answers" do
            expect(serialized).to include(answer: multichoice_answer_choices.map(&:body))
          end
        end

        context "when question is single choice" do
          let!(:singlechoice_question) { create(:questionnaire_question, questionnaire:, question_type: "single_option") }
          let!(:singlechoice_answer_options) { create_list(:answer_option, 2, question: singlechoice_question) }
          let!(:singlechoice_answer) do
            create(:answer, questionnaire:, question: singlechoice_question, user:, body: nil)
          end
          let!(:singlechoice_answer_choice) do
            answer_option = singlechoice_answer_options.first
            create(:answer_choice, answer: singlechoice_answer, answer_option:, body: answer_option.body[I18n.locale.to_s])
          end

          it "includes the answer id" do
            expect(serialized).to include(id: singlechoice_answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: singlechoice_answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: singlechoice_answer.user.email)
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: singlechoice_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(singlechoice_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(singlechoice_question.description))
            )
          end

          it "includes the answers" do
            expect(serialized).to include(answer: [singlechoice_answer_choice.body])
          end
        end

        context "when question is sorting" do
          let!(:sorting_question) { create(:questionnaire_question, questionnaire:, question_type: "sorting") }
          let!(:sorting_answer_options) { create_list(:answer_option, 4, question: sorting_question) }
          let!(:sorting_answer) do
            create(:answer, questionnaire:, question: sorting_question, user:, body: nil)
          end
          let!(:sorting_answer_choices) do
            base_position = sorting_answer_options.count - 1
            sorting_answer_options.sort_by(&:id).map.with_index do |answer_option, i|
              create(:answer_choice, answer: sorting_answer, answer_option:, position: base_position - i, body: answer_option.body[I18n.locale.to_s])
            end
          end

          it "includes the answer id" do
            expect(serialized).to include(id: sorting_answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: sorting_answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: sorting_answer.user.email)
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: sorting_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(sorting_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(sorting_question.description))
            )
          end

          it "includes the answers correctly ordered correctly" do
            expect(serialized).to include(answer: sorting_answer_options.sort_by(&:id).reverse.map { |option| option.body[I18n.locale.to_s] })
          end
        end

        context "when question is matrix_single" do
          let!(:matrix_single_question) { create(:questionnaire_question, questionnaire:, question_type: "matrix_single") }
          let!(:matrix_single_answer_options) { create_list(:answer_option, 4, question: matrix_single_question) }
          let!(:matrix_single_answer_rows) do
            (0..9).map do |position|
              create(:question_matrix_row, question: matrix_single_question, position:)
            end
          end
          let!(:matrix_single_answer) do
            create(:answer, questionnaire:, question: matrix_single_question, user:, body: nil)
          end
          let(:sorted_choices_indexes) { [0, 2, 0, 1, 3, 3, 2, 1, 3, 1] }
          let!(:matrix_single_answer_choices) do
            matrix_single_answer_rows.sort_by(&:id).reverse.map.with_index do |matrix_row, i|
              answer_option = matrix_single_answer_options[sorted_choices_indexes[i]]
              create(:answer_choice, answer: matrix_single_answer, matrix_row:, answer_option:, body: answer_option.body[I18n.locale.to_s])
            end
          end

          it "includes the answer id" do
            expect(serialized).to include(id: matrix_single_answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: matrix_single_answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: matrix_single_answer.user.email)
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: matrix_single_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(matrix_single_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(matrix_single_question.description))
            )
          end

          it "includes the answers ordered correctly" do
            expect(serialized).to include(answer: sorted_choices_indexes.reverse.map { |i| matrix_single_answer_options[i].body[I18n.locale.to_s] })
          end
        end
      end
    end
  end
end
