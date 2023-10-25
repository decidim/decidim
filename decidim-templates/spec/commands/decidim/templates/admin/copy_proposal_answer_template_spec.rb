# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe CopyProposalAnswerTemplate do
        let(:template) { create(:template, :proposal_answer) }

        describe "when the template is invalid" do
          before do
            template.update(name: nil)
          end

          it "broadcasts invalid" do
            expect { described_class.call(template) }.to broadcast(:invalid)
          end
        end

        describe "when the template is valid" do
          let(:destination_template) do
            events = described_class.call(template)
            expect(events).to have_key(:ok)
            events[:ok]
          end

          it "applies template attributes to the questionnaire" do
            expect(destination_template.name).to eq(template.name)
            expect(destination_template.description).to eq(template.description)
            expect(destination_template.field_values).to eq(template.field_values)
            expect(destination_template.templatable).to eq(template.templatable)
            expect(destination_template.target).to eq(template.target)
          end
        end
      end
    end
  end
end
