# frozen_string_literal: true

RSpec.shared_context "when managing an accountability component" do
  let!(:result) { create :result, scope:, component: current_component }
  let!(:child_result) { create :result, scope:, component: current_component, parent: result }
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
