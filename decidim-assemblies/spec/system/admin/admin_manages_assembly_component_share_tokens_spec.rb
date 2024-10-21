# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly component share tokens" do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage component share tokens" do
    let(:participatory_space) { assembly }
    let(:participatory_space_engine) { decidim_admin_assemblies }
  end
end
