require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Accountability
  describe CreateResultType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { AccountabilityMutationType }
    let(:locale) { "en" }
    let!(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) do
      create(:component, manifest_name: "accountability", participatory_space: participatory_process)
    end
    let(:model) { component }
    let(:end_date) { "01.01.2025" }
    let(:external_id) { "dummy_external_id" }
    let(:progress) { 12.4 }
    let(:proposal_ids) { [] }
    let(:project_ids) { [] }
    let(:start_date) { "01.01.2020" }
    let(:taxonomies) { [] }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:weight) { 0 }
    let(:status_id) { nil }

    let(:variables) do
      {
        input: {
          attributes: {
            title: { en: title_en },
            description: { en: description_en },
            endDate: end_date,
            externalId: external_id,
            progress: progress,
            proposalIds: proposal_ids,
            projectIds: project_ids,
            startDate: start_date,
            taxonomies: taxonomies,
            weight: weight,
            decidimAccountabilityStatusId: status_id
          }
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: CreateResultInput!) {
          createResult(input: $input) {
            id
            title {
              translation(locale: "#{locale}")
            }
            description {
              translation(locale: "#{locale}")
            }
            endDate
            externalId
            progress
            proposals { id }
            projects { id }
            status { id }
            startDate
            taxonomies { id }
            weight
          }
        }
      GRAPHQL
    end

    let(:api_response) do
      response["createResult"]
    end

    context "with admin user" do
      it_behaves_like "API creatable result" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        result = response["createResult"]
        expect(result).to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "API creatable result" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
