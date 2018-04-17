# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages sortitions", type: :system do
  let(:manifest_name) { "sortitions" }
  let(:user) { process_admin }

  include_context "when managing a component as a process admin"

  it_behaves_like "manage sortitions"
  it_behaves_like "cancel sortitions"
  it_behaves_like "update sortitions"
end
