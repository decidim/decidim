# frozen_string_literal: true

require "spec_helper"

describe "Participatory process admin manages participatory process categories", type: :feature do
  include_context "participatory process administration by process admin"

  let!(:category) do
    create(
      :category,
      participatory_process: participatory_process
    )
  end

  it_behaves_like "manage process categories examples"
end
