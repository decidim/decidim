# frozen_string_literal: true

require "spec_helper"

describe "Decidim.version" do
  it "has a version number" do
    expect(Decidim.version).not_to be nil
  end
end
