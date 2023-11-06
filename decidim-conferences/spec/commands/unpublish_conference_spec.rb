# frozen_string_literal: true

require "spec_helper"

describe "Conference can be unpublished", type: :system do
  it_behaves_like "Unpublicable space", :conference
end
