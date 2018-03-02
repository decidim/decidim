# frozen_string_literal: true

RSpec.shared_context "when managing an accountability feature" do
  let!(:result) { create :result, scope: scope, feature: current_feature }
  let!(:child_result) { create :result, scope: scope, feature: current_feature, parent: result }
  let!(:status) { create :status, key: "ongoing", name: { en: "Ongoing" }, feature: current_feature }
end

RSpec.shared_context "when managing an accountability feature as a process admin" do
  include_context "when managing a feature as a process admin"

  include_context "when managing an accountability feature"
end

RSpec.shared_context "when managing an accountability feature as an admin" do
  include_context "when managing a feature as an admin"

  include_context "when managing an accountability feature"
end
