# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe ResponseQuestionnaire do
      let(:command) { described_class.new(form, questionnaire) }
      let(:form) do
        QuestionnaireForm.from_params(
          form_params
        ).with_context(
          current_organization:,
          current_user:,
          session_token:,
          ip_hash:
        )
      end
      let(:form_params) do
        {
          "responses" => [
            {
              "body" => "This is my first response",
              "question_id" => question1.id
            },
            {
              "choices" => [
                { "response_option_id" => response_option_ids[0], "body" => "My", "matrix_row_id" => matrix_row_ids[0] },
                { "response_option_id" => response_option_ids[1], "body" => "second", "matrix_row_id" => matrix_row_ids[1] },
                { "response_option_id" => response_option_ids[2], "body" => "response", "matrix_row_id" => matrix_row_ids[2] }
              ],
              "question_id" => question2.id
            },
            {
              "choices" => [
                { "response_option_id" => response_option_ids[3], "body" => "Third", "position" => 0 },
                { "response_option_id" => response_option_ids[4], "body" => "response", "position" => 1 }
              ],
              "question_id" => question3.id
            }
          ],
          "tos_agreement" => "1"
        }
      end
      let(:matrix_row_ids) { matrix_rows.pluck(:id).map(&:to_s) }
      let(:matrix_rows) { create_list(:question_matrix_row, 3, question: question2) }
      let(:response_option_ids) { response_options.pluck(:id).map(&:to_s) }
      let(:response_options) { create_list(:response_option, 5, question: question2) }
      let(:question3) { create(:questionnaire_question, questionnaire:) }
      let(:question2) { create(:questionnaire_question, questionnaire:) }
      let(:question1) { create(:questionnaire_question, questionnaire:) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:participatory_process) { create(:participatory_process, organization: current_organization) }
      let(:request) do
        double(
          session: { session_id: },
          remote_ip:
        )
      end
      let(:ip_hash) { tokenize(remote_ip) }
      let(:remote_ip) { "1.1.1.1" }
      let(:session_token) { tokenize(current_user&.id || session_id) }
      let(:session_id) { "session-string" }
      let(:current_user) { create(:user, organization: current_organization) }
      let(:current_organization) { create(:organization) }

      it_behaves_like "fires an ActiveSupport::Notification event", "decidim.forms.response_questionnaire:after"

      def tokenize(id)
        "fake-hash-for-#{id}"
      end

      describe "when the form is invalid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create questionnaire responses" do
          expect do
            command.call
          end.not_to change(Response, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a questionnaire response for each question responded" do
          expect do
            command.call
          end.to change(Response, :count).by(3)
          expect(Response.all.map(&:questionnaire)).to eq([questionnaire, questionnaire, questionnaire])
        end

        it "creates responses with the correct information" do
          command.call

          expect(Response.first.body).to eq("This is my first response")
          expect(Response.second.choices.map { |a| [a.body, a.matrix_row.body] }).to eq([["My", matrix_rows.first.body], ["second", matrix_rows.second.body], ["response", matrix_rows.third.body]])
          expect(Response.third.choices.pluck(:body, :position)).to eq([["Third", 0], ["response", 1]])
        end

        # This is to ensure that always exists a uniq identifier per-user
        context "and user is registered" do
          let(:ip_hash) { nil }

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "have responses with session_token information" do
            command.call

            expect(Response.first.session_token).to eq(tokenize(current_user.id))
            expect(Response.first.ip_hash).to be_nil
            expect(Response.second.session_token).to eq(tokenize(current_user.id))
            expect(Response.second.ip_hash).to be_nil
            expect(Response.third.session_token).to eq(tokenize(current_user.id))
            expect(Response.third.ip_hash).to be_nil
          end
        end

        context "with attachments" do
          let(:question1) { create(:questionnaire_question, questionnaire:, question_type: :files) }
          let(:uploaded_files) do
            [
              {
                title: "Picture of the city",
                file: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"))
              },
              {
                title: "Example document",
                file: upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"))
              }
            ]
          end
          let(:form_params) do
            {
              "responses" => [
                {
                  "add_documents" => uploaded_files,
                  "question_id" => question1.id
                }
              ],
              "tos_agreement" => "1"
            }
          end

          context "when attachments are allowed" do
            it "creates multiple attachments for the proposal" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(2)
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to be_a(Decidim::Forms::Response)
            end
          end

          context "when attachments are allowed and file is invalid" do
            let(:uploaded_files) do
              [
                {
                  title: "Picture of the city",
                  file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg")
                },
                {
                  title: "Text document",
                  file: upload_test_file(Decidim::Dev.asset("invalid_extension.log"), content_type: "text/plain")
                }
              ]
            end

            it "does not create attachments for the proposal" do
              expect { command.call }.not_to change(Decidim::Attachment, :count)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end

          context "when the user has responded the survey" do
            let!(:response) { create(:response, questionnaire:, question: question1, user: current_user) }

            it "does not create questionnaire responses" do
              expect { command.call }.not_to change(Response, :count)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end
        end

        context "when display_conditions are not mandatory on the same question but are fulfilled" do
          let(:questionnaire_conditioned) { create(:questionnaire, questionnaire_for: participatory_process) }
          let!(:option1) { create(:response_option, question: condition_question) }
          let!(:option2) { create(:response_option, question: condition_question) }
          let!(:option3) { create(:response_option, question: condition_question) }
          let!(:condition_question) do
            create(
              :questionnaire_question,
              questionnaire: questionnaire_conditioned,
              mandatory: false,
              question_type: "single_option"
            )
          end
          let!(:question) { create(:questionnaire_question, questionnaire: questionnaire_conditioned, question_type: "short_response") }
          let!(:display_condition) { create(:display_condition, question:, condition_question:, condition_type: :equal, response_option: option1, mandatory: false) }
          let!(:display_condition2) { create(:display_condition, question:, condition_question:, condition_type: :equal, response_option: option3, mandatory: false) }
          let(:form_params) do
            {
              "responses" => [
                {
                  "choices" => [
                    { "body" => option1.body, "response_option_id" => option1.id }
                  ],
                  "question_id" => condition_question.id
                },
                {
                  "body" => "response_test",
                  "question_id" => question.id
                }
              ],
              "tos_agreement" => "1"
            }
          end
          let(:command) { described_class.new(form, questionnaire_conditioned) }

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a questionnaire response for each question responded" do
            expect do
              command.call
            end.to change(Response, :count).by(2)
            expect(Response.all.map(&:questionnaire)).to eq([questionnaire_conditioned, questionnaire_conditioned])
          end

          it "creates responses with the correct information" do
            command.call

            expect(Response.first.choices.first.response_option).to eq(option1)
            expect(Response.second.body).to eq("response_test")
          end
        end

        context "when questionnaire component is a survey" do
          let(:manifest_name) { "surveys" }
          let(:manifest) { Decidim.find_component_manifest(manifest_name) }

          let!(:component) do
            create(:component,
                   manifest:,
                   participatory_space: participatory_process,
                   published_at: nil)
          end
          let!(:survey) { create(:survey, component:, questionnaire:) }

          let(:responses) do
            survey.questionnaire.questions.map do |question|
              create(:response, questionnaire: survey.questionnaire, question:, user: current_user)
            end
          end

          let(:event_arguments) do
            {
              resource: questionnaire,
              extra: {
                session_token:,
                questionnaire:,
                event_author: current_user
              }
            }
          end
          let(:mailer) { double :mailer }

          it_behaves_like "fires an ActiveSupport::Notification event", "decidim.forms.response_questionnaire:after"
        end
      end

      describe "when the user is unregistered" do
        let(:current_user) { nil }

        context "and session exists" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "have responses session/ip information" do
            command.call

            expect(Response.first.session_token).to eq(tokenize(session_id))
            expect(Response.first.ip_hash).to eq(ip_hash)
            expect(Response.second.session_token).to eq(tokenize(session_id))
            expect(Response.second.ip_hash).to eq(ip_hash)
            expect(Response.third.session_token).to eq(tokenize(session_id))
            expect(Response.third.ip_hash).to eq(ip_hash)
          end
        end

        context "and visitor has responded the survey" do
          let!(:response) { create(:response, questionnaire:, question: question1, session_token: tokenize(session_id)) }

          it "does not create questionnaire responses" do
            expect { command.call }.not_to change(Response, :count)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "and session is missing" do
          let(:session_token) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not create questionnaire responses" do
            expect do
              command.call
            end.not_to change(Response, :count)
          end
        end
      end
    end
  end
end
