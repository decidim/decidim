# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingIframeEmbedder do
      subject { described_class.new(url) }

      let(:request_host) { "decidim.org" }
      let(:services) { %w(www.youtube.com www.twitch.tv meet.jit.si) }
      let(:youtube_video_id) { "aiyHi9MzW30" }
      let(:twitch_video_id) { "920134652" }
      let(:transformed_youtube_url) { "https://www.youtube-nocookie.com/embed/#{youtube_video_id}" }
      let(:transformed_twitch_url) { "https://player.twitch.tv/?video=#{twitch_video_id}&parent=#{request_host}" }

      before do
        allow(Decidim::Meetings).to receive(:embeddable_services).and_return services
      end

      # Hosts that should never be considered equivalent to the configured
      # services after stripping a single leading "www." or "m." prefix.
      non_embeddable_hosts = %w(
        www.www.youtube.com
        www.m.youtube.com
        m.www.youtube.com
        m.m.youtube.com
        foo.youtube.com
        www.youtube.com.evil.com
        youtube.com.evil.com
        evil.youtube.com
        www.notyoutube.com
        www.www.twitch.tv
        www.m.twitch.tv
        m.www.twitch.tv
        m.m.twitch.tv
        foo.twitch.tv
        www.twitch.tv.evil.com
        twitch.tv.evil.com
        evil.twitch.tv
        www.nottwitch.tv
      )

      describe "#embed_transformed_url" do
        %w(youtube.com www.youtube.com m.youtube.com).each do |host|
          context "with a valid youtube URL on #{host}" do
            let(:url) { "https://#{host}/watch?v=#{youtube_video_id}" }

            it "is transformed" do
              expect(subject.embed_transformed_url(request_host)).to eq(transformed_youtube_url)
            end
          end

          %w(embed live shorts).each do |youtube_path|
            context "with a valid youtube #{youtube_path} URL on #{host}" do
              let(:url) { "https://#{host}/#{youtube_path}/#{youtube_video_id}" }

              it "is transformed" do
                expect(subject.embed_transformed_url(request_host)).to eq(transformed_youtube_url)
              end
            end
          end

          context "with a valid youtube embed URL with a query string on #{host}" do
            let(:url) { "https://#{host}/embed/#{youtube_video_id}?start=30" }

            it "is transformed preserving the original query string" do
              expect(subject.embed_transformed_url(request_host)).to eq("#{transformed_youtube_url}?start=30")
            end
          end
        end

        context "with a valid youtube watch URL with additional query parameters" do
          let(:url) { "https://www.youtube.com/watch?v=#{youtube_video_id}&start=30" }

          it "is transformed without the original query string" do
            expect(subject.embed_transformed_url(request_host)).to eq(transformed_youtube_url)
          end
        end

        %w(twitch.tv www.twitch.tv m.twitch.tv).each do |host|
          context "with a valid Twitch URL on #{host}" do
            let(:url) { "https://#{host}/videos/#{twitch_video_id}?collection=YQZOzRslZRZ0TQ" }

            it "is transformed" do
              expect(subject.embed_transformed_url(request_host)).to eq(transformed_twitch_url)
            end
          end
        end

        context "with an invalid youtube URL" do
          let(:url) { "https://www.youtube.com/watch/foo/bar" }

          it "is not transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end

        context "with an HTML payload percent-encoded in the v parameter" do
          let(:url) { "https://www.youtube.com/watch?v=abc%22%3E%20--%3E%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E" }

          it "is not transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end

        %w(embed live shorts).each do |youtube_path|
          context "with an HTML payload percent-encoded in the #{youtube_path} path" do
            let(:url) { "https://www.youtube.com/#{youtube_path}/abc%22%3E%20--%3E%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E" }

            it "is not transformed" do
              expect(subject.embed_transformed_url(request_host)).to eq(url)
            end
          end
        end

        context "with an unknown youtube path" do
          let(:url) { "https://www.youtube.com/channel/#{youtube_video_id}" }

          it "is not transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end

        context "with an invalid Twitch URL" do
          let(:url) { "https://www.twitch.tv/foo/bar" }

          it "is not transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end

        non_embeddable_hosts.each do |host|
          context "with the non-embeddable host #{host}" do
            let(:url) do
              if host.include?("twitch")
                "https://#{host}/videos/#{twitch_video_id}"
              else
                "https://#{host}/watch?v=#{youtube_video_id}"
              end
            end

            it "is not transformed" do
              expect(subject.embed_transformed_url(request_host)).to eq(url)
            end
          end
        end

        context "with a not recognized streaming URL" do
          let(:url) { "https://meet.jit.si/decidim-meeting" }

          it "is not transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end
      end

      describe "#embeddable?" do
        %w(youtube.com www.youtube.com m.youtube.com twitch.tv www.twitch.tv m.twitch.tv).each do |host|
          context "with a URL on #{host}" do
            let(:url) { "https://#{host}/decidim-meeting" }

            it "is embeddable" do
              expect(subject).to be_embeddable
            end
          end
        end

        non_embeddable_hosts.each do |host|
          context "with the non-embeddable host #{host}" do
            let(:url) { "https://#{host}/decidim-meeting" }

            it "is not embeddable" do
              expect(subject).not_to be_embeddable
            end
          end
        end

        context "with a not recognized streaming URL" do
          let(:url) { "https://example.org/decidim-meeting" }

          it "is not embeddable" do
            expect(subject).not_to be_embeddable
          end

          context "and embeddable services are customized" do
            let(:services) { %w(www.youtube.com www.twitch.tv meet.jit.si example.org) }

            it "is not embeddable" do
              expect(subject).to be_embeddable
            end
          end
        end

        %w(www.example.org m.example.org).each do |host|
          context "with the non-YouTube/Twitch host #{host} when example.org is embeddable" do
            let(:services) { %w(example.org) }
            let(:url) { "https://#{host}/decidim-meeting" }

            it "is not embeddable without an exact host match" do
              expect(subject).not_to be_embeddable
            end
          end

          context "with #{host} as the configured embeddable service" do
            let(:services) { [host] }
            let(:url) { "https://example.org/decidim-meeting" }

            it "is not embeddable without an exact host match" do
              expect(subject).not_to be_embeddable
            end
          end
        end
      end

      describe "#embed_code" do
        context "with a YouTube URL" do
          let(:url) { "https://www.youtube.com/watch?v=#{youtube_video_id}" }

          it "generates an iframe tag with the embed url" do
            embed_code = subject.embed_code(request_host)

            expect(embed_code).to include(subject.embed_transformed_url(request_host))
            expect(embed_code).to include(%(<div))
            expect(embed_code).to include(%(class="disabled-iframe"))
            expect(embed_code).to include("</div")
          end
        end

        context "with an HTML payload percent-encoded in the v parameter" do
          let(:url) { "https://www.youtube.com/watch?v=abc%22%3E%20--%3E%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E" }

          it "does not include the decoded payload" do
            embed_code = subject.embed_code(request_host)

            expect(embed_code).not_to include("<img src=x onerror=alert(1)>")
            expect(embed_code).not_to include(%(embed/abc">))
          end
        end

        context "with a meet.jit.si URL containing a comment terminator" do
          let(:url) { "https://meet.jit.si/decidim-meeting?x=-->" }

          it "escapes the url in the src attribute" do
            embed_code = subject.embed_code(request_host)

            expect(embed_code).not_to include("?x=-->")
            expect(embed_code).to include("?x=--&gt;")
          end
        end

        context "with a Twitch URL" do
          let(:url) { "https://www.twitch.tv/videos/#{twitch_video_id}" }

          it "escapes the ampersand in the query string" do
            embed_code = subject.embed_code(request_host)

            expect(embed_code).to include(%(src="https://player.twitch.tv/?video=#{twitch_video_id}&amp;parent=#{request_host}"))
          end
        end
      end
    end
  end
end
