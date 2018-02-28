# frozen_string_literal: true

RSpec.shared_context "when admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization, email: "admin@example.org") }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
  let(:scope) { create :scope, organization: organization }
  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:result) { create :result, scope: scope, feature: current_feature }
  let!(:child_result) { create :result, scope: scope, feature: current_feature, parent: result }
  let!(:status) { create :status, key: "ongoing", name: { en: "Ongoing" }, feature: current_feature }
end
