# frozen_string_literal: true

shared_context "with a graphql type" do
  let!(:current_organization) { create(:organization) }
  let!(:current_user) { create(:user, organization: current_organization) }
  let(:model) { OpenStruct.new({}) }
  let(:type_class) { described_class }
  let(:variables) { {} }
  let(:root_value) { model }

  let(:schema) do
    klass = type_class

    GraphQL::Schema.define do
      query klass

      orphan_types(Decidim::Api.orphan_types)

      resolve_type ->(_type, _obj, _ctx) {}
    end
  end

  let(:response) do
    execute_query query, variables.stringify_keys
  end

  def execute_query(query, variables)
    result = schema.execute(
      query,
      root_value: root_value,
      context: {
        current_organization: current_organization,
        current_user: current_user
      },
      variables: variables
    )

    raise Exception, result["errors"].map { |e| e["message"] }.join(", ") if result["errors"]

    result["data"]
  end
end

shared_context "with a graphql scalar type" do
  include_context "with a graphql type"

  let(:root_value) do
    OpenStruct.new(value: model)
  end

  let(:type_class) do
    klass = described_class

    GraphQL::ObjectType.define do
      name "Test#{klass.name}"
      description "Fake test type"

      field :value, klass
    end
  end

  let(:response) do
    execute_query("{ value }", {}).try(:[], "value")
  end
end
