# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_component_permissions_examples"

describe "Admin manages consultation component permissions", type: :system do
  include_examples "Managing component permissions" do
    let(:participatory_space_engine) { decidim_admin_consultations }
    let(:consultation) { create(:consultation, organization:) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    let!(:participatory_space) do
      create(:question, consultation:)
    end
  end
end
