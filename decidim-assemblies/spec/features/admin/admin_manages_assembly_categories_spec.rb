# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly categories", type: :system do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage assembly categories"
end
