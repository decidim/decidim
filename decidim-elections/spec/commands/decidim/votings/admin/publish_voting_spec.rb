# frozen_string_literal: true

require "spec_helper"

describe "Voting can be published", type: :system do
  it_behaves_like "Publicable space", :voting
end
