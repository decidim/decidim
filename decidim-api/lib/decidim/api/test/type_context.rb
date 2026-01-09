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
  let(:can_introspect) { Decidim::Api.enable_anonymous_introspection || current_user&.admin? }

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
      INTROSPECTION_DISABLED_ERROR
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
        scopes: api_scopes,
        can_introspect:
      },
      variables:
    )

    raise_proper_error(result["errors"].first) if result["errors"]

    result["data"]
  end
end

shared_examples "when the introspection is disabled" do
  shared_examples "check introspection behavior" do
    context "and the user is not authenticated" do
      let!(:current_user) { nil }

      it "raises an Decidim::Api::Errors::IntrospectionDisabledError" do
        expect { response }.to raise_error(Decidim::Api::Errors::IntrospectionDisabledError, "Introspection is disabled for this request")
      end
    end

    context "and the user is not an admin" do
      let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

      it "raises an Decidim::Api::Errors::IntrospectionDisabledError" do
        expect { response }.to raise_error(Decidim::Api::Errors::IntrospectionDisabledError, "Introspection is disabled for this request")
      end
    end

    context "and the user is an admin" do
      let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

      it "runs successfully" do
        expect { response }.not_to raise_error
      end
    end

    context "and the setting is true" do
      before do
        allow(Decidim::Api).to receive(:enable_anonymous_introspection).and_return(true)
      end

      it "runs successfully" do
        expect { response }.not_to raise_error
      end
    end

    context "and the setting is false" do
      before do
        allow(Decidim::Api).to receive(:enable_anonymous_introspection).and_return(false)
      end
      it "raises an Decidim::Api::Errors::IntrospectionDisabledError" do
        expect { response }.to raise_error(Decidim::Api::Errors::IntrospectionDisabledError, "Introspection is disabled for this request")
      end
    end
  end

  context "when requesting the schema introspection" do
    let(:query) do
      %( query { __schema { types { fields { type { fields { type { fields { type { fields { type { name } } } } } } } } } } } )
    end

    it_behaves_like "check introspection behavior"
  end

  context "when requesting the type introspection" do
    let(:query) do
      %( query CircularIntrospection {
  __type(name: "User") {
    fields {
      type {
        fields {
          type {
            fields {
              type {
                name
              }
            }
          }
        }
      }
    }
  }
} )
    end

    it_behaves_like "check introspection behavior"
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
