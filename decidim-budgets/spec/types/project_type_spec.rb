# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Budgets
    describe ProjectType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:project) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"
      include_examples "attachable interface"
      include_examples "attachable collection interface with attachment"
      include_examples "traceable interface"
      include_examples "timestamps interface"
      include_examples "commentable interface"
      include_examples "localizable interface"
      include_examples "referable interface"
      include_examples "followable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(model.resource_locator.url)
        end
      end

      describe "selected_at" do
        let(:model) { create(:project, :selected) }

        let(:query) { "{ selectedAt }" }

        it "returns all the required fields" do
          expect(response["selectedAt"]).to eq(model.selected_at.to_time.iso8601)
        end
      end

      describe "proposals" do
        let(:query) { "{ relatedProposals { id } }" }
        let!(:proposal_component) { create(:proposal_component, :published, participatory_space: model.participatory_space) }
        let(:proposals) { create_list(:proposal, 2, :published, component: proposal_component) }

        before do
          model.link_resources(proposals, "included_proposals")
        end

        it "returns the proposal urls" do
          expect(response["relatedProposals"].length).to eq(2)
          expect(response["relatedProposals"]).to eq(proposals.collect { |proposal| { "id" => proposal.id.to_s } })
        end
      end

      describe "confirmed_votes" do
        let(:query) { "{ confirmedVotes }" }

        let(:budget) { create(:budget, component:) }
        let(:model) { create(:project, budget:) }

        context "when show_votes is false" do
          let(:component) { create(:budgets_component) }

          it "does not return all the required fields" do
            expect(response["confirmedVotes"]).to be_nil
          end
        end

        context "when show_votes is true" do
          let(:component) { create(:budgets_component, :with_show_votes_enabled) }

          it "returns all the required fields" do
            expect(response["confirmedVotes"]).to eq(model.confirmed_orders_count)
          end
        end
      end

      describe "budget_url" do
        let(:query) { "{ budgetUrl }" }

        it "returns all the required fields" do
          expect(response["budgetUrl"]).to eq(Decidim::EngineRouter.main_proxy(model.component).budget_url(model.budget))
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
