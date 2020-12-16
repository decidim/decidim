# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::VideoconferenceCell, type: :cell do
  subject { described_class.new(model, context: { current_user: current_user }) }

  let(:my_cell) { cell("decidim/meetings/videoconference", model, context: { current_user: current_user }) }
  let(:model) { create(:meeting) }
  let(:current_user) { create(:user) }

  context "when rendering" do
    subject { my_cell.call }

    let(:html) { subject }

    context "when there's no current user" do
      let(:current_user) { nil }

      it "renders nothing" do
        expect(html).to have_no_css("iframe")
      end
    end

    context "when the videoconference is not visible" do
      before do
        expect(my_cell).to receive(:pad_is_visible?).and_return(false)
      end

      it "renders nothing" do
        expect(html).to have_no_css("iframe")
      end
    end

    context "when the videoconference is visible" do
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
        expect(model).to receive(:pad_is_writable?).and_return(true)
      end

      it "includes the writable url" do
        expect(subject.iframe_url).to include("PUBLIC_URL")
      end
    end

    context "when the pad is only readable" do
      before do
        expect(model).to receive(:pad_is_writable?).and_return(false)
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
