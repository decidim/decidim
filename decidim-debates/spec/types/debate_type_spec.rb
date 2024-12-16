# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/taxonomizable_interface_examples"
require "decidim/core/test/shared_examples/comments_examples"
require "decidim/core/test/shared_examples/authorable_interface_examples"

module Decidim
  module Debates
    describe DebateType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:debate, :open_ama) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"
      include_examples "authorable interface"

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

      describe "instructions" do
        let(:query) { '{ instructions { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["instructions"]["translation"]).to eq(model.instructions["en"])
        end
      end

      describe "informationUpdates" do
        let(:query) { '{ informationUpdates { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["informationUpdates"]["translation"]).to eq(model.information_updates["en"])
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the date when the debate starts" do
          expect(response["startTime"]).to eq(model.start_time.to_time.iso8601)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the date when the debate ends" do
          expect(response["endTime"]).to eq(model.end_time.to_time.iso8601)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the debate was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the debate was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns all the required fields" do
          expect(response).to include("reference" => model.reference.to_s)
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:current_component) { create(:debates_component, participatory_space:) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private but transparent" do
        let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
        let(:current_component) { create(:debates_component, participatory_space:) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:current_component) { create(:debates_component, participatory_space:) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:current_component) { create(:debates_component, :unpublished, organization: current_organization) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when debate is moderated" do
        let(:model) { create(:debate, :open_ama, :hidden) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end
    end
  end
end
