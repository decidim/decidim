# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::QueryExtensions do
  let(:organization) { create(:organization) }
  let(:current_user) { nil }
  let(:context) do
    {
      current_organization: organization,
      current_user:,
      scopes: Doorkeeper::OAuth::Scopes.from_string("api:read"),
      can_introspect: false
    }
  end

  describe "commentable query" do
    let(:query) do
      <<~GRAPHQL
        query Commentable($id: String!, $type: String!, $locale: String!, $toggleTranslations: Boolean!) {
          commentable(id: $id, type: $type, locale: $locale, toggleTranslations: $toggleTranslations) {
            id
            type
          }
        }
      GRAPHQL
    end

    context "when type does not include Decidim::Comments::Commentable" do
      it "raises an error for Decidim::System::Admin" do
        variables = {
          id: "1",
          type: "Decidim::System::Admin",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to eq("Invalid commentable type")
      end

      it "raises an error for Decidim::User" do
        variables = {
          id: "1",
          type: "Decidim::User",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to eq("Invalid commentable type")
      end

      it "raises an error for Doorkeeper::AccessToken" do
        variables = {
          id: "1",
          type: "Doorkeeper::AccessToken",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to eq("Invalid commentable type")
      end

      it "raises an error for arbitrary class names" do
        variables = {
          id: "1",
          type: "SomeRandomClass",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to eq("Invalid commentable type")
      end

      it "raises an error for non-existent class names" do
        variables = {
          id: "1",
          type: "NonExistent::Class::Name",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to eq("Invalid commentable type")
      end
    end

    context "when type includes Decidim::Comments::Commentable" do
      it "accepts Decidim::Proposals::Proposal" do
        variables = {
          id: "1",
          type: "Decidim::Proposals::Proposal",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end

      it "accepts Decidim::Meetings::Meeting" do
        variables = {
          id: "1",
          type: "Decidim::Meetings::Meeting",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end

      it "accepts Decidim::Debates::Debate" do
        variables = {
          id: "1",
          type: "Decidim::Debates::Debate",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end

      it "accepts Decidim::Budgets::Project" do
        variables = {
          id: "1",
          type: "Decidim::Budgets::Project",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end

      it "accepts Decidim::Blogs::Post" do
        variables = {
          id: "1",
          type: "Decidim::Blogs::Post",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end

      it "accepts Decidim::Accountability::Result" do
        variables = {
          id: "1",
          type: "Decidim::Accountability::Result",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end

      it "accepts Decidim::Initiative" do
        variables = {
          id: "1",
          type: "Decidim::Initiative",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end

      it "accepts Decidim::Comments::Comment" do
        variables = {
          id: "1",
          type: "Decidim::Comments::Comment",
          locale: "en",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).not_to be_present
      end
    end

    context "when locale is invalid" do
      it "raises an error for invalid locale" do
        variables = {
          id: "1",
          type: "Decidim::Proposals::Proposal",
          locale: "invalid_locale",
          toggleTranslations: false
        }

        result = Decidim::Api::Schema.execute(query, variables:, context:)
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("is not a valid locale")
      end
    end
  end
end
