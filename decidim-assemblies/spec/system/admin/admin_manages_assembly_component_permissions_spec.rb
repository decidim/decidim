# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly component permissions", type: :system do
  include_examples "Managing component permissions" do
    let(:participatory_space_engine) { decidim_admin_assemblies }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    let!(:participatory_space) do
      create(:assembly, organization:)
    end
  end
end
