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

      describe "when content contains paragraphs" do
        let(:content) { <<~EOCONTENT }
          Content with

          <p>some</p><p>paragraphs</p><p>with some interesting</p><p>content</p>on the text.
        EOCONTENT
        let(:result) { <<~EORESULT }
          Content with

          some

          paragraphs

          with some interesting

          content

          on the text.
        EORESULT

        it "adds line feeds to paragraphs" do
          expect(subject.body(links: false, strip_tags: true)).to eq(result)
        end
      end

      describe "when content contains an ordered list but not unordered" do
        let(:content) { <<~EOCONTENT }
          Content with

          <ol><li>a</li><li>random</li><li>ordered</li><li>list</li></ol>
        EOCONTENT
        let(:result) { <<~EORESULT }
          Content with

          1. a
          2. random
          3. ordered
          4. list

        EORESULT

        it "adds numberings to ordered lists" do
          expect(subject.body(links: false, strip_tags: true)).to eq(result)
        end
      end

      describe "when content contains an unordered list but not ordered" do
        let(:content) { <<~EOCONTENT }
          Content with

          <ul><li>a</li><li>random</li><li>unordered</li><li>list</li></ul>
        EOCONTENT
        let(:result) { <<~EORESULT }
          Content with

          • a
          • random
          • unordered
          • list

        EORESULT

        it "adds bullet points to unordered lists" do
          expect(subject.body(links: false, strip_tags: true)).to eq(result)
        end
      end

      describe "when content contains paragraphs, ordered and unordered lists" do
        let(:content) { <<~EOCONTENT }
          Content with

          <p>some</p><p>paragraphs,</p><ul><li>unordered</li><li>list</li></ul>
          and a

          <ol><li>random</li><li>ordered</li><li>list</li></ol>
          and then again another

          <ul><li>unordered</li><li>list</li></ul>
        EOCONTENT
        let(:result) { <<~EORESULT }
          Content with

          some

          paragraphs,

          • unordered
          • list

          and a

          1. random
          2. ordered
          3. list

          and then again another

          • unordered
          • list

        EORESULT

        it "adds line feeds to paragraphs, bullet points to unordered lists, and numberings to ordered lists" do
          expect(subject.body(links: false, strip_tags: true)).to eq(result)
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
