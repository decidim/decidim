# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Forms
    describe QuestionMatrixRowType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:question_matrix_row) }

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

      describe "position" do
        let(:query) { "{ position }" }

        it "returns the question's position" do
          expect(response["position"]).to eq(model.position)
        end
      end
    end
  end
end
