# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/taxonomizable_interface_examples"

module Decidim
  module Budgets
    describe ProjectType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:project) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"
      include_examples "attachable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale:"en")}}' }

        it "returns the title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale:"en")}}' }

        it "returns the description" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "budget_amount" do
        let(:query) { "{ budget_amount }" }

        it "returns the budget amount" do
          expect(response["budget_amount"]).to eq(model.budget_amount)
        end
      end

      describe "selected" do
        let(:query) { "{ selected }" }

        context "when the project is selected" do
          let(:model) { create(:project, :selected) }

          it "returns true" do
            expect(response["selected"]).to be true
          end
        end

        context "when the project is not selected" do
          it "returns false" do
            expect(response["selected"]).to be_falsey
          end
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the resource was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the resource was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the reference" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      context "when participatory space is private and transparent" do
        let(:participatory_space) { create(:assembly, :published, :transparent, :private) }
        let(:component) { create(:budgets_component, :published, participatory_space:) }
        let(:budget) { create(:budget, component:) }
        let(:model) { create(:project, budget:) }

        let(:query) { "{ id }" }

        it "returns the object" do
          expect(response).to eq({ "id" => model.id.to_s })
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:component) { create(:budgets_component, participatory_space:) }
        let(:budget) { create(:budget, component:) }
        let(:model) { create(:project, budget:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:component) { create(:budgets_component, participatory_space:) }
        let(:budget) { create(:budget, component:) }
        let(:model) { create(:project, budget:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:component) { create(:budgets_component, :unpublished, organization: current_organization) }
        let(:model) { create(:project, component:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when budget is not visible" do
        let(:component) { create(:budgets_component, organization: current_organization) }
        let(:budget) { create(:budget, component:) }
        let(:model) { create(:project, budget:) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns all the required fields" do
          allow(model).to receive(:visible?).and_return(false)
          expect(response).to be_nil
        end
      end
    end
  end
end
