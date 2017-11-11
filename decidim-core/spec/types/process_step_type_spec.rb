# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  describe ProcessStepType do
    include_context "with a graphql type"

    let(:process) do
      create(:participatory_process, organization: current_organization)
    end

    let(:model) do
      create(:participatory_process_step, participatory_process: process)
    end

    describe "id" do
      let(:query) { "{ id }" }

      it "returns all the required fields" do
        expect(response).to include("id" => model.id.to_s)
      end
    end

    describe "process" do
      let(:query) { "{ process { id } }" }

      it "queries the original process" do
        expect(response).to include("process" => { "id" => process.id.to_s })
      end
    end

    describe "title" do
      let(:query) { "{ title { locales } }" }

      it "returns its title" do
        expect(response["title"]["locales"]).to include(*process.title.keys)
      end
    end
  end
end
