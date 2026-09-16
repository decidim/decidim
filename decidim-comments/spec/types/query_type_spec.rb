# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "decidim/api/test/type_context"

module Decidim::Api
  describe QueryType do
    include_context "with a graphql class type"

    describe "session" do
      let(:query) { "{ session { user { name } } }" }

      context "when the user is logged in" do
        it "return current user data" do
          expect(response["session"]).to include("user" => { "name" => current_user.name })
        end
      end

      context "when the user is not logged in" do
        let!(:current_user) { nil }

        it "return a nil object" do
          expect(response["session"]).to be_nil
        end
      end
    end

    describe "commentable" do
      let(:model) { create(:dummy_resource, :published) }
      let(:query) { %({ commentable(type: "#{model.commentable_type}", id: "#{id}", locale: "#{locale}", toggleTranslations: false) { id } }) }
      let(:id) { model.id }
      let(:locale) { "en" }

      it "returns the commentable response" do
        expect(response["commentable"]).to eq("id" => model.id.to_s)
      end

      context "with unknown locale" do
        let(:locale) { "tlh" }

        it "returns a proper GraphQL error" do
          expect { response }.to raise_error("#{locale} is not a valid locale")
        end
      end

      context "with unknown record id" do
        let(:id) { model.id + 1000 }

        it "returns nothing" do
          expect(response["commentable"]).to be_nil
        end
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

    describe "user" do
      let!(:user) { create(:user, :confirmed, organization: current_organization) }

      context "with ID" do
        let(:query) { %({ user(id: "#{user.id}") { id, name } }) }

        it "returns the correct user" do
          expect(response["user"]).to eq("id" => user.id.to_s, "name" => user.name)
        end
      end

      context "with nickname" do
        let(:query) { %({ user(nickname: "#{user.nickname}") { id, name } }) }

        it "returns the correct user" do
          expect(response["user"]).to eq("id" => user.id.to_s, "name" => user.name)
        end
      end

      context "with no argument" do
        let(:query) { %({ user { id, name } }) }

        it "returns nothing" do
          expect(response["user"]).to be_nil
        end
      end
    end
  end
end
