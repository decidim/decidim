# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin manages assembly categories", type: :system do
  include_context "when assembly admin administrating an assembly"

  it_behaves_like "manage assembly categories"
end
