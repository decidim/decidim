# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_component_access_examples"

describe "AdminAccess" do
  let(:manifest_name) { "pages" }
  let(:title) { "Edit page" }

  # This does not work for pages
  #
  # let!(:page) { create(:page, component:) }
  #
  # So, we need to do a workaround
  before do
    create(:page, component:)
  end

  include_context "when managing a component as an admin"
  include_examples "accessing the component in a participatory space"
end
