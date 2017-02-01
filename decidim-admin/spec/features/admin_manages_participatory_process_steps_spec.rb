# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process steps", type: :feature do
  include_context "participatory process admin"
  it_behaves_like "manage process steps examples"
end
