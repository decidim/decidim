# frozen_string_literal: true

require "spec_helper"

describe "Admin copies conference", type: :system do
  include_context "when admin administrating a conference"

  it_behaves_like "copy conferences"
end
