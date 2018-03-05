# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin manages assembly component permissions", type: :system do
  include_examples "Managing component permissions" do
    let(:participatory_space_engine) { decidim_admin_assemblies }

    let(:user) do
      create(:assembly_admin, :confirmed, assembly: participatory_space)
    end

    let(:participatory_space) do
      create(:assembly, organization: organization)
    end
  end
end
