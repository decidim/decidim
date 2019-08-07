# frozen_string_literal: true

require "spec_helper"

describe "Admin manages media links", type: :system do
  include_context "when admin administrating a conference"

  it_behaves_like "manage media links examples"
end
