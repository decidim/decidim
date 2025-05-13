# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Initiatives
    describe InitiativeType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:initiative, online_votes: { "total" => 5 }, offline_votes: { "total" => 3 }) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the initiative' slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "hashtag" do
        let(:query) { "{ hashtag }" }

        it "returns the initiative' hashtag" do
          expect(response["hashtag"]).to eq(model.hashtag)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the initiative was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the initiative was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the initiative was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(Decidim::EngineRouter.main_proxy(model).initiative_url(model))
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "signatureStartDate" do
        let(:query) { "{ signatureStartDate }" }

        it "returns the signature start date of the initiative" do
          expect(response["signatureStartDate"]).to eq(model.signature_start_date.to_date.iso8601)
        end
      end

      describe "signatureEndDate" do
        let(:query) { "{ signatureEndDate }" }

        it "returns when the initiative signature date ends" do
          expect(response["signatureEndDate"]).to eq(model.signature_end_date.to_date.iso8601)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the initiative' reference" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      describe "scope" do
        let(:query) { "{ scope { id } }" }

        it "has a scope" do
          expect(response).to include("scope" => { "id" => model.scope.id.to_s })
        end
      end

      context "without fields from AuthorInterface" do
        %w(name nickname avatarUrl profilePath badge organizationName deleted).each do |field|
          describe field do
            let(:query) { "{ #{field} }" }
            let(:msg) { "Field '#{field}' doesn't exist on type 'Initiative'" }

            it "has not have a #{field} field" do
              expect { response }.to raise_error(an_instance_of(StandardError).and(having_attributes(message: msg)))
            end
          end
        end
      end

      describe "offlineVotes" do
        let(:query) { "{ offlineVotes }" }

        it "has a offlineVotes" do
          expect(response).to include("offlineVotes" => model.offline_votes_count)
        end
      end

      describe "onlineVotes" do
        let(:query) { "{ onlineVotes }" }

        it "has a onlineVotes" do
          expect(response).to include("onlineVotes" => model.online_votes_count)
        end
      end

      describe "initiativeVotesCount" do
        let(:query) { "{ initiativeVotesCount }" }

        it "has an initiativeVotesCount" do
          expect(response).to include("initiativeVotesCount" => model.online_votes_count)
        end
      end

      describe "initiativeSupportsCount" do
        let(:query) { "{ initiativeSupportsCount }" }

        it "has an initiativeSupportsCount" do
          expect(response).to include("initiativeSupportsCount" => model.supports_count)
        end
      end
    end
  end
end
