# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages debates", type: :system do
  let(:manifest_name) { "debates" }

  include_context "when managing a component as a process admin"

  it_behaves_like "manage debates"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end
end
