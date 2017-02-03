# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Api
    describe QueryType do
      include_context "graphql type"

      describe "processes" do
        let!(:process1) { create(:participatory_process, organization: current_organization) }
        let!(:process2) { create(:participatory_process, organization: current_organization) }
        let!(:process3) { create(:participatory_process) }

        let(:query) { %({ processes { id }}) }

        it "returns all the processes" do
          expect(response["processes"]).to     include("id" => process1.id.to_s)
          expect(response["processes"]).to     include("id" => process2.id.to_s)
          expect(response["processes"]).not_to include("id" => process3.id.to_s)
        end
      end
    end
  end
end
