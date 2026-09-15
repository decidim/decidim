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
    let!(:root_taxonomy) { create(:taxonomy, organization: current_organization) }
    let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: current_organization) }
    let(:taxonomy_id) { taxonomy.id }
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
        taxonomies: [taxonomy_id],
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

    shared_context "with linking resources" do
      let(:other_process) { create(:participatory_process, organization:) }
      let(:foreign_proposals_component) { create(:component, manifest_name: :proposals, participatory_space: other_process) }
      let(:foreign_budgets_component) { create(:component, manifest_name: :budgets, participatory_space: other_process) }
      let!(:foreign_project) { create(:project, component: foreign_budgets_component) }
      let!(:foreign_proposal) { create(:proposal, component: foreign_proposals_component) }
      let!(:budgets_component) { create(:component, manifest_name: :budgets, participatory_space: participatory_process) }
      let!(:proposals_component) { create(:component, manifest_name: :proposals, participatory_space: participatory_process) }
      let!(:proposal) { create(:proposal, component: proposals_component) }
      let!(:project) { create(:project, component: budgets_component) }
    end

    shared_examples "handle linking resources" do
      include_context "with linking resources"
      let!(:proposal_ids) { [1234, foreign_proposal.id, proposal.id] }
      let!(:project_ids) { [1235, foreign_project.id, project.id] }

      it "links only belonging resources" do
        expect(api_response).to include(
          {
            "proposals" => [
              { "id" => proposal.id.to_s }
            ],
            "projects" => [
              { "id" => project.id.to_s }
            ]
          }
        )
        result = Decidim::Accountability::Result.last
        linked_proposals = result.linked_resources(:proposals, "included_proposals")
        linked_projects = result.linked_resources(:projects, "included_projects")

        expect(linked_proposals).to eq([proposal])
        expect(linked_projects).to eq([project])
      end
    end

    shared_examples "trace result action" do
      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(expected_trace_method)
          .with(target, current_user, kind_of(Hash), { visibility: "all" })
          .and_call_original

        expect { execute_query(query, variables) }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
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
            "taxonomies" => [{ "id" => taxonomy.id.to_s }],
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

        context "when submitting missing required attributes" do
          let(:attributes) { {} }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "when submitting invalid status_id numericality for result" do
          let(:status_id) { "" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value "" to Int/)
          end
        end

        context "when submitting null description for result" do
          let(:attributes) { { description: nil } }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "when submitting null progress for result" do
          let(:progress) { nil }

          it "passes" do
            expect(response["createResult"]["progress"]).to be_nil
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
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value/)
          end
        end

        context "when submitting invalid date format for start_date" do
          let(:start_date) { "2025-13-01" }

          it "passes" do
            expect(response["createResult"]["startDate"]).to be_nil
          end
        end

        context "when submitting invalid date format for end_date" do
          let(:end_date) { "2025-13-01" }

          it "raises an error" do
            expect(response["createResult"]["endDate"]).to be_nil
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

    it_behaves_like "admin API access checks", "API creatable result"
  end
end
