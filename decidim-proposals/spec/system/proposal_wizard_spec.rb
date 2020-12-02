# frozen_string_literal: true

require "spec_helper"

describe "Proposal", type: :system do
  it_behaves_like "proposals wizards", with_address: false
  it_behaves_like "proposals wizards", with_address: true
end
