# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Elections
    describe ElectionResultType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:election_result) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "value" do
        let(:query) { "{ value }" }

        it "returns the votes count" do
          expect(response["value"]).to eq(model.value)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the voting was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the voting was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "answer" do
        let(:query) { "{ answer { id } }" }

        it "returns the answer for this result" do
          expect(response["answer"]["id"]).to eq(model.answer.id.to_s)
        end
      end

      describe "question" do
        let(:query) { "{ question { id } }" }

        it "returns the question for this result" do
          expect(response["question"]["id"]).to eq(model.question.id.to_s)
        end
      end
    end
  end
end
