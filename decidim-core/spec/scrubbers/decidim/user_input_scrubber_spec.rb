# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserInputScrubber do
  subject { described_class.new }

  def scrub(html)
    Loofah.scrub_fragment(html, subject).to_s
  end

  RSpec::Matchers.define :be_scrubbed do
    match do |actual|
      expect(scrub(actual)).to eq actual
    end

    failure_message do |actual|
      "expected \"#{actual}\" to eq \"#{scrub(actual)}\" after scrubbing"
    end
  end

  RSpec::Matchers.define :be_scrubbed_as do |expected|
    match do |actual|
      expect(scrub(actual)).to eq expected
    end

    failure_message do |actual|
      "expected \"#{actual}\" to eq \"#{expected}\" after scrubbing, scrubbed as \"#{scrub(actual)}\" instead"
    end
  end

  it "allows iframes to embed videos" do
    html = "<iframe frameborder=\"0\" allowfullscreen=\"true\" src=\"url\"></iframe>"
    expect(html).to be_scrubbed
  end

  it "allows most basic tags" do
    html = "<a></a><b></b><strong></strong><em></em><i></i><p></p><br>"
    expect(html).to be_scrubbed
  end

  it "does not allow scripts" do
    html = "<script></script>"
    expect(html).to be_scrubbed_as("")
  end
end
