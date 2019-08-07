# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process steps", type: :system do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage process steps examples"
end
