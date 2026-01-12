# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Api
    module FooBar
      class DummyModel
        def initialize(id)
          @id = id
        end

        attr_reader :id

        def child
          self.class.new(id + 1)
        end

        def parent
          self.class.new(id + 1)
        end
      end

      class DummyType < GraphQL::Schema::Object
        description "Dummy type"
        field :child, ::Decidim::Api::FooBar::DummyType, "Dummy child field"
        field :id, Integer, "Dummy ID", null: false
        field :parent, ::Decidim::Api::FooBar::DummyType, "Dummy parent field"
      end

      class Query < GraphQL::Schema::Object
        description "The query root of this schema"
        field :parent, ::Decidim::Api::FooBar::DummyType, "Dummy field", null: false

        def parent
          DummyModel.new(0)
        end
      end
    end

    describe RecursionAnalyzer do
      include_context "with a graphql class type" do
        let(:schema) do
          Class.new(GraphQL::Schema) do
            query ::Decidim::Api::FooBar::Query
            query_analyzer Decidim::Api::RecursionAnalyzer
          end
        end
      end

      let(:model) do
        Decidim::Api::FooBar::DummyModel
      end

      context "when a recursion is detected" do
        let!(:query) do
          %(
            query {
              parent { child { parent { child { parent { child { id } } } } } }
            }
          )
        end

        it "raises an error" do
          expect { response }.to raise_error(Decidim::Api::Errors::RecursionLimitExceededError)
        end
      end

      context "when a recursion is not detected" do
        let!(:query) do
          %(
            query {
              parent { child { parent { child { id } } } }
            }
          )
        end

        it "raises an error" do
          expect { response }.not_to raise_error
        end
      end
    end
  end
end
