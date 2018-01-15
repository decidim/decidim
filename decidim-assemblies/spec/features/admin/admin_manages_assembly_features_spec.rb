# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly features", type: :feature do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage assembly features"
end
