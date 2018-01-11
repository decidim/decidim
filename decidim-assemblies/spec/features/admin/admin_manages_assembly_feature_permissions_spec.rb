# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly feature permissions", type: :feature do
  include_examples "Managing feature permissions" do
    let(:participatory_space_engine) { decidim_admin_assemblies }

    let!(:participatory_space) do
      create(:assembly, organization: organization)
    end
  end
end
