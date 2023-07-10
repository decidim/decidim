# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    describe StaticMap do
      let(:latitude) { 60.149790 }
      let(:longitude) { 24.887430 }

      include_context "with map utility" do
        subject { utility }
      end

      describe "#link" do
        it "returns the default link" do
          expect(subject.link(latitude:, longitude:)).to eq(
            "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=17/#{latitude}/#{longitude}"
          )
        end

        context "with zoom option" do
          it "returns the correct link" do
            expect(
              subject.link(
                latitude:,
                longitude:,
                options: { zoom: 15 }
              )
            ).to eq(
              "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=15/#{latitude}/#{longitude}"
            )
          end
        end

        context "with configured link" do
          let(:config) { { link: "https://customstreetmap.org/" } }

          it "returns the correct link" do
            expect(
              subject.link(
                latitude:,
                longitude:
              )
            ).to eq(
              "https://customstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=17/#{latitude}/#{longitude}"
            )
          end
        end
      end

      describe "#url" do
        it "returns nil when the url has not been configured" do
          expect(subject.url(latitude:, longitude:)).to be_nil
        end

        context "with configured url" do
          let(:config) { { url: "https://staticmaps.example.org/" } }

          it "returns the correct URL" do
            expect(subject.url(latitude:, longitude:)).to eq(
              "https://staticmaps.example.org/?latitude=#{latitude}&longitude=#{longitude}&zoom=#{Decidim::Map::StaticMap::DEFAULT_ZOOM}&width=#{Decidim::Map::StaticMap::DEFAULT_SIZE}&height=#{Decidim::Map::StaticMap::DEFAULT_SIZE}"
            )
          end

          context "and the configured URL has extra parameters" do
            let(:config) { { url: "https://staticmaps.example.org/?key=123&msg=foo" } }

            it "returns the correct URL" do
              expect(subject.url(latitude:, longitude:)).to eq(
                "https://staticmaps.example.org/?key=123&msg=foo&latitude=#{latitude}&longitude=#{longitude}&zoom=#{Decidim::Map::StaticMap::DEFAULT_ZOOM}&width=#{Decidim::Map::StaticMap::DEFAULT_SIZE}&height=#{Decidim::Map::StaticMap::DEFAULT_SIZE}"
              )
            end
          end

          context "when custom options are provided" do
            it "returns the correct URL" do
              expect(
                subject.url(
                  latitude:,
                  longitude:,
                  options: { zoom: 10, width: 200, height: 200 }
                )
              ).to eq(
                "https://staticmaps.example.org/?latitude=#{latitude}&longitude=#{longitude}&zoom=10&width=200&height=200"
              )
            end
          end
        end

        context "with configured callable url" do
          let(:options) { double }
          let(:final_url) { double }

          it "calls the callable object and returns the correct URL" do
            url_result = double
            allow(url_result).to receive(:to_s).and_return(final_url)

            url = lambda do |config|
              expect(config[:latitude]).to be(latitude)
              expect(config[:longitude]).to be(longitude)
              expect(config[:options]).to be(options)

              url_result
            end

            util = utility_class.new(
              organization:,
              config: config.merge(url:),
              locale:
            )
            expect(
              util.url(
                latitude:,
                longitude:,
                options:
              )
            ).to be(final_url)
          end
        end
      end

      describe "#url_params" do
        it "returns the default params" do
          expect(
            subject.url_params(
              latitude:,
              longitude:
            )
          ).to eq(
            latitude:,
            longitude:,
            zoom: Decidim::Map::StaticMap::DEFAULT_ZOOM,
            width: Decidim::Map::StaticMap::DEFAULT_SIZE,
            height: Decidim::Map::StaticMap::DEFAULT_SIZE
          )
        end

        context "with custom options" do
          it "returns the correct params" do
            expect(
              subject.url_params(
                latitude:,
                longitude:,
                options: {
                  zoom: 10,
                  width: 200,
                  height: 200,
                  foo: "bar"
                }
              )
            ).to eq(
              latitude:,
              longitude:,
              zoom: 10,
              width: 200,
              height: 200
            )
          end
        end
      end

      describe "#image_data" do
        context "when the URL is not configured" do
          it "does not do a request and returns an empty string" do
            # The unexpected HTTP requests will automatically raise an error, so
            # it does not need to be tested separately.
            expect(
              subject.image_data(
                latitude:,
                longitude:
              )
            ).to eq("")
          end
        end

        context "when the URL is configured" do
          let(:config) { { url: "https://staticmaps.example.org/" } }
          let(:image_url) { "https://staticmaps.example.org/?latitude=#{latitude}&longitude=#{longitude}&zoom=#{Decidim::Map::StaticMap::DEFAULT_ZOOM}&width=#{Decidim::Map::StaticMap::DEFAULT_SIZE}&height=#{Decidim::Map::StaticMap::DEFAULT_SIZE}" }
          let(:body) { "imagedata" }

          before do
            stub_request(:get, image_url).to_return(body:)
          end

          it "does a request and returns an the data returned by the URL" do
            expect(
              subject.image_data(
                latitude:,
                longitude:
              )
            ).to eq(body)

            expect(
              a_request(:get, image_url).with(
                headers: { "Referer" => organization.host }
              )
            ).to have_been_made.once
          end
        end
      end
    end
  end
end
