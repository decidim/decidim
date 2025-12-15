# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::Errors" do
  include_context "with a graphql class type"

  let(:query) do
    %(
      query {
        testedError
      }
    )
  end

  let(:schema) do
    klass = type_class
    Class.new(Decidim::Api::Schema) do
      query klass
    end
  end

  context "when Decidim::Api::Errors::PermissionNotSetError is raised" do
    let(:type_class) do
      Class.new(Decidim::Api::Types::BaseObject) do
        graphql_name "ErrorTypeTest"
        field :tested_error, String, null: false

        def tested_error
          raise Decidim::PermissionAction::PermissionNotSetError, "Exemplifying permission not set error"
        end
      end
    end

    it "throws exception" do
      expect { response }.to raise_error(Decidim::Api::Errors::PermissionNotSetError, /Permission has not been set for this/)
    end
  end
end
