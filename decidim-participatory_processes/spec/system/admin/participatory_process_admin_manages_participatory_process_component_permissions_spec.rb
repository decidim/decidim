# frozen_string_literal: true

require "spec_helper"

describe "Participatory process admin manages participatory process component permissions", type: :system do
  include_examples "Managing component permissions" do
    let(:participatory_space_engine) { decidim_admin_participatory_processes }

    let(:participatory_space) do
      create(:participatory_process, organization: organization)
    end

    let(:user) do
      create(:process_admin, :confirmed, participatory_process: participatory_space)
    end
  end
end
