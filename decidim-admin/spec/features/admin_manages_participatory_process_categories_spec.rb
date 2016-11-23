# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/manage_process_categories_examples"

describe "Admin manages participatory process categories", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end
  let!(:category) do
    create(
      :category,
      participatory_process: participatory_process
    )
  end

  it_behaves_like "manage process categories examples"
end
