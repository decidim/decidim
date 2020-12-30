# frozen_string_literal: true

RSpec.shared_context "when managing an accountability component" do
  let!(:result) { create :result, scope: scope, component: current_component }
  let!(:child_result) { create :result, scope: scope, component: current_component, parent: result }
  let!(:status) { create :status, key: "ongoing", name: { en: "Ongoing" }, component: current_component }
end

RSpec.shared_context "when managing an accountability component as a process admin" do
  include_context "when managing a component as a process admin"

  include_context "when managing an accountability component"
end

RSpec.shared_context "when managing an accountability component as an admin" do
  include_context "when managing a component as an admin"

  include_context "when managing an accountability component"
end

RSpec.shared_context "when managing results as an admin" do
  #let!(:category) { create(:category, participatory_space: component.participatory_space) }
  #let(:scope) { create :scope, organization: component.organization }

  # let!(:scopes) do
  #   create_list(
  #     :scope,
  #     results_count,
  #     organization: organization
  #   )
  # end

  #scopes.inspect

  let(:results_count) { 10 }
  let!(:results) do
    create_list(
      :result,
      results_count,
      component: component,
      #scope: new_scope
      #category: category
    )
  end

  #let!(:pending_user_groups) { create_list(:user_group, 4, users: [create(:user, organization: organization)]) }


  include_context "when managing a component as an admin"
end
