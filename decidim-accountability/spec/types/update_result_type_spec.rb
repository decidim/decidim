# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe UpdateResultType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:locale) { "en" }
    let(:current_component) { create(:accountability_component, organization: current_organization) }
    let(:component) { current_component }

    let(:type_class) { Decidim::Accountability::UpdateResultType }
    let(:root_klass) { ResultMutationType }
    let(:root_value) { model }

    let(:model) { create(:result, component:) }
    let(:end_date) { "2025-01-01" }
    let(:external_id) { "dummy_external_id" }
    let(:progress) { 12.4 }
    let(:proposal_ids) { [] }
    let(:project_ids) { [] }
    let(:start_date) { "2020-01-01" }
    let(:taxonomies) { [] }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:weight) { 0 }
    let(:status_id) { nil }

    let(:attributes) do
      {
        title: { en: title_en },
        description: { en: description_en },
        endDate: end_date,
        externalId: external_id,
        progress:,
        proposalIds: proposal_ids,
        projectIds: project_ids,
        startDate: start_date,
        taxonomies:,
        weight:,
        decidimAccountabilityStatusId: status_id
      }
    end

    let(:variables) do
      {
        component_id: current_component.id,
        result_id: model.id,
        input: {
          attributes:
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

    shared_examples "API updatable result" do
      context "when updating a result" do
        it "updates fields" do
          updated_result = response["updateResult"]
          expect(updated_result["id"].to_i).to eq(model.id)
          expect(updated_result["title"]["translation"]).to eq(title_en)
          expect(updated_result["description"]["translation"]).to eq(description_en)
          expect(updated_result["endDate"]).to eq(end_date)
          expect(updated_result["externalId"]).to eq(external_id)
          expect(updated_result["progress"]).to eq(progress)
          expect(updated_result["proposals"].map { |p| p["id"] }).to eq(proposal_ids)
        end
      end

      context "when having invalid arguments" do
        context "when having invalid locale" do
          let(:variables) do
            {
              component_id: current_component.id,
              result_id: model.id,
              input: {
                attributes: {
                  title: { "en" => title_en, "tlh" => "Foo bar" },
                  description: { en: description_en }
                }
              }
            }
          end

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::InvalidLocaleError, /Invalid locale provided/)
          end
        end

        context "when submitting invalid title for result" do
          let(:title_en) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "when endDate is in invalid format (e.g., 'abcd-01-01')" do
          let(:end_date) { "abcd-01-01" }

          it "returns an error" do
            expect(response["updateResult"]).to be_present
            expect(response["updateResult"]["endDate"]).to be_nil
          end
        end

        context "when submitting invalid status_id numericality for result" do
          let(:status_id) { "" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value "" to Int/)
          end
        end

        context "when submitting invalid progress numericality for result" do
          let(:progress) { "" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value "" to Float/)
          end
        end

        context "when submitting invalid progress numericality as string for result" do
          let(:progress) { "foo" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value "foo" to Float/)
          end
        end

        context "when submitting null title for result" do
          let(:attributes) do
            {
              title: nil,
              description: { en: description_en },
              endDate: end_date,
              externalId: external_id,
              progress:,
              proposalIds: proposal_ids,
              projectIds: project_ids,
              startDate: start_date,
              taxonomies:,
              weight:,
              decidimAccountabilityStatusId: status_id
            }
          end

          it "raises an error" do
            expect(response["updateResult"]).to be_present
            expect(response["updateResult"]["title"]).to be_present
            expect(response["updateResult"]["title"]["translation"]).to eq(translated(model.title))
          end
        end
      end
    end

    it_behaves_like "admin API access checks", "API updatable result"
  end
end
