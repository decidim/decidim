# frozen_string_literal: true

require "spec_helper"

describe "Process moderator manages process moderations", type: :system do
  let!(:user) do
    create(
      :process_moderator,
      :confirmed,
      organization:,
      participatory_process:
    )
  end
  let(:current_component) { create :component, participatory_space: participatory_process }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.moderations_path(participatory_process)
  end

  include_context "when administrating a participatory process"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it_behaves_like "manage moderations"

  it_behaves_like "sorted moderations" do
    let!(:reportables) { create_list(:dummy_resource, 17, component: current_component) }
  end
end
