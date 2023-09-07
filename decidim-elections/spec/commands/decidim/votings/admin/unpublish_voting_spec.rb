# frozen_string_literal: true

require "spec_helper"

describe "Any Voting can be unpublished", type: :system do
  it_behaves_like "Unpublicable space", :voting
end
