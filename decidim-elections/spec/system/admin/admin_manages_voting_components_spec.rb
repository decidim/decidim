# frozen_string_literal: true

require "spec_helper"

describe "Admin manages voting components", type: :system do
  include_context "when admin administrating a voting"

  it_behaves_like "manage voting components"
end
