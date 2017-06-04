# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings", type: :feature do
  include_context "admin"
  it_behaves_like "manage meetings"
end
