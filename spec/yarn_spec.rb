# frozen_string_literal: true

require "English"

describe "Yarn sanity" do
  it "matches package.json with yarn.lock" do
    `yarn check --integrity`
    expect($CHILD_STATUS).to eq(0), "Yarn integrity check failed, please run `yarn install`"
  end
end
