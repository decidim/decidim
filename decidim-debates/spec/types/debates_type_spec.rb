# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Debates
    describe DebatesType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:debates_component) }

      it_behaves_like "a component query type"

      describe "debates" do
        let!(:component_debates) { create_list(:debate, 2, component: model) }
        let!(:other_debates) { create_list(:debate, 2) }

        let(:query) { "{ debates { edges { node { id } } } }" }

        it "returns the debates" do
          ids = response["debates"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_debates.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_debates.map(&:id).map(&:to_s))
        end
      end

      describe "debate" do
        let(:query) { "query Debate($id: ID!){ debate(id: $id){ id } }" }
        let(:variables) { { id: debate.id.to_s } }

        context "when the debate belongs to the component" do
          let(:debate) { create(:debate, component: model) }

          it "finds the debate" do
            expect(response["debate"]["id"]).to eq(debate.id.to_s)
          end
        end

        context "when the debate does not belong to the component" do
          let(:debate) { create(:debate, component: create(:debates_component)) }

          it "does not find the debate" do
            expect(response["debate"]).to be_nil
          end
        end
      end
    end
  end
end
