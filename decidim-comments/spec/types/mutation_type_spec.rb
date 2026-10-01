# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Api
    describe MutationType do
      include_context "with a graphql class type"

      describe "commentable" do
        let(:query) do
          <<~GRAPHQL
            mutation Commentable($id: String!, $type: String!, $locale: String, $toggleTranslations: Boolean) {
              commentable(id: $id, type: $type, locale: $locale, toggleTranslations: $toggleTranslations) {
                id
              }
            }
          GRAPHQL
        end

        let(:variables) do
          {
            id: commentable_id.to_s,
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
          it "fetches the commentable" do
            expect(response["commentable"]).to include("id" => commentable_id.to_s)
          end
        end

        context "when type does not include Decidim::Comments::Commentable" do
          let(:commentable_id) { "1" }

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
          let!(:commentable) { create(:dummy_resource) }
          let(:commentable_id) { commentable.id }
          let(:tested_class) { commentable.commentable_type }

          it_behaves_like "valid commentable type"

          context "without locale and toggleTranslations arguments" do
            let(:variables) do
              {
                id: commentable_id.to_s,
                type: tested_class
              }
            end

            it_behaves_like "valid commentable type"
          end
        end
      end

      describe "comment" do
        let!(:comment) { create(:comment) }
        let(:query) { "{ comment(id: \"#{comment.id}\", locale: \"en\", toggleTranslations: false) { id } }" }

        it "fetches the comment given its id" do
          expect(response["comment"]).to include("id" => comment.id.to_s)
        end

        context "without locale and toggleTranslations arguments" do
          let(:query) { "{ comment(id: \"#{comment.id}\") { id } }" }

          it "fetches the commentable given its id and commentable_type" do
            expect(response["comment"]).to include("id" => comment.id.to_s)
          end
        end
      end
    end
  end
end
