# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Budgets
  describe CreateProjectType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetMutationType }
    let(:locale) { "en" }
    let!(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:budgets_component, participatory_space: participatory_process) }
    let(:proposals_component) { create(:component, manifest_name: :proposals, participatory_space: participatory_process) }
    let!(:budget) { create(:budget, component:) }
    let!(:project) { create(:project, component:) }
    let(:address) { Faker::Address.full_address }
    let!(:proposal) { create(:proposal, component: proposals_component) }
    let(:model) { budget }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:latitude) { Faker::Address.latitude }
    let(:longitude) { Faker::Address.longitude }
    let!(:root_taxonomy) { create(:taxonomy, organization:) }
    let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let(:taxonomy_id) { taxonomy.id }
    let(:budget_amount) { 123_4 }

    let(:variables) do
      {
        input: {
          id: project.id,
          attributes: {
            title: { en: title_en },
            description: { en: description_en },
            budgetAmount: budget_amount,
            latitude: latitude,
            longitude: longitude,
            proposalIds: [proposal.id],
            taxonomies: [taxonomy_id]
          }
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: UpdateProjectInput!) {
          updateProject(input: $input) {
            id
            title { translation(locale: "#{locale}") }
            description { translation(locale: "#{locale}") }
            address
            coordinates {
              latitude
              longitude
            }
            relatedProposals {
              id
            }
            taxonomies {
              id
              name { translation(locale: "#{locale}") }
            }
            budget_amount
          }
        }
      GRAPHQL
    end

    context "with an admin user" do
      it_behaves_like "API updatable project" do
        let!(:user_type) { :admin }
      end
    end

    context "with an api user" do
      it_behaves_like "API updatable project" do
        let!(:user_type) { :api_user }
      end
    end

    it "does not create project for unauthorized user" do
      expect(response["updateProoject"]).to be_nil
    end
  end
end
