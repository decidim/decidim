# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/shared_examples/copies_all_questionnaire_contents_examples"

module Decidim
  module Templates
    module Admin
      describe CopyQuestionnaireTemplate do
        let(:template) { create(:questionnaire_template) }

        describe "when the template is invalid" do
          before do
            template.update(name: nil)
          end

          it "broadcasts invalid" do
            expect { described_class.call(template) }.to broadcast(:invalid)
          end
        end

        describe "when the template is valid" do
          let(:destination_questionnaire) do
            events = described_class.call(template)
            # events => { :ok => copied_template }
            expect(events).to have_key(:ok)
            events[:ok].templatable
          end

          it "applies template attributes to the questionnaire" do
            expect(destination_questionnaire.title).to eq(template.templatable.title)
            expect(destination_questionnaire.description).to eq(template.templatable.description)
            expect(destination_questionnaire.tos).to eq(template.templatable.tos)
          end

          context "when the questionnaire has all question types and display conditions" do
            let!(:template) { create(:questionnaire_template, :with_all_questions) }

            it_behaves_like "copies all questionnaire contents"
          end
        end
      end
    end
  end
end
