# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Votings
    describe PollingStationClosureType, type: :graphql do
      include_context "with a graphql class type"

      let(:signed_at) { nil }
      let(:model) { create(:ps_closure, :with_results, signed_at: signed_at) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "polling_officer_notes" do
        let(:query) { "{ pollingOfficerNotes }" }

        it "returns the polling officer notes" do
          expect(response["pollingOfficerNotes"]).to eq(model.polling_officer_notes)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the closure was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the closure was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "election" do
        let(:query) { "{ election { id } }" }

        it "returns the election for this closure" do
          expect(response["election"]["id"]).to eq(model.election.id.to_s)
        end
      end

      describe "polling_station" do
        let(:query) { "{ pollingStation { id } }" }

        it "returns the polling_station for this closure" do
          expect(response["pollingStation"]["id"]).to eq(model.polling_station.id.to_s)
        end
      end

      describe "results" do
        let(:query) { "{ results { id } }" }

        it "returns the results" do
          ids = response["results"].map { |result| result["id"].to_i }
          expect(ids).to eq(model.results.map(&:id))
        end
      end

      describe "signed" do
        let(:query) { "{ signed }" }

        context "when the closure is signed" do
          let(:signed_at) { Time.current }

          it "returns true" do
            expect(response["signed"]).to be true
          end
        end

        context "when the closure is not signed" do
          it "returns false" do
            expect(response["signed"]).to be_falsey
          end
        end
      end
    end
  end
end
