# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_component_access_examples"

describe "AdminAccess" do
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component:) }
  let!(:project) { create(:project, budget:) }
  let(:title) { "Budgets" }

  include_context "when managing a component as an admin"
  include_examples "accessing the component in a participatory space"
end
