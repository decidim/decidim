# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/taxonomizable_interface_examples"

module Decidim
  module Accountability
    describe ResultType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:result) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
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

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the reference field" do
          expect(response["reference"]).to eq(model.reference.to_s)
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

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns the createdAt" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns the updatedAt" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
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
