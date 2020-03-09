# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalPresenter, type: :helper do
      subject(:presenter) { described_class.new(proposal) }

      let(:proposal) { build(:proposal, body: content) }

      describe "when content contains urls" do
        let(:content) { <<~EOCONTENT }
          Content with <a href="http://urls.net" onmouseover="alert('hello')">URLs</a> of anchor type and text urls like https://decidim.org.
          And a malicous <a href="javascript:document.cookies">click me</a>
        EOCONTENT
        let(:result) { <<~EORESULT }
          Content with URLs of anchor type and text urls like <a href="https://decidim.org" target="_blank" rel="nofollow noopener">https://decidim.org</a>.
          And a malicous click me
        EORESULT

        it "converts all URLs to links and strips attributes in anchors" do
          expect(subject.body(links: true, strip_tags: true)).to eq(result)
        end
      end

      describe "#versions", versioning: true do
        subject { presenter.versions }

        let(:proposal) { create(:proposal) }

        it { is_expected.to eq(proposal.versions) }

        context "when proposal has an answer that wasn't published yet" do
          before do
            proposal.update!(answer: "an answer", state: "accepted", answered_at: Time.current)
          end

          it "only consider the first version" do
            expect(subject.count).to eq(1)
          end

          it "doesn't include state on the version" do
            expect(subject.first.changeset.keys).not_to include("state")
          end
        end

        context "when a proposal's answer gets published" do
          let(:proposal) { create(:proposal) }

          before do
            proposal.update!(answer: "an answer", state: "accepted", answered_at: Time.current)
            proposal.update!(state_published_at: Time.current)
          end

          it "only consider two versions" do
            expect(subject.count).to eq(2)
          end

          it "doesn't include state on the first version" do
            expect(subject.first.changeset.keys).not_to include("state")
          end

          it "includes the state and the state_published_at fields in the last version" do
            expect(subject.last.changeset.keys).to include("state", "state_published_at")
          end
        end
      end
    end
  end
end
