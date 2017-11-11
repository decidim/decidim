# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  describe ProcessType, type: :graphql do
    include_context "with a graphql type"

    let(:model) { create(:participatory_process) }

    describe "id" do
      let(:query) { "{ id }" }

      it "returns all the required fields" do
        expect(response).to include("id" => model.id.to_s)
      end
    end

    describe "title" do
      let(:query) { '{ title { translation(locale: "en")}}' }

      it "returns all the required fields" do
        expect(response["title"]["translation"]).to eq(model.title["en"])
      end
    end

    describe "steps" do
      let!(:step) { create(:participatory_process_step, participatory_process: model) }

      let(:query) { "{ steps { edges { node { id } } } }" }

      it "returns all the required fields" do
        step_response = response["steps"]["edges"].first["node"]
        expect(step_response["id"]).to eq(step.id.to_s)
      end
    end
  end
end
