# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalPresenter, type: :helper do
      subject { described_class.new(proposal) }

      let(:proposal) { build(:proposal, body: content) }

      describe "when content contains urls" do
        let(:content) { <<~EOCONTENT }
          Content with <a href="http://urls.net" onmouseover="alert('hello')">URLs</a> of anchor type and text urls like https://decidim.org.
          And a malicous <a href="javascript:document.cookies">click me</a>
        EOCONTENT
        let(:result) { <<~EORESULT }
          Content with URLs of anchor type and text urls like <a href="https://decidim.org" target="_blank" rel="noopener">https://decidim.org</a>.
          And a malicous click me
        EORESULT

        it "converts all URLs to links and strips attributes in anchors" do
          expect(subject.body(strip_tags: true)).to eq(result)
        end
      end
    end
  end
end