# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe IframeUrlTransformer do
      subject { described_class.new(url, request) }

      let(:request) { double("request") }

      describe "#transformed_url" do
        context "with a valid youtube URL" do
          let(:url) { "https://www.youtube.com/watch?v=aiyHi9MzW30" }

          it "is transformed" do
            expect(subject.transformed_url).to eq("https://www.youtube-nocookie.com/embed/aiyHi9MzW30")
          end
        end

        context "with an invalid youtube URL" do
          let(:url) { "https://www.youtube.com/watch/foo/bar" }

          it "isn't transformed" do
            expect(subject.transformed_url).to eq(url)
          end
        end

        context "with a valid Twitch URL" do
          let(:url) { "https://www.twitch.tv/videos/920134652?collection=YQZOzRslZRZ0TQ" }

          it "is transformed" do
            allow(request).to receive_messages(host: "decidim.org")

            expect(subject.transformed_url).to eq("https://player.twitch.tv/?video=920134652&parent=decidim.org")
          end
        end

        context "with an invalid Twitch URL" do
          let(:url) { "https://www.twitch.tv/foo/bar" }

          it "isn't transformed" do
            expect(subject.transformed_url).to eq(url)
          end
        end

        context "with a not recognized streaming URL" do
          let(:url) { "https://meet.jit.si/decidim-meeting" }

          it "isn't transformed" do
            expect(subject.transformed_url).to eq(url)
          end
        end
      end
    end
  end
end
