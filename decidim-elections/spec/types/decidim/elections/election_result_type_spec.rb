# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Elections
    describe ElectionResultType, type: :graphql do
      include_context "with a graphql class type"

      let(:polling_station) { create(:polling_station) }
      let(:model) { create(:election_result, polling_station: polling_station) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "votes_count" do
        let(:query) { "{ votesCount }" }

        it "returns the votes count" do
          expect(response["votesCount"]).to eq(model.votes_count)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the voting was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the voting was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "answer" do
        let(:query) { "{ answer { id } }" }

        it "returns the answer for this result" do
          expect(response["answer"]["id"]).to eq(model.answer.id.to_s)
        end
      end

      describe "polling station" do
        let(:query) { "{ pollingStation { id } }" }

        it "returns the polling station for this result" do
          expect(response["pollingStation"]["id"]).to eq(model.polling_station.id.to_s)
        end
      end
    end
  end
end
