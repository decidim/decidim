# frozen_string_literal: true

require "spec_helper"

describe "Admin manages voting attachment collections" do
  include_context "when admin managing a voting"

  it_behaves_like "manage voting attachment collections examples"
end
