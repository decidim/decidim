# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process categories", type: :system do
  include_context "when administrating a consultation"

  let!(:category) do
    create(
      :category,
      participatory_space: question
    )
  end

  it_behaves_like "manage question categories examples"
end
