# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe AnswerQuestionnaire do
      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: current_organization) }
      let(:session_id) { "session-string" }
      let(:remote_ip) { "1.1.1.1" }
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
      let(:form_params) do
        {
          "answers" => [
            {
              "body" => "This is my first answer",
              "question_id" => question_1.id
            },
            {
              "choices" => [
                { "answer_option_id" => answer_option_ids[0], "body" => "My" },
                { "answer_option_id" => answer_option_ids[1], "body" => "second" },
                { "answer_option_id" => answer_option_ids[2], "body" => "answer" }
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
          current_organization: current_organization
        )
      end
      let(:command) { described_class.new(form, current_user, questionnaire, request) }

      def tokenize(id)
        Digest::MD5.hexdigest("#{id}-#{Rails.application.secrets.secret_key_base}")
      end

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
          expect(Answer.second.choices.pluck(:body)).to eq(%w(My second answer))
          expect(Answer.third.choices.pluck(:body, :position)).to eq([["Third", 0], ["answer", 1]])
        end

        # This is to ensure that always exists a uniq identifier per-user
        context "and no session exists" do
          let(:session_id) { nil }
          let(:remote_ip) { nil }

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

        context "and remote_ip exists" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "have answers session/ip information" do
            command.call

            expect(Answer.first.session_token).to eq(tokenize(session_id))
            expect(Answer.first.ip_hash).to eq(tokenize(remote_ip))
            expect(Answer.second.session_token).to eq(tokenize(session_id))
            expect(Answer.second.ip_hash).to eq(tokenize(remote_ip))
            expect(Answer.third.session_token).to eq(tokenize(session_id))
            expect(Answer.third.ip_hash).to eq(tokenize(remote_ip))
          end
        end

        context "and remote_ip is missing" do
          let(:remote_ip) { nil }

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
