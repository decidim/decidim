# frozen_string_literal: true

describe "Yarn sanity" do
  it "matches package.json with yarn.lock" do
    `yarn check --integrity`
    expect($?).to eq(0), "Yarn integrity check failed, please run `yarn install`"
  end
end
