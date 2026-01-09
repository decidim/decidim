# frozen_string_literal: true

shared_context "with a graphql class type" do
  let!(:current_organization) { create(:organization) }
  let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
  let!(:current_component) { create(:component) }
  let(:api_scopes) do
    if current_user.present?
      Doorkeeper::OAuth::Scopes.from_array(Doorkeeper.config.scopes.all)
    else
      Doorkeeper::OAuth::Scopes.from_string("api:read")
    end
  end
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

  def raise_proper_error(error)
    code = error.dig("extensions", "code")

    # Matches the error code with the Error class
    # For instance, if the error code is NOT_FOUND_ERROR then it will raise the "Decidim::Api::Errors::NotFoundError" class
    raise "Decidim::Api::Errors::#{code.downcase.classify}".constantize, error["message"] if %w(
      LOCALE_ERROR
      NOT_FOUND_ERROR
      INVALID_LOCALE_ERROR
      PERMISSION_NOT_SET_ERROR
      ATTRIBUTE_VALIDATION_ERROR
      UNAUTHORIZED_FIELD_ERROR
      UNAUTHORIZED_OBJECT_ERROR
      MUTATION_NOT_AUTHORIZED_ERROR
      VALIDATION_ERROR
      TOO_MANY_ALIASES_ERROR
    ).include?(code)

    raise GraphQL::ExecutionError, error["message"]
  end

  def execute_query(query, variables)
    result = schema.execute(
      query,
      root_value:,
      context: {
        current_organization:,
        current_user:,
        current_component:,
        scopes: api_scopes
      },
      variables:
    )

    raise_proper_error(result["errors"].first) if result["errors"]

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
