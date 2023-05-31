# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Elections
    describe ElectionAnswerType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:election_answer) }

      it_behaves_like "attachable interface"

      it_behaves_like "traceable interface" do
        let(:author) { create(:user, :admin, organization: model.component.organization) }
      end

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

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the answers weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "results_total" do
        let(:query) { "{ results_total }" }

        it "returns the votes for this answer" do
          expect(response["results_total"]).to eq(model.results_total)
        end
      end

      describe "selected" do
        let(:query) { "{ selected }" }

        it "returns if answer is selected" do
          expect(response["selected"]).to eq(model.selected)
        end
      end

      describe "proposals" do
        let(:component) { create(:proposal_component, organization: model.question.election.component.organization) }
        let!(:proposals) { create_list(:proposal, 2, component:) }
        let(:query) { "{ proposals { id } }" }

        it "returns the answer related proposals" do
          ids = response["proposals"].map { |proposal| proposal["id"] }
          expect(ids).to include(*model.proposals.map(&:id).map(&:to_s))
          expect(ids).not_to include(*proposals.map(&:id).map(&:to_s))
        end
      end
    end
  end
end
