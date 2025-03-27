# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      describe QuestionnaireResponsesHelper do
        describe "display_percentage" do
          context "when given a number" do
            let(:number) { 84.64 }

            it "displays the number formatted as percentage with no decimals" do
              expect(helper.display_percentage(number)).to eq("85%")
            end
          end
        end
      end
    end
  end
end
