# frozen_string_literal: true

require "spec_helper"

describe "provides valid scope helpers" do
  let(:participatory_space) do
    create(
      :assembly,
      organization: organization,
      scopes_enabled: scopes_enabled,
      scope: participatory_space_scope
    )
  end

  include_examples "scope helpers"
end
