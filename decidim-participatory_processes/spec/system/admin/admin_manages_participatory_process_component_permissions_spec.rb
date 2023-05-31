# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process component permissions", type: :system do
  include_examples "Managing component permissions" do
    let(:participatory_space_engine) { decidim_admin_participatory_processes }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    let!(:participatory_space) do
      create(:participatory_process, organization:)
    end
  end
end
