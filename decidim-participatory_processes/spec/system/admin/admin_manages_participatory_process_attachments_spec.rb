# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process attachments", type: :system do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage process attachments examples"
end
