# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Accountability
    describe StatusType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:status) }

      include_examples "traceable interface" do
        let!(:field) { :name }
      end
      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "key" do
        let(:query) { "{ key }" }

        it "returns the key field" do
          expect(response["key"]).to eq(model.key)
        end
      end

      describe "name" do
        let(:query) { '{ name { translation(locale:"en")}}' }

        it "returns the name field" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end

      describe "progress" do
        let(:query) { "{ progress }" }

        it "returns the progress field" do
          expect(response["progress"]).to eq(model.progress)
        end
      end

      describe "results" do
        let(:query) { "{ results { id } }" }

        it "returns empty" do
          expect(response["results"]).to eq([])
        end
      end

      context "when there are results" do
        let(:results) { create_list(:result, 2) }

        before do
          model.update(results:)
        end

        describe "results" do
          let(:query) { "{ results { id } }" }

          it "returns the results" do
            expect(response["results"].first["id"]).to eq(results.first.id.to_s)
          end
        end
      end
    end
  end
end
