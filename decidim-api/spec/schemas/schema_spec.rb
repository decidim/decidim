# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Api
    describe Schema do
      let!(:current_user) { create(:user) }
      let!(:current_organization) { current_user.organization }

      def execute_query(query, variables = {})
        described_class.execute(
          query,
          context: {
            current_organization: current_organization,
            current_user: current_user
          },
          variables: variables
        )
      end

      describe "processes" do
        let!(:process1) { create(:participatory_process, organization: current_organization) }
        let!(:process2) { create(:participatory_process, organization: current_organization) }
        let!(:process3) { create(:participatory_process) }

        let(:query) { %({ processes { id } }) }

        it "returns all the processes" do
          result = execute_query(query)

          expect(result["data"]["processes"]).to     include("id" => process1.id.to_s)
          expect(result["data"]["processes"]).to     include("id" => process2.id.to_s)
          expect(result["data"]["processes"]).to_not include("id" => process3.id.to_s)
        end
      end
    end
  end
end
