# frozen_string_literal: true

RSpec.shared_context "graphql type" do
  let!(:current_organization) { create(:organization) }
  let!(:current_user) { create(:user, organization: current_organization) }
  let(:model) { OpenStruct.new({}) }

  let(:schema) do
    resolver = ->(_obj, _args, _ctx) { model }
    type_class = described_class

    query_type = GraphQL::ObjectType.define do
      name "FakeTestQuery"

      field :type, !type_class do
        resolve resolver
      end
    end

    GraphQL::Schema.define do
      query query_type
      resolve_type ->(obj, ctx) {}
    end
  end

  let(:response) do
    execute_query "{ type #{query}}"
  end

  def execute_query(query, variables = {})
    result = schema.execute(
      query,
      context: {
        current_organization: current_organization,
        current_user: current_user
      },
      variables: variables
    )

    raise Exception, result["errors"].map { |e| e["message"] }.join(", ") if result["errors"]
    result["data"]["type"]
  end
end
