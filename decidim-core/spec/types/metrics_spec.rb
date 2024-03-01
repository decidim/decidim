# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:query) do
    %(
      query {
        metrics {
          count
          name
          history {
            key
            value
          }
        }
      }
    )
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    %w(
      users
      participants
      followers
      comments
      participatory_processes
      assemblies
      meetings
      proposals
      accepted_proposals
      votes
      endorsements
      survey_answers
      results
      debates
    ).each do |stat|
      it {
        expect(response["metrics"].select { |hash| hash["name"] == stat }.first).to eq({ "count" => 0, "history" => [], "name" => stat })
      }
    end
  end
end
