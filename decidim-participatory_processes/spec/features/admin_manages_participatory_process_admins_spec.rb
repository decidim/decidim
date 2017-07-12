# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process admins", type: :feature do
  include_context "participatory process administration by admin"

  it_behaves_like "manage process admins examples"
end
