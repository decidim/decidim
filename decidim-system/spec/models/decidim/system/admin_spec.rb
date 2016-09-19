# frozen_string_literal: true
require "spec_helper"

describe "Admin", :db do
  let(:admin) { create(:admin) }

  it "is valid" do
    expect(admin).to be_valid
  end
end
