# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly categories", type: :system do
  include_context "when admin administrating an assembly"

  let!(:category) do
    create(
      :category,
      participatory_space: assembly
    )
  end

  it_behaves_like "manage assembly categories"
end
