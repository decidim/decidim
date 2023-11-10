# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly components" do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage assembly components"
end
