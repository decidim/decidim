# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/manage_process_steps_examples"

describe "Admin manages participatory process steps", type: :feature do
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
  let(:active) { false }
  let!(:process_step) do
    create(
      :participatory_process_step,
      participatory_process: participatory_process,
      active: active,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  it_behaves_like "manage process steps examples"
end
