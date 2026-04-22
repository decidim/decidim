# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe CreateResultType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { AccountabilityMutationType }
    let(:resource_class) { Decidim::Accountability::Result }
    let(:locale) { "en" }
    let(:model) { create(:accountability_component, participatory_space: participatory_process) }
    let(:current_component) { model }
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
    let!(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }

    let(:variables) do
      {
        input: {
          attributes:
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

    shared_examples "API creatable result" do
      it "creates a new result" do
        expect do
          execute_query(query, variables)
        end.to change(resource_class, :count).by(1)
      end

      include_examples "trace result action" do
        let(:expected_trace_method) { :create! }
        let(:target) { resource_class }
      end

      include_examples "handle linking resources" do
        let(:api_response) { response["createResult"] }
      end

      it "assigns fields" do
        result = response["createResult"]
        expect(result).to include(
          {
            "description" => { "translation" => description_en },
            "title" => { "translation" => title_en },
            "proposals" => [{ "id" => kind_of(String) }],
            "projects" => [{ "id" => kind_of(String) }],
            "externalId" => "dummy_external_id",
            "progress" => 12.4,
            "startDate" => "2020-01-01",
            "taxonomies" => [],
            "status" => nil,
            "weight" => 0
          }
        )
        expect(result["id"]).to be_present
      end

      context "when having invalid arguments" do
        context "when having invalid locale" do
          let(:variables) do
            {
              component_id: current_component.id,
              input: {
                attributes: {
                  title: { en: title_en, tlh: "Foo bar" },
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
              }
            }
          end

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::InvalidLocaleError, /Invalid locale provided/)
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

        context "when submitting progress as string" do
          let(:progress) { "foo" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value "foo" to Float/)
          end
        end

        context "when submitting taxonomy as string" do
          let(:taxonomy_id) { "foo" }

          it "raises an error" do
            expect(response["createResult"]["taxonomies"]).to be_empty
            expect(response["createResult"]["taxonomies"]).to eq([])
          end
        end

        context "when submitting taxonomy result" do
          let(:taxonomy_id) { 0 }

          it "raises an error" do
            expect(response["createResult"]["taxonomies"]).to be_empty
            expect(response["createResult"]["taxonomies"]).to eq([])
          end
        end

        context "when submitting invalid title for result" do
          let(:title_en) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
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
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end
      end
    end

    context "with admin user" do
      it_behaves_like "API creatable result" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
      end
    end

    context "with api_user" do
      it_behaves_like "API creatable result" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
