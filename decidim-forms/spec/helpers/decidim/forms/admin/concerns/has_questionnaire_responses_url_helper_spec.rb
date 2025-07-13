# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      module Concerns
        describe HasQuestionnaireResponsesUrlHelper, type: :controller do
          controller(ApplicationController) do
            include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponsesUrlHelper

            def index; end
          end

          let(:questionnaire) { double("Questionnaire", questionnaire_for: "/test-path") }

          before do
            allow(controller).to receive(:questionnaire).and_return(questionnaire)
            routes.draw { get "index" => "anonymous#index" }
          end

          describe "#questionnaire_url" do
            it "returns the correct URL for the questionnaire" do
              expect(controller.questionnaire_url).to eq("/test-path")
            end
          end
        end
      end
    end
  end
end
