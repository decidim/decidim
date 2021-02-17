# frozen_string_literal: true

shared_context "with a graphql class type" do
  let!(:current_organization) { create(:organization) }
  let!(:current_user) { create(:user, organization: current_organization) }
  let(:model) { OpenStruct.new({}) }
  let(:type_class) { described_class }
  let(:variables) { {} }
  let(:root_value) { model }

  let(:schema) do
    klass = type_class
    Class.new(Decidim::Api::Schema) do
      query klass
      orphan_types(Decidim::Api.orphan_types)
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

    raise StandardError, result["errors"].map { |e| e["message"] }.join(", ") if result["errors"]

    result["data"]
  end
end

shared_context "with a graphql scalar class type" do
  include_context "with a graphql class type"

  let(:root_value) do
    OpenStruct.new(value: model)
  end

  let(:type_class) do
    klass = described_class

    Class.new(GraphQL::Schema::Object) do
      graphql_name "ScalarFieldType"
      description "Fake test type"

      field :value, klass, null: false
    end
  end

  let(:response) do
    execute_query("{ value }", {}).try(:[], "value")
  end
end
