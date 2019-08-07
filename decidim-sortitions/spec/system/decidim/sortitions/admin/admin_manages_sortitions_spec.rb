# frozen_string_literal: true

require "spec_helper"

describe "Admin manages sortitions", type: :system do
  let(:manifest_name) { "sortitions" }

  include_context "when managing a component as an admin"

  it_behaves_like "manage sortitions"
  it_behaves_like "cancel sortitions"
  it_behaves_like "update sortitions"
end
