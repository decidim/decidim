# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages surveys", type: :feature do
  include_context "admin"
  let(:user) { process_admin }
  it_behaves_like "edit surveys"
  it_behaves_like "export survey user answers"
  include_context "feature admin"
  let(:manifest_name) { "surveys" }
end
