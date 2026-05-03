# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Accountability
    describe AccountabilityType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:accountability_component) }

      describe "" do
        subject { described_class }

        it_behaves_like "a component query type"
      end

      describe "results" do
        let!(:component_results) { create_list(:result, 2, component: model) }
        let!(:other_results) { create_list(:result, 2) }

        let(:query) { "{ results { edges { node { id } } } }" }

        it "returns the published results" do
          ids = response["results"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_results.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_results.map(&:id).map(&:to_s))
        end
      end

      describe "result" do
        let(:query) { "query Result($id: ID!){ result(id: $id) { id } }" }
        let(:variables) { { id: result.id.to_s } }

        context "when the result belongs to the component" do
          let!(:result) { create(:result, component: model) }

          it "finds the result" do
            expect(response["result"]["id"]).to eq(result.id.to_s)
          end
        end

        context "when the result does not belong to the component" do
          let!(:result) { create(:result, component: create(:accountability_component)) }

          it "raises error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Result not found")
          end
        end
      end

      describe "statuses" do
        let!(:statuses) { create_list(:status, 5, component: model) }
        let(:query) do
          %(
            {
              statuses {
                id
                key
                name { translations { locale text } }
              }
            }
          )
        end

        it "returns all statuses" do
          expect(response["statuses"]).to be_a(Array)
          expect(response["statuses"].count).to eq(5)

          response["statuses"].each do |response_status|
            status = statuses.find { |st| st.id.to_s == response_status["id"] }
            expect(response_status["key"]).to eq(status.key)

            translated_name = status.name.to_h
            machine_translations = translated_name.delete("machine_translations")
            translated_name.merge!(machine_translations) if machine_translations.is_a?(Hash)

            expect(response_status["name"]["translations"]).to match_array(
              translated_name.map { |key, val| { "locale" => key.to_s, "text" => val } }
            )
          end
        end
      end

      describe "status" do
        let(:query) { "query Status($id: ID!){ status(id: $id) { id } }" }
        let(:variables) { { id: status.id.to_s } }

        context "when the status belongs to the component" do
          let!(:status) { create(:status, component: model) }

          it "finds the status" do
            expect(response["status"]).to eq("id" => status.id.to_s)
          end
        end

        context "when the status does not belong to the component" do
          let!(:status) { create(:status, component: create(:accountability_component)) }

          it "raises error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Status not found")
          end
        end
      end
    end
  end
end
