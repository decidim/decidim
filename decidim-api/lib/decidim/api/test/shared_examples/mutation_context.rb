# frozen_string_literal: true

require "decidim/api/test/type_context"
shared_context "with a graphql class mutation" do
  include_context "with a graphql class type"

  let!(:current_user) do
    case user_type
    when :admin
      create(:user, :admin, :confirmed, organization: current_organization)
    when :api_user
      create(:api_user, organization: current_organization)
    else
      create(:user, :confirmed, organization: current_organization)
    end
  end
  let(:user_type) { :user }

  let(:api_scopes) do
    if user_type == :api_user
      Doorkeeper::OAuth::Scopes.from_array(["api:read", "api:write"])
    else
      Doorkeeper::OAuth::Scopes.from_array(Doorkeeper.config.scopes.all)
    end
  end

  let(:schema) do
    klass = type_class
    field_name = klass.graphql_name.underscore.to_sym
    root = root_klass
    Class.new(Decidim::Api::Schema) do
      mutation(Class.new(root) do
        graphql_name klass.graphql_name

        field field_name, mutation: klass
      end)
    end
  end

  shared_examples "admin API access checks" do |scenario|
    context "with an admin user" do
      it_behaves_like scenario do
        let!(:user_type) { :admin }
      end
    end

    context "with api_user" do
      context "when it has permissions" do
        let(:api_scopes) { Doorkeeper::OAuth::Scopes.from_array(Doorkeeper.config.scopes.all) }

        it_behaves_like scenario do
          let!(:user_type) { :api_user }
        end
      end

      context "when it has no permissions" do
        let(:api_scopes) { Doorkeeper::OAuth::Scopes.from_array(Doorkeeper.config.scopes.all) }

        it "raises Unauthorized Field Error" do
          expect { response }.to raise_error(GraphQL::ExecutionError, /you do not have permission/)
        end
      end
    end

    context "with normal user" do
      it "raises Unauthorized Field Error" do
        expect { response }.to raise_error(GraphQL::ExecutionError, /you do not have permission/)
      end
    end
  end
end
