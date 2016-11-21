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
