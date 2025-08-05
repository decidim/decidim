# frozen_string_literal: true

RSpec.shared_context "when managing an accountability component" do
  let!(:result) { create(:result, scope:, component: current_component) }
  let!(:other_result) { create(:result, scope:, component: current_component) }
  let!(:child_result) { create(:result, scope:, component: current_component, parent: result) }
  let!(:status) { create(:status, key: "ongoing", name: { en: "Ongoing" }, component: current_component) }
end

RSpec.shared_context "when managing an accountability component as a process admin" do
  include_context "when managing a component as a process admin"

  include_context "when managing an accountability component"
end

RSpec.shared_context "when managing an accountability component as an admin" do
  include_context "when managing a component as an admin"

  include_context "when managing an accountability component"
end

RSpec.shared_context "with taxonomies, attached_resources, and status" do
  include_context "with linking resources"

  let!(:initial_status) { create(:status, component: component, key: "started", name: { en: "Started" }) }
  let!(:finished_status) { create(:status, component: component, key: "finished", name: { en: "Finished" }) }
end

RSpec.shared_context "with linking resources" do
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

RSpec.shared_context "with taxonomies" do
  let!(:foreign_organization) { create(:organization) }
  let!(:valid_root) { create(:taxonomy, organization:) }
  let!(:invalid_root) { create(:taxonomy, organization: foreign_organization) }
  let!(:invalid_taxonomies) { create_list(:taxonomy, 2, parent: invalid_root, organization: foreign_organization) }
  let!(:valid_taxonomies) { create_list(:taxonomy, 2, parent: valid_root, organization:) }
end

RSpec.shared_context "when managing result through API" do
  let(:attributes) do
    {
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
  end
  let(:locale) { "en" }
  let!(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) do
    create(:component, manifest_name: "accountability", participatory_space: participatory_process)
  end
end

RSpec.shared_context "when managing milestone through API" do
  let(:attributes) do
    {
      title: { en: title_en },
      description: { en: description_en },
      entryDate: entry_date
    }
  end
  let(:locale) { "en" }
  let!(:organization) { create(:organization) }
  let(:component) { create(:component, manifest_name: "accountability") }
end
