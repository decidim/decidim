# frozen_string_literal: true

require "spec_helper"

describe "Admin manages surveys", type: :feature do
  let(:manifest_name) { "surveys" }

  include_context "feature admin"
  include_context "admin"

  it_behaves_like "edit surveys"
  it_behaves_like "export survey user answers"
end
