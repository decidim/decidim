# frozen_string_literal: true

require "spec_helper"

describe "Admin copies assembly" do
  include_context "when admin administrating an assembly"

  it_behaves_like "copy assemblies"
end
