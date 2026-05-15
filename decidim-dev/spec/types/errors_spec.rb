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

  before do
    I18n.backend.reload!
    I18n.backend.store_translations(
      :en,
      decidim: {
        test: "Test %{name}"
      }
    )
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

  context "when Decidim::Api::Errors::LocaleError is raised because of I18n::MissingInterpolationArgument is raised" do
    let(:type_class) do
      Class.new(Decidim::Api::Types::BaseObject) do
        graphql_name "ErrorTypeTest"
        field :tested_error, String, null: false

        def tested_error
          I18n.translate!("decidim.test", invalid_interpolation: "Testing Missing interpolation argument")
        end
      end
    end

    it "throws exception" do
      expect { response }.to raise_error(Decidim::Api::Errors::LocaleError, "There was an error while internally handling i18n data")
    end
  end

  context "when Decidim::Api::Errors::LocaleError is raised because of I18n::MissingTranslationData is raised" do
    let(:type_class) do
      Class.new(Decidim::Api::Types::BaseObject) do
        graphql_name "ErrorTypeTest"
        field :tested_error, String, null: false

        def tested_error
          I18n.translate!("decidim.invalid_translation_key")
        end
      end
    end

    it "throws exception" do
      expect { response }.to raise_error(Decidim::Api::Errors::LocaleError, "There was an error while internally handling i18n data")
    end
  end

  context "when Decidim::Api::Errors::InvalidLocaleError is raised because of I18n::InvalidLocaleError is raised" do
    let(:type_class) do
      Class.new(Decidim::Api::Types::BaseObject) do
        graphql_name "ErrorTypeTest"
        field :tested_error, String, null: false

        def tested_error
          I18n.with_locale("invalid_locale") do
            I18n.translate!("decidim.test", name: "test")
          end
        end
      end
    end

    it "throws exception" do
      expect { response }.to raise_error(Decidim::Api::Errors::InvalidLocaleError, "Invalid locale provided")
    end
  end
end
