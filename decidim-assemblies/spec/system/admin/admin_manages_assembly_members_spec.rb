# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly members", type: :system do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage assembly members examples"
end
