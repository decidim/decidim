# frozen_string_literal: true

RSpec.shared_context "admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization, email: "admin@example.org") }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:process_admin) { create :user, :confirmed, organization: organization }
  let!(:user_role) { create :participatory_process_user_role, user: process_admin, participatory_process: participatory_process }
  let(:current_feature) { create :feature, participatory_process: participatory_process, manifest_name: "budgets" }
  let(:scope) { create :scope, organization: organization }
  let!(:category) { create :category, participatory_process: participatory_process }
  let!(:project) { create :project, scope: scope, feature: current_feature }
end
