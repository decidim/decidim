# frozen_string_literal: true

require "spec_helper"

describe "Bundle sanity" do
  it "is up to date" do
    previous_hash = bundle_hash

    Dir.chdir("../") do
      `npm run build:prod 2>&1 /dev/null`
    end

    new_hash = bundle_hash

    expect(previous_hash).to eq(new_hash),
                             "Please normalize the comments bundle file with `npm run build:prod` from the Decidim root folder"
  end

  def bundle_hash
    Digest::MD5.file("app/assets/javascripts/decidim/comments/bundle.js").hexdigest
  end
end
