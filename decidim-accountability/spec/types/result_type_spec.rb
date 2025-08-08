# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Accountability
    describe ResultType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:result) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"
      include_examples "attachable interface"
      include_examples "attachable collection interface with attachment"
      include_examples "traceable interface"
      include_examples "timestamps interface"
      include_examples "commentable interface"
      include_examples "localizable interface"
      include_examples "referable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(Decidim::ResourceLocatorPresenter.new(model).url)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale:"en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale:"en")}}' }

        it "returns the description field" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "startDate" do
        let(:query) { "{ startDate }" }

        it "returns the startDate" do
          expect(response["startDate"]).to eq(model.start_date.to_date.iso8601)
        end
      end

      describe "endDate" do
        let(:query) { "{ endDate }" }

        it "returns the endDate" do
          expect(response["endDate"]).to eq(model.end_date.to_date.iso8601)
        end
      end

      describe "progress" do
        let(:query) { "{ progress }" }

        it "returns the progress field" do
          expect(response["progress"]).to eq(model.progress)
        end
      end

      describe "proposals" do
        let(:query) { "{ proposals { id } } " }

        let!(:proposal_component) { create(:proposal_component, participatory_space: model.participatory_space) }
        let(:proposals) { create_list(:proposal, 2, :published, component: proposal_component) }

        before do
          model.link_resources(proposals, "included_proposals")
        end

        it "returns the proposal urls" do
          expect(response["proposals"]).to eq(proposals.collect { |proposal| { "id" => proposal.id.to_s } })
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:current_component) { create(:accountability_component, participatory_space:) }
        let(:model) { create(:result, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private but transparent" do
        let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
        let(:current_component) { create(:accountability_component, participatory_space:) }
        let(:model) { create(:result, component: current_component) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:current_component) { create(:accountability_component, participatory_space:) }
        let(:model) { create(:result, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:current_component) { create(:accountability_component, :unpublished, organization: current_organization) }
        let(:model) { create(:result, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end
    end
  end
end
