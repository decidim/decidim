# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Elections
    describe ElectionResultType, type: :graphql do
      include_context "with a graphql class type"

      let(:polling_station) { create(:polling_station) }
      let(:model) { create(:election_result) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "votes_count" do
        let(:query) { "{ votesCount }" }

        it "returns the votes for this answer" do
          expect(response["votesCount"]).to eq(model.votes_count)
        end
      end
    end
  end
end
