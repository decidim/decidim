# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_component_access_examples"

describe "AdminAccess" do
  let(:manifest_name) { "surveys" }
  let!(:survey) { create(:survey, :published, :clean_after_publish, component:) }
  let(:title) { "Surveys" }

  include_context "when managing a component as an admin"
  include_examples "accessing the component in a participatory space"
end
