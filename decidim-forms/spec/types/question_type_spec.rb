# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/timestamps_interface_examples"

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

      describe "answerOptions" do
        let(:query) { "{ answerOptions { id } }" }
        let(:model) { create(:questionnaire_question, :with_answer_options, question_type: :single_option) }

        it "returns the question's answer options corresponding to question_for_id" do
          ids = response["answerOptions"].map { |item| item["id"] }
          expect(ids).to include(*model.answer_options.map(&:id).map(&:to_s))
        end
      end
    end
  end
end
