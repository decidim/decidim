# frozen_string_literal: true
require "spec_helper"

describe "Organization", :db do
  let(:organization) { create(:organization) }

  it "is valid" do
    expect(organization).to be_valid
  end
end
