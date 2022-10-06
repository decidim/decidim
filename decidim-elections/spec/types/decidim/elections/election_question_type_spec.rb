# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Elections
    describe ElectionQuestionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:question) }

      it_behaves_like "traceable interface" do
        let(:author) { create(:user, :admin, organization: model.component.organization) }
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "maxSelections" do
        let(:query) { "{ maxSelections }" }

        it "returns the election max_selections" do
          expect(response["maxSelections"]).to eq(model.max_selections)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the election weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "randomAnswersOrder" do
        let(:query) { "{ randomAnswersOrder }" }

        it "returns the election random_answers_order" do
          expect(response["randomAnswersOrder"]).to eq(model.random_answers_order)
        end
      end

      describe "answers" do
        let!(:question2) { create(:question, :complete) }
        let(:query) { "{ answers { id } }" }

        it "returns the question answers" do
          ids = response["answers"].map { |question| question["id"] }
          expect(ids).to include(*model.answers.map(&:id).map(&:to_s))
          expect(ids).not_to include(*question2.answers.map(&:id).map(&:to_s))
        end
      end

      describe "minSelections" do
        let(:query) { "{ minSelections }" }

        it "returns the election min_selections" do
          expect(response["minSelections"]).to eq(model.min_selections)
        end
      end
    end
  end
end
