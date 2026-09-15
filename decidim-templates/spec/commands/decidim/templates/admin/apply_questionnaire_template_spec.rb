# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/shared_examples/copies_all_questionnaire_contents_examples"

module Decidim
  module Templates
    module Admin
      describe ApplyQuestionnaireTemplate do
        let(:dummy_questionnaire) { create(:questionnaire_template) }
        let(:template) { dummy_questionnaire.class.includes(:templatable).find(dummy_questionnaire.id) }

        let(:destination_questionnaire) { create(:questionnaire, questionnaire_for: template) }
        let(:command) { described_class.new(destination_questionnaire, template) }

        describe "when the template is nil" do
          let(:command) { described_class.new(destination_questionnaire, nil) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        describe "when the template is valid" do
          before do
            expect { command.call }.to broadcast(:ok)
          end

          it "applies template attributes to the questionnaire" do
            destination_questionnaire.reload
            expect(destination_questionnaire.title).to eq(template.templatable.title)
            expect(destination_questionnaire.description).to eq(template.templatable.description)
            expect(destination_questionnaire.tos).to eq(template.templatable.tos)
          end

          context "when the questionnaire has all question types and display conditions" do
            let(:dummy_questionnaire) { create(:questionnaire_template, :with_all_questions) }

            it_behaves_like "copies all questionnaire contents"
          end
        end
      end
    end
  end
end
