# frozen_string_literal: true

require "spec_helper"

describe Decidim::PadIframeCell, type: :cell do
  subject { described_class.new(model, context: { current_user: current_user }) }

  let(:my_cell) { cell("decidim/pad_iframe", model, context: { current_user: current_user }) }
  let(:model) { create(:dummy_resource) }
  let(:current_user) { model.author }
  let(:pad) { instance_double(Decidim::Etherpad::Pad, text: pad_text) }
  let(:pad_text) { "This is the content of the pad" }

  before do
    allow(model).to receive(:pad_public_url).and_return("PUBLIC_URL")
    allow(model).to receive(:pad_read_only_url).and_return("READ_ONLY_URL")
    allow(model).to receive(:pad).and_return(pad)
  end

  context "when rendering" do
    subject { my_cell.call }

    let(:html) { subject }

    context "when there's no current user" do
      let(:current_user) { nil }

      it "renders nothing" do
        expect(html).to have_no_css("iframe")
      end
    end

    context "when the pad is not visible" do
      before do
        allow(model).to receive(:pad_is_visible?).and_return(false)
      end

      it "renders nothing" do
        expect(html).to have_no_css("iframe")
      end
    end

    context "when the pad is visible and read only" do
      before do
        allow(model).to receive(:pad_is_visible?).and_return(true)
        allow(model).to receive(:pad_is_writable?).and_return(false)
      end

      context "when the pad has contents" do
        it "renders an iframe" do
          expect(html).to have_css("iframe")
        end
      end

      context "when the pad has no contents" do
        let(:pad_text) { nil }

        it "renders nothing" do
          expect(html).to have_no_css("iframe")
        end
      end
    end

    it "renders an iframe" do
      expect(html).to have_css("iframe")
    end
  end

  describe "iframe_url" do
    context "when the pad is writable" do
      before do
        allow(model).to receive(:pad_is_writable?).and_return(true)
      end

      it "includes the writable url" do
        expect(subject.iframe_url).to include("PUBLIC_URL")
      end
    end

    context "when the pad is only readable" do
      before do
        allow(model).to receive(:pad_is_writable?).and_return(false)
      end

      it "includes the read only url" do
        expect(subject.iframe_url).to include("READ_ONLY_URL")
      end
    end

    it "includes the user's nickname" do
      expect(subject.iframe_url).to include("userName=")
      expect(subject.iframe_url).to include(current_user.nickname)
    end

    it "includes the user's locale" do
      expect(subject.iframe_url).to include("lang=")
      expect(subject.iframe_url).to include(current_user.locale)
    end
  end
end
