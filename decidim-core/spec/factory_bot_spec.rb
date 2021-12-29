# frozen_string_literal: true

require "spec_helper"

describe FactoryBot do
  it "has 100% valid factories" do
    expect { described_class.lint(traits: true) }.not_to raise_error
  end
end
