# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process categories", type: :system do
  include_context "when admin administrating a participatory process"

  let!(:category) do
    create(
      :category,
      participatory_space: participatory_process
    )
  end

  it_behaves_like "manage process categories examples"
end
