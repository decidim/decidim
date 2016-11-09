# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/manage_process_steps_examples"

describe "Participatory process admin manages participatory process steps", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
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
  let!(:process_user_role) { create :participatory_process_user_role, user: user, participatory_process: participatory_process }

  it_behaves_like "manage process steps examples"
end
