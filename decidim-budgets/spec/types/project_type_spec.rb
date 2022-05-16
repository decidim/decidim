# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/categorizable_interface_examples"
require "decidim/core/test/shared_examples/scopable_interface_examples"
require "decidim/core/test/shared_examples/attachable_interface_examples"

module Decidim
  module Budgets
    describe ProjectType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:project) }

      include_examples "categorizable interface"
      include_examples "scopable interface"
      include_examples "attachable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale:"en")}}' }

        it "returns the title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale:"en")}}' }

        it "returns the description" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "budget_amount" do
        let(:query) { "{ budget_amount }" }

        it "returns the budget amount" do
          expect(response["budget_amount"]).to eq(model.budget_amount)
        end
      end

      describe "selected" do
        let(:query) { "{ selected }" }

        context "when the project is selected" do
          let(:model) { create(:project, :selected) }

          it "returns true" do
            expect(response["selected"]).to be true
          end
        end

        context "when the project is not selected" do
          it "returns false" do
            expect(response["selected"]).to be_falsey
          end
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the resource was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the resource was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the reference" do
          expect(response["reference"]).to eq(model.reference)
        end
      end
    end
  end
end
