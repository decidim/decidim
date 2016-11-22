# frozen_string_literal: true
RSpec.shared_context "component" do
  let!(:component) do
    create(:component, component_type: :pages, participatory_process: participatory_process)
  end

  let(:participatory_process) do
    create(:participatory_process, organization: organization)
  end

  let!(:organization) { create(:organization) }

  before do

    switch_to_host(organization.host)
  end

  def visit_component
    visit decidim.component_path(participatory_process, component)
  end
end

RSpec.shared_context "component admin" do
  include_context "component"
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    Decidim::Admin::ParticipatoryProcessUserRole.create!(
      role: :admin,
      user: user,
      participatory_process: participatory_process
    )

    login_as user, scope: :user
  end

  def visit_component_admin
    visit decidim_admin.manage_component_path(participatory_process, component)
  end
end
