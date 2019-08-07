# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference component permissions", type: :system do
  include_examples "Managing component permissions" do
    let(:participatory_space_engine) { decidim_admin_conferences }
    let(:user) { create(:user, :admin, :confirmed, organization: organization) }

    let!(:participatory_space) do
      create(:conference, organization: organization)
    end
  end
end
