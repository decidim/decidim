# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Accountability
  describe UpdateMilestoneType, type: :graphql do
    include_context "with a graphql class mutation"
    include_context "when managing milestone through API"

    let(:root_klass) { ResultMutationType }
    let!(:result) { create(:result, component:) }
    let(:model) { result }
    let(:milestone) { create(:milestone, result:) }
    let(:entry_date) { "01.01.2025" }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }

    let(:variables) do
      {
        input: {
          id: milestone.id,
          attributes: attributes
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: UpdateMilestoneInput!) {
          updateMilestone(input: $input) {
            id
            title {
              translation(locale: "#{locale}")
            }
            description {
              translation(locale: "#{locale}")
            }
            entryDate
            result { id }
          }
        }
      GRAPHQL
    end

    let(:api_response) do
      response["updateMilestone"]
    end
    let!(:expected_trace_method) { :update! }
    let(:target) { milestone }

    context "with admin user" do
      let!(:user_type) { :admin }

      include_examples "create/update milestone shared examples"
    end

    context "with api user" do
      let!(:user_type) { :api_user }

      include_examples "create/update milestone shared examples"
    end

    context "with normal user" do
      it "returns nil" do
        expect(api_response).to be_nil
      end
    end
  end
end
