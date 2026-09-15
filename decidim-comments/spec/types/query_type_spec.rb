# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Api
  describe QueryType do
    include_context "with a graphql class type"

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

      let(:type_class) { Decidim::Api::QueryType }
      let(:variables) do
        {
          id: "1",
          type: tested_class,
          locale: "en",
          toggleTranslations: false
        }
      end

      shared_examples "invalid commentable type" do
        it "raises an error" do
          expect { response }.to raise_error(GraphQL::ExecutionError, /Invalid commentable type/)
        end
      end

      shared_examples "valid commentable type" do
        it "prevents displaying an error" do
          expect(response).to eq("commentable" => nil)
        end
      end

      context "when type does not include Decidim::Comments::Commentable" do
        context "when Decidim::System::Admin" do
          let(:tested_class) { "Decidim::System::Admin" }

          it_behaves_like "invalid commentable type"
        end

        context "when Decidim::User" do
          let(:tested_class) { "Decidim::User" }

          it_behaves_like "invalid commentable type"
        end

        context "when Doorkeeper::AccessToken" do
          let(:tested_class) { "Doorkeeper::AccessToken" }

          it_behaves_like "invalid commentable type"
        end

        context "when arbitrary class names" do
          let(:tested_class) { "SomeRandomClass" }

          it_behaves_like "invalid commentable type"
        end

        context "when non-existent class names" do
          let(:tested_class) { "NonExistent::Class::Name" }

          it_behaves_like "invalid commentable type"
        end
      end

      context "when type includes Decidim::Comments::Commentable" do
        context "when Decidim::Proposals::Proposal" do
          let(:tested_class) { "Decidim::Proposals::Proposal" }

          it_behaves_like "valid commentable type"
        end

        context "when Decidim::Meetings::Meeting" do
          let(:tested_class) { "Decidim::Meetings::Meeting" }

          it_behaves_like "valid commentable type"
        end

        context "when Decidim::Debates::Debate" do
          let(:tested_class) { "Decidim::Debates::Debate" }

          it_behaves_like "valid commentable type"
        end

        context "when Decidim::Budgets::Project" do
          let(:tested_class) { "Decidim::Budgets::Project" }

          it_behaves_like "valid commentable type"
        end

        context "when Decidim::Blogs::Post" do
          let(:tested_class) { "Decidim::Blogs::Post" }

          it_behaves_like "valid commentable type"
        end

        context "when Decidim::Accountability::Result" do
          let(:tested_class) { "Decidim::Accountability::Result" }

          it_behaves_like "valid commentable type"
        end

        context "when Decidim::Initiative" do
          let(:tested_class) { "Decidim::Initiative" }

          it_behaves_like "valid commentable type"
        end

        context "when Decidim::Comments::Comment" do
          let(:tested_class) { "Decidim::Comments::Comment" }

          it_behaves_like "valid commentable type"
        end
      end

      context "when locale is invalid" do
        let(:tested_class) { "Decidim::Proposals::Proposal" }
        let(:variables) do
          {
            id: "1",
            type: tested_class,
            locale: "invalid_locale",
            toggleTranslations: false
          }
        end

        it "raises an error" do
          expect { response }.to raise_error(GraphQL::ExecutionError, /is not a valid locale/)
        end
      end
    end
  end
end
