# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql type"

      describe "allParticipatoryProcesses" do
        let!(:process1) { create(:participatory_process, organization: current_organization) }
        let!(:process2) { create(:participatory_process, organization: current_organization) }
        let!(:process3) { create(:participatory_process) }

        let(:query) { %({ allParticipatoryProcesses { id }}) }

        it "returns all the processes" do
          expect(response["allParticipatoryProcesses"]).to include("id" => process1.id.to_s)
          expect(response["allParticipatoryProcesses"]).to include("id" => process2.id.to_s)
          expect(response["allParticipatoryProcesses"]).not_to include("id" => process3.id.to_s)
        end
      end

      describe "decidim" do
        let(:query) { %({ decidim { version }}) }

        it "returns the right version" do
          expect(response["decidim"]).to include("version" => Decidim.version)
        end
      end
    end
  end
end
