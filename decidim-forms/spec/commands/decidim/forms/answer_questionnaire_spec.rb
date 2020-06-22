# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe AnswerQuestionnaire do
      def tokenize(id)
        Digest::MD5.hexdigest("#{id}-#{Rails.application.secrets.secret_key_base}")
      end

      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: current_organization) }
      let(:session_id) { "session-string" }
      let(:session_token) { tokenize(current_user&.id || session_id) }
      let(:remote_ip) { "1.1.1.1" }
      let(:ip_hash) { tokenize(remote_ip) }
      let(:request) do
        double(
          session: { session_id: session_id },
          remote_ip: remote_ip
        )
      end

      let(:participatory_process) { create(:participatory_process, organization: current_organization) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question_1) { create(:questionnaire_question, questionnaire: questionnaire) }
      let(:question_2) { create(:questionnaire_question, questionnaire: questionnaire) }
      let(:question_3) { create(:questionnaire_question, questionnaire: questionnaire) }
      let(:answer_options) { create_list(:answer_option, 5, question: question_2) }
      let(:answer_option_ids) { answer_options.pluck(:id).map(&:to_s) }
      let(:matrix_rows) { create_list(:question_matrix_row, 3, question: question_2) }
      let(:matrix_row_ids) { matrix_rows.pluck(:id).map(&:to_s) }
      let(:form_params) do
        {
          "responses" => [
            {
              "body" => "This is my first answer",
              "question_id" => question_1.id
            },
            {
              "choices" => [
                { "answer_option_id" => answer_option_ids[0], "body" => "My", "matrix_row_id" => matrix_row_ids[0] },
                { "answer_option_id" => answer_option_ids[1], "body" => "second", "matrix_row_id" => matrix_row_ids[1] },
                { "answer_option_id" => answer_option_ids[2], "body" => "answer", "matrix_row_id" => matrix_row_ids[2] }
              ],
              "question_id" => question_2.id
            },
            {
              "choices" => [
                { "answer_option_id" => answer_option_ids[3], "body" => "Third", "position" => 0 },
                { "answer_option_id" => answer_option_ids[4], "body" => "answer", "position" => 1 }
              ],
              "question_id" => question_3.id
            }
          ],
          "tos_agreement" => "1"
        }
      end
      let(:form) do
        QuestionnaireForm.from_params(
          form_params
        ).with_context(
          current_organization: current_organization,
          session_token: session_token,
          ip_hash: ip_hash
        )
      end
      let(:command) { described_class.new(form, current_user, questionnaire) }

      describe "when the form is invalid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create questionnaire answers" do
          expect do
            command.call
          end.not_to change(Answer, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a questionnaire answer for each question answered" do
          expect do
            command.call
          end.to change(Answer, :count).by(3)
          expect(Answer.all.map(&:questionnaire)).to eq([questionnaire, questionnaire, questionnaire])
        end

        it "creates answers with the correct information" do
          command.call

          expect(Answer.first.body).to eq("This is my first answer")
          expect(Answer.second.choices.map { |a| [a.body, a.matrix_row.body] }).to eq([["My", matrix_rows.first.body], ["second", matrix_rows.second.body], ["answer", matrix_rows.third.body]])
          expect(Answer.third.choices.pluck(:body, :position)).to eq([["Third", 0], ["answer", 1]])
        end

        # This is to ensure that always exists a uniq identifier per-user
        context "and user is registered" do
          let(:ip_hash) { nil }

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "have answers with session_token information" do
            command.call

            expect(Answer.first.session_token).to eq(tokenize(current_user.id))
            expect(Answer.first.ip_hash).to eq(nil)
            expect(Answer.second.session_token).to eq(tokenize(current_user.id))
            expect(Answer.second.ip_hash).to eq(nil)
            expect(Answer.third.session_token).to eq(tokenize(current_user.id))
            expect(Answer.third.ip_hash).to eq(nil)
          end
        end
      end

      describe "when the user is unregistered" do
        let(:current_user) { nil }

        context "and session exists" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "have answers session/ip information" do
            command.call

            expect(Answer.first.session_token).to eq(tokenize(session_id))
            expect(Answer.first.ip_hash).to eq(ip_hash)
            expect(Answer.second.session_token).to eq(tokenize(session_id))
            expect(Answer.second.ip_hash).to eq(ip_hash)
            expect(Answer.third.session_token).to eq(tokenize(session_id))
            expect(Answer.third.ip_hash).to eq(ip_hash)
          end
        end

        context "and session is missing" do
          let(:session_token) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create questionnaire answers" do
            expect do
              command.call
            end.not_to change(Answer, :count)
          end
        end
      end
    end
  end
end
