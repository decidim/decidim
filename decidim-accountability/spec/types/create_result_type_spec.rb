# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Accountability
  describe CreateResultType, type: :graphql do
    include_context "with a graphql class mutation"
    include_context "when managing result through API"

    let(:root_klass) { AccountabilityMutationType }
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
          attributes: attributes
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
    let!(:expected_trace_method) { :create! }
    let(:target) { Decidim::Accountability::Result }

    context "with admin user" do
      let!(:user_type) { :admin }

      it_behaves_like "create new result"
      include_examples "create/update result shared examples", visible_to_all: true
    end

    context "with api user" do
      let!(:user_type) { :api_user }

      it_behaves_like "create new result"
      include_examples "create/update result shared examples", visible_to_all: true
    end

    context "with normal user" do
      it "returns nil" do
        result = response["createResult"]
        expect(result).to be_nil
      end
    end
  end
end
