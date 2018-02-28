# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin manages assembly feature permissions", type: :system do
  include_examples "Managing feature permissions" do
    let(:participatory_space_engine) { decidim_admin_assemblies }

    let(:user) do
      create(:assembly_admin, :confirmed, assembly: participatory_space)
    end

    let(:participatory_space) do
      create(:assembly, organization: organization)
    end
  end
end
