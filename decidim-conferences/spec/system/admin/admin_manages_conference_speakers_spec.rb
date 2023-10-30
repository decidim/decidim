# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference speakers" do
  include_context "when admin administrating a conference"

  it_behaves_like "manage conference speakers examples"
end
