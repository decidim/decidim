# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe UserResponsesSerializer do
      subject do
        described_class.new(questionnaire.responses)
      end

      let!(:questionable) { create(:dummy_resource) }
      let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }
      let!(:user) { create(:user, organization: questionable.organization) }
      let!(:questions) { create_list(:questionnaire_question, 3, questionnaire:) }
      let!(:responses) do
        questions.map do |question|
          create(:response, questionnaire:, question:, user:)
        end
      end

      let!(:multichoice_question) { create(:questionnaire_question, questionnaire:, question_type: "multiple_option") }
      let!(:multichoice_response_options) { create_list(:response_option, 2, question: multichoice_question) }
      let!(:multichoice_response) do
        create(:response, questionnaire:, question: multichoice_question, user:, body: nil)
      end
      let!(:multichoice_response_choices) do
        multichoice_response_options.map do |response_option|
          create(:response_choice, response: multichoice_response, response_option:, body: response_option.body[I18n.locale.to_s])
        end
      end

      let!(:singlechoice_question) { create(:questionnaire_question, questionnaire:, question_type: "single_option") }
      let!(:singlechoice_response_options) { create_list(:response_option, 2, question: singlechoice_question) }
      let!(:singlechoice_response) do
        create(:response, questionnaire:, question: singlechoice_question, user:, body: nil)
      end
      let!(:singlechoice_response_choice) do
        response_option = singlechoice_response_options.first
        create(:response_choice, response: singlechoice_response, response_option:, body: response_option.body[I18n.locale.to_s], custom_body: "Free text")
      end

      let!(:matrixmultiple_question) { create(:questionnaire_question, questionnaire:, question_type: "matrix_multiple") }
      let!(:matrixmultiple_response_options) { create_list(:response_option, 3, question: matrixmultiple_question) }
      let!(:matrixmultiple_rows) { create_list(:question_matrix_row, 3, question: matrixmultiple_question) }
      let!(:matrixmultiple_response) do
        create(:response, questionnaire:, question: matrixmultiple_question, user:, body: nil)
      end
      let!(:matrixmultiple_response_choices) do
        matrixmultiple_rows.map do |row|
          [
            create(:response_choice, response: matrixmultiple_response, response_option: matrixmultiple_response_options.first, matrix_row: row, body: matrixmultiple_response_options.first.body[I18n.locale.to_s]),
            create(:response_choice, response: matrixmultiple_response, response_option: matrixmultiple_response_options.last, matrix_row: row, body: matrixmultiple_response_options.last.body[I18n.locale.to_s])
          ]
        end.flatten
      end

      let!(:files_question) { create(:questionnaire_question, questionnaire:, question_type: "files") }
      let!(:files_response) do
        create(:response, :with_attachments, questionnaire:, question: files_question, user:, body: nil)
      end

      before do
        questions.each_with_index do |question, idx|
          question.update!(position: idx)
        end
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "includes the response for each question" do
          questions.each_with_index do |question, idx|
            expect(serialized).to include(
              "#{question.position + 1}. #{translated(question.body, locale: I18n.locale)}" => responses[idx].body
            )
          end

          serialized_matrix_response = matrixmultiple_rows.to_h do |row|
            key = translated(row.body, locale: I18n.locale)
            choices = matrixmultiple_response_options.map do |option|
              matrixmultiple_response_choices.find { |choice| choice.matrix_row == row && choice.response_option == option }
            end

            [key, choices.map { |choice| choice&.body }]
          end

          serialized_files_blobs = files_response.attachments.map(&:file).map(&:blob)

          expect(serialized).to include(
            "#{multichoice_question.position + 1}. #{translated(multichoice_question.body, locale: I18n.locale)}" => [multichoice_response_choices.first.body, multichoice_response_choices.last.body]
          )

          expect(serialized).to include(
            "#{singlechoice_question.position + 1}. #{translated(singlechoice_question.body, locale: I18n.locale)}" => ["#{translated(singlechoice_response_choice.body)} (Free text)"]
          )

          expect(serialized).to include(
            "#{matrixmultiple_question.position + 1}. #{translated(matrixmultiple_question.body, locale: I18n.locale)}" => serialized_matrix_response
          )

          expect(serialized["#{files_question.position + 1}. #{translated(files_question.body, locale: I18n.locale)}"]).to include_blob_urls(
            *serialized_files_blobs
          )
        end

        context "and includes the attributes" do
          let(:an_response) { responses.first }

          it "the id of the response" do
            key = I18n.t(:id, scope: "decidim.forms.user_responses_serializer")
            expect(serialized[key]).to eq an_response.session_token
          end

          it "the creation of the response" do
            key = I18n.t(:created_at, scope: "decidim.forms.user_responses_serializer")
            expect(serialized[key]).to be_within(1.second).of an_response.created_at
          end

          it "the IP hash of the user" do
            key = I18n.t(:ip_hash, scope: "decidim.forms.user_responses_serializer")
            expect(serialized[key]).to eq an_response.ip_hash
          end

          it "the user status" do
            key = I18n.t(:user_status, scope: "decidim.forms.user_responses_serializer")
            expect(serialized[key]).to eq "Registered"
          end

          context "when user is not registered" do
            before do
              questionnaire.responses.first.update!(decidim_user_id: nil)
            end

            it "the user status is unregistered" do
              key = I18n.t(:user_status, scope: "decidim.forms.user_responses_serializer")
              expect(serialized[key]).to eq "Unregistered"
            end
          end
        end

        context "when conditional question is not responded by user" do
          let!(:conditional_question) { create(:questionnaire_question, :conditioned, questionnaire:, position: 4) }

          it "includes conditional question as empty" do
            expect(serialized).to include("5. #{translated(conditional_question.body, locale: I18n.locale)}" => "")
          end
        end

        context "when time zone is UTC" do
          let(:time_zone) { "UTC" }
          let(:created_at) { Time.new(2000, 1, 2, 3, 4, 5, 0) }

          before do
            questionable.organization.update!(time_zone:)
            responses.first.update!(created_at:)
          end

          it "Time uses UTC time zone in exported data" do
            key = I18n.t(:created_at, scope: "decidim.forms.user_responses_serializer")
            expect(serialized[key].to_s).to include "UTC"
          end
        end

        context "when time zone is non-UTC" do
          let(:time_zone) { "Hawaii" }
          let(:created_at) { Time.new(2000, 1, 2, 3, 4, 5, 0) }

          before do
            questionable.organization.update!(time_zone:)
            responses.first.update!(created_at:)
          end

          it "Time uses UTC time zone in exported data" do
            key = I18n.t(:created_at, scope: "decidim.forms.user_responses_serializer")
            expect(serialized[key].to_s).to include "UTC"
          end
        end

        context "when the questionnaire body is very long" do
          let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable, description: questionnaire_description) }
          let(:questionnaire_description) do
            Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.localized { "a" * 1_000_000 }
            end
          end
          let!(:users) { create_list(:user, 100, organization: questionable.organization) }

          before do
            users.each do |user|
              questions.each do |question|
                create(:response, questionnaire:, question:, user:)
              end
            end
          end

          it "does not load the questionnaire description to memory every time when iterating an response" do
            # NOTE:
            # For this test it is important to fetch the single user "response
            # sets" to an array and store them there because this is the same
            # way the responses are loaded e.g. in the survey component export
            # functionality. The export had previously a memory leak because the
            # questionnaire is fetched individually for each "response set" and if
            # it has a very long description, it caused the description to be
            # stored multiple times within the array (for each "response set"
            # separately) causing a out of memory errors when there is a large
            # amount of responses.
            all_responses = Decidim::Forms::QuestionnaireUserResponses.for(questionnaire)

            initial_memory = memory_usage
            all_responses.each do |response_set|
              described_class.new(response_set).serialize
            end
            expect(memory_usage - initial_memory).to be < 10_000
          end

          def memory_usage
            `ps -o rss #{Process.pid}`.lines.last.to_i
          end
        end
      end

      describe "questions_hash" do
        it "generates a hash of questions ordered by position" do
          questions.shuffle!
          expect(subject.instance_eval { questions_hash }.keys.map { |key| key[0].to_i }.uniq).to eq(questions.sort_by(&:position).map { |question| question.position + 1 })
        end
      end
    end
  end
end
