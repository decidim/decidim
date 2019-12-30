# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference categories", type: :system do
  include_context "when admin administrating a conference"

  let!(:category) do
    create(
      :category,
      participatory_space: conference
    )
  end

  it_behaves_like "manage conference categories"
end
