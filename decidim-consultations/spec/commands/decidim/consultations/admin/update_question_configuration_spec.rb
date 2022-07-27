# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UpdateQuestionConfiguration do
        let(:question) { create :question }
        let(:min_votes) { "3" }
        let(:max_votes) { "5" }
        let(:params) do
          {
            question: {
              id: question.id,
              min_votes:,
              max_votes:,
              instructions_en: "Foo instructions",
              instructions_ca: "Foo instructions",
              instructions_es: "Foo instructions"
            }
          }
        end
        let(:form) { QuestionConfigurationForm.from_params(params) }
        let(:command) { described_class.new(question, form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the consultation" do
            command.call
            question.reload

            expect(question.min_votes).not_to eq(3)
          end
        end

        describe "when question is not valid" do
          before do
            allow(question).to receive(:valid?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the consultation" do
            command.call
            question.reload

            expect(question.min_votes).not_to eq(3)
          end
        end

        describe "when the configuration is not valid" do
          let(:max_votes) { "1" }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "adds errors to the form" do
            command.call

            expect(form.errors[:max_votes]).not_to be_empty
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the question" do
            expect { command.call }.to broadcast(:ok)
            question.reload

            expect(question.min_votes).to eq(3)
            expect(question.max_votes).to eq(5)
            expect(question.instructions["en"]).to eq("Foo instructions")
          end
        end
      end
    end
  end
end
