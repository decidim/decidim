# frozen_string_literal: true

require "spec_helper"

describe "Bundle sanity" do
  let(:command) { "npm run build:prod" }

  it "is up to date" do
    previous_hash = bundle_hash

    Dir.chdir("../") do
      expect(system(command, out: File::NULL, err: File::NULL)).to eq(true)
    end

    new_hash = bundle_hash

    expect(previous_hash).to eq(new_hash),
                             "Please normalize the comments bundle file with `#{command}` from the Decidim root folder"
  end

  def bundle_hash
    Digest::MD5.file("app/assets/javascripts/decidim/comments/bundle.js").hexdigest
  end
end
