# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Api
    describe Schema do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Api::QueryType }

      context "when restricting number of aliases" do
        let!(:query) do
          %({
          invalias0 : __typename
          invalias1 : __typename
          invalias2 : __typename
          invalias3 : __typename
          invalias4 : __typename
          invalias5 : __typename
        })
        end

        it "raises an error" do
          expect { response }.to raise_error(GraphQL::ExecutionError)
        end

        context "when using a custom value" do
          around do |example|
            aliases = Decidim::Api.max_aliases

            # 5 is the default value, we have a number alias in the above query definition, and we just set a higher number
            Decidim::Api.max_aliases = 10
            example.run

            Decidim::Api.max_aliases = aliases
          end

          it "runs successfully" do
            expect(response).to include("invalias0" => "Query")
          end
        end
      end

      context "when allowing number of aliases" do
        let!(:query) do
          %({
          invalias0 : __typename
          invalias1 : __typename
          invalias2 : __typename
          invalias3 : __typename
          invalias4 : __typename
        })
        end

        it "runs successfully" do
          expect(response).to include("invalias0" => "Query")
        end
      end
    end
  end
end
