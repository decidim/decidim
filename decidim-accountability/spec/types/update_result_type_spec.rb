# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Accountability
  describe UpdateResultType, type: :graphql do
    include_context "with a graphql class mutation"
    include_context "when managing result through API"

    let(:root_klass) { AccountabilityMutationType }
    let(:model) { component }
    let(:api_response) do
      response["updateResult"]
    end
    let(:result) { create(:result, component:) }
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
          id: result.id,
          attributes: attributes
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: UpdateResultInput!) {
          updateResult(input: $input) {
            id
            title {
              translation(locale: "#{locale}")
            }
            description {
              translation(locale: "#{locale}")
            }
            id
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

    let!(:expected_trace_method) { :update! }
    let(:target) { result }

    context "with admin user" do
      let!(:user_type) { :admin }

      include_examples "create/update result shared examples"
    end

    context "with api user" do
      let!(:user_type) { :api_user }

      include_examples "create/update result shared examples"
    end

    context "with normal user" do
      it "returns nil" do
        expect(api_response).to be_nil
      end
    end
  end
end
