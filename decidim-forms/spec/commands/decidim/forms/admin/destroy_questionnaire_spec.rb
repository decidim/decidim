# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      describe DestroyQuestionnaire do
        let(:current_organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
        let(:subject) { described_class.new(questionnaire) }

        describe "when the questionnaire has question answers" do
          before do
            create :question_answer, questionnaire: questionnaire
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "doesn't delete the questionnaire" do
            expect { subject.call }.not_to change(Decidim::Forms::Questionnaire, :count)
          end
        end

        describe "when the questionnaire has answers" do
          before do
            create :answer, questionnaire: questionnaire
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "doesn't delete the questionnaire" do
            expect { subject.call }.not_to change(Decidim::Forms::Questionnaire, :count)
          end
        end

        describe "when the questionnaire is not answered" do
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "deletes the questionnaire" do
            questionnaire
            expect { subject.call }.to change(Decidim::Forms::Questionnaire, :count).by(-1)
          end
        end
      end
    end
  end
end
