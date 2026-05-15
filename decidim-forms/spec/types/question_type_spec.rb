# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Forms
    describe QuestionType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:questionnaire_question) }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the question's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "body" do
        let(:query) { "{ body { translation(locale: \"ca\") } }" }

        it "returns the question's body" do
          expect(response["body"]["translation"]).to eq(model.body["ca"])
        end
      end

      describe "description" do
        let(:query) { "{ description { translation(locale: \"ca\") } }" }

        it "returns the question's description" do
          expect(response["description"]["translation"]).to eq(model.description["ca"])
        end
      end

      describe "mandatory" do
        let(:query) { "{ mandatory }" }

        it "returns the question's mandatory" do
          expect(response["mandatory"]).to eq(model.mandatory)
        end
      end

      describe "max_choices" do
        let(:query) { "{ maxChoices }" }

        it "returns the question's maxChoices" do
          expect(response["maxChoices"]).to eq(model.max_choices)
        end
      end

      describe "questionType" do
        let(:query) { "{ questionType }" }

        it "returns the question's questionType" do
          expect(response["questionType"]).to eq(model.question_type)
        end
      end

      describe "responseOptions" do
        let(:query) { "{ responseOptions { id } }" }
        let(:model) { create(:questionnaire_question, :with_response_options, question_type: :single_option) }

        it "returns the question's response options corresponding to question_for_id" do
          ids = response["responseOptions"].map { |item| item["id"] }
          expect(ids).to include(*model.response_options.map(&:id).map(&:to_s))
        end
      end

      describe "matrixRows" do
        let(:query) { "{ matrixRows { id } }" }
        let!(:model) { create(:questionnaire_question, question_type: "matrix_multiple") }
        let!(:matrixmultiple_response_options) { create_list(:response_option, 3, question: model) }
        let!(:matrixmultiple_rows) { create_list(:question_matrix_row, 3, question: model) }

        it "returns the question's response options corresponding to question_for_id" do
          ids = response["matrixRows"].map { |item| item["id"] }
          expect(ids).to include(*model.matrix_rows.map(&:id).map(&:to_s))
        end
      end
    end
  end
end
