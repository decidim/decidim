# frozen_string_literal: true

require "spec_helper"

describe "Admin manages registration types" do
  include_context "when admin administrating a conference"

  it_behaves_like "manage registration types examples"
end
