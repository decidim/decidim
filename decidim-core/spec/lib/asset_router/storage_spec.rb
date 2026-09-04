# frozen_string_literal: true

require "spec_helper"
require "active_storage/service/dummy_service"

module Decidim::AssetRouter
  describe Storage do
    subject { router }

    let(:router) { described_class.new(asset) }
    let(:asset) { organization.official_img_footer }
    let(:filename) { "avatar.jpg" }
    let(:organization) { create(:organization) }

    describe "#url" do
      subject { router.url(**options) }

      let(:options) { {} }
      let(:default_port) { Capybara.server_port }

      shared_context "with current URL options host" do |host:, protocol: nil, port: nil|
        before do
          ActiveStorage::Current.url_options = { protocol:, host:, port: }.compact
        end
      end

      shared_context "without default URL options host" do
        before { allow(Rails.env).to receive(:local?).and_return(false) }
      end

      shared_examples "disk service URL" do
        it "creates the disk service URL to the blob" do
          suffix = respond_to?(:expected_url_suffix) ? expected_url_suffix : nil
          expect(subject).to match(%r{\A#{Regexp.escape(expected_host_url)}/rails/active_storage/disk/[^/]+/#{Regexp.escape("#{filename}#{suffix}")}\z})
        end
      end

      shared_examples "blob redirect URL" do
        it "creates the redirect route to the blob" do
          suffix = respond_to?(:expected_url_suffix) ? expected_url_suffix : nil
          expect(subject).to match(%r{\A#{Regexp.escape(expected_host_url)}/rails/active_storage/blobs/redirect/[^/]+/#{Regexp.escape("#{filename}#{suffix}")}\z})
        end
      end

      shared_examples "blob redirect path" do
        it "creates the redirect route to the blob" do
          suffix = respond_to?(:expected_url_suffix) ? expected_url_suffix : nil
          expect(subject).to match(%r{\A/rails/active_storage/blobs/redirect/[^/]+/#{Regexp.escape("#{filename}#{suffix}")}\z})
        end
      end

      shared_examples "representation redirect URL" do
        it "creates the redirect URL to the blob representation" do
          suffix = respond_to?(:expected_url_suffix) ? expected_url_suffix : nil
          expect(subject).to match(%r{\A#{Regexp.escape(expected_host_url)}/rails/active_storage/representations/redirect/[^/]+/[^/]+/#{Regexp.escape("#{filename}#{suffix}")}\z})
        end
      end

      shared_examples "representation redirect path" do
        it "creates the redirect URL to the blob representation" do
          suffix = respond_to?(:expected_url_suffix) ? expected_url_suffix : nil
          expect(subject).to match(%r{\A/rails/active_storage/representations/redirect/[^/]+/[^/]+/#{Regexp.escape("#{filename}#{suffix}")}\z})
        end
      end

      shared_examples "no blob attachments fetched" do
        it "does not fetch the attachments for the blob" do
          expect(asset.blob).not_to receive(:attachments)
          subject
        end
      end

      context "with an ActiveStorage::Attached" do
        context "when the host is set" do
          let(:expected_host_url) { "http://another.example.org:#{default_port}" }

          include_context "with current URL options host", host: "another.example.org"
          it_behaves_like "disk service URL"

          context "when requesting the blob URL with a different host" do
            let(:expected_host_url) { "http://passed.example.org:#{default_port}" }
            let(:options) { { host: "passed.example.org" } }

            it_behaves_like "disk service URL"
          end
        end

        context "when the host is not set" do
          let(:expected_host_url) { "http://localhost:#{default_port}" }

          it_behaves_like "disk service URL"

          context "and default URL options do not define the host" do
            let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

            include_context "without default URL options host"
            it_behaves_like "disk service URL"
          end
        end

        context "when requesting the local redirect path to the asset" do
          let(:options) { { only_path: true } }

          it_behaves_like "blob redirect path"

          context "with extra URL options" do
            let(:options) { { only_path: true, utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }
            let(:expected_url_suffix) { "?utm_campaign=testing&utm_medium=email&utm_source=website" }

            it_behaves_like "blob redirect path"
          end
        end

        context "when requesting the blob URL with a different host" do
          let(:expected_host_url) { "http://another.example.org:#{default_port}" }
          let(:options) { { host: "another.example.org" } }

          it_behaves_like "disk service URL"
        end
      end

      context "with an ActiveStorage::Blob" do
        let(:asset) { organization.official_img_footer.blob }

        context "when the host is set" do
          let(:expected_host_url) { "http://another.example.org:#{default_port}" }

          include_context "with current URL options host", host: "another.example.org"
          it_behaves_like "disk service URL"

          context "when requesting the blob URL with a different host" do
            let(:expected_host_url) { "http://passed.example.org:#{default_port}" }
            let(:options) { { host: "passed.example.org" } }

            it_behaves_like "disk service URL"
          end
        end

        context "when the host is not set" do
          let(:expected_host_url) { "http://localhost:#{default_port}" }

          it_behaves_like "disk service URL"

          context "and default URL options do not define the host" do
            let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

            include_context "without default URL options host"
            it_behaves_like "disk service URL"
          end

          context "and the resource does not have an attached organization record" do
            let(:asset) { create(:blob) }
            let(:filename) { asset.filename.to_s }

            it_behaves_like "disk service URL"

            context "and default URL options do not define the host" do
              include_context "without default URL options host"
              it_behaves_like "blob redirect path"
            end
          end
        end

        context "when requesting the local redirect path to the asset" do
          let(:options) { { only_path: true } }

          it_behaves_like "blob redirect path"

          context "with extra URL options" do
            let(:options) { { only_path: true, utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }
            let(:expected_url_suffix) { "?utm_campaign=testing&utm_medium=email&utm_source=website" }

            it_behaves_like "blob redirect path"
          end
        end

        context "when requesting the blob URL with a different host" do
          let(:expected_host_url) { "http://another.example.org:#{default_port}" }
          let(:options) { { host: "another.example.org" } }

          it_behaves_like "disk service URL"
        end
      end

      context "with a variant" do
        let(:asset) { organization.official_img_footer.variant(resize_to_fit: [160, 160]) }
        let(:track_variants) { true }
        let(:expected_host_url) { "http://localhost:#{default_port}" }

        before do
          # This is typically set through `config.active_storage.track_variants`
          # and for test environment it seems to be enabled by default at the
          # time of writing these specs. This config is overridden for these
          # specs because the default configurations may be changed through
          # other changes or gem updates.
          allow(ActiveStorage).to receive(:track_variants).and_return(track_variants)
        end

        it_behaves_like "representation redirect URL"
        it_behaves_like "no blob attachments fetched"

        context "when default URL options do not define the host" do
          let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

          include_context "without default URL options host"
          it_behaves_like "representation redirect URL"
        end

        context "when the url_options have been set" do
          let(:expected_host_url) { "https://another.example.org:8080" }

          include_context "with current URL options host", protocol: "https", host: "another.example.org", port: 8080
          it_behaves_like "representation redirect URL"
          it_behaves_like "no blob attachments fetched"

          context "when requesting the blob URL with a different host" do
            let(:expected_host_url) { "https://passed.example.org:8080" }
            let(:options) { { host: "passed.example.org" } }

            it_behaves_like "representation redirect URL"
          end
        end

        context "when the resource does not have an attached organization record" do
          let(:asset) { blob.variant(resize_to_fit: [160, 160]) }
          let(:blob) { create(:blob) }
          let(:filename) { blob.filename.to_s }

          it_behaves_like "representation redirect URL"
          it_behaves_like "no blob attachments fetched"

          context "and default URL options do not define the host" do
            include_context "without default URL options host"
            it_behaves_like "representation redirect path"
          end
        end

        context "when requesting the local redirect path to the asset" do
          let(:options) { { only_path: true } }

          it_behaves_like "representation redirect path"

          context "with extra URL options" do
            let(:options) { { only_path: true, utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }
            let(:expected_url_suffix) { "?utm_campaign=testing&utm_medium=email&utm_source=website" }

            it_behaves_like "representation redirect path"
          end
        end

        context "when requesting the blob URL with a different host" do
          let(:expected_host_url) { "http://another.example.org:#{default_port}" }
          let(:options) { { host: "another.example.org" } }

          it_behaves_like "representation redirect URL"
        end

        context "when the asset has been processed" do
          before { asset.processed }

          it_behaves_like "disk service URL"
          it_behaves_like "no blob attachments fetched"

          context "and default URL options do not define the host" do
            let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

            include_context "without default URL options host"
            it_behaves_like "disk service URL"
          end

          # Note that this situation should not normally happen but it is
          # possible e.g. if the backend has created the variant record in the
          # database but has not yet uploaded the asset to the storage service.
          context "and does not exist at the storage service" do
            before do
              path = asset.blob.service.path_for(asset.key)
              File.delete(path)
            end

            # Ensure the preconditions are met for the tests in this context.
            it "ensures the asset does not exist" do
              expect(asset.send(:processed?)).to be(true)
              expect(asset.key).to be_present
              expect(asset.blob.service.exist?(asset.key)).to be(false)
            end

            it_behaves_like "representation redirect URL"
            it_behaves_like "no blob attachments fetched"

            context "and default URL options do not define the host" do
              let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

              include_context "without default URL options host"
              it_behaves_like "representation redirect URL"
            end
          end

          context "and the resource does not have an attached organization record" do
            let(:asset) { blob.variant(resize_to_fit: [160, 160]) }
            let(:blob) { create(:blob) }
            let(:filename) { blob.filename.to_s }

            it_behaves_like "disk service URL"
            it_behaves_like "no blob attachments fetched"

            context "and default URL options do not define the host" do
              include_context "without default URL options host"
              it_behaves_like "representation redirect path"
            end
          end

          context "and requesting the local redirect path to the asset" do
            let(:options) { { only_path: true } }

            it_behaves_like "representation redirect path"

            context "with extra URL options" do
              let(:options) { { only_path: true, utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }
              let(:expected_url_suffix) { "?utm_campaign=testing&utm_medium=email&utm_source=website" }

              it_behaves_like "representation redirect path"
            end
          end

          context "and requesting the blob URL with a different host" do
            let(:expected_host_url) { "http://another.example.org:#{default_port}" }
            let(:options) { { host: "another.example.org" } }

            it_behaves_like "disk service URL"
          end
        end

        context "when track_variants is disabled" do
          let(:track_variants) { false }

          it_behaves_like "representation redirect URL"
          it_behaves_like "no blob attachments fetched"

          context "and default URL options do not define the host" do
            let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

            include_context "without default URL options host"
            it_behaves_like "representation redirect URL"
          end

          context "and the asset has been processed" do
            before { asset.processed }

            it_behaves_like "disk service URL"
            it_behaves_like "no blob attachments fetched"

            context "and default URL options do not define the host" do
              let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

              include_context "without default URL options host"
              it_behaves_like "disk service URL"
            end

            context "and when passing incompatible URL options" do
              # The `:host` option is passed e.g. in many mailers.
              # `ActiveStorage::Variant#url` method does not allow this argument
              # which is why this test is testing that it does not lead to an
              # error.
              let(:options) { { host: "example.lvh.me" } }
              let(:expected_host_url) { "http://example.lvh.me:#{default_port}" }

              it_behaves_like "disk service URL"
              it_behaves_like "no blob attachments fetched"
            end

            context "and the resource does not have an attached organization record" do
              let(:asset) { blob.variant(resize_to_fit: [160, 160]) }
              let(:blob) { create(:blob) }
              let(:filename) { blob.filename.to_s }

              it_behaves_like "disk service URL"
              it_behaves_like "no blob attachments fetched"

              context "and default URL options do not define the host" do
                include_context "without default URL options host"
                it_behaves_like "representation redirect path"
              end
            end
          end
        end

        context "when the variant has a different file extension" do
          let(:asset) { organization.official_img_footer.variant(resize_to_fit: [160, 160], format: "png") }
          let(:filename) { "avatar.png" }

          it_behaves_like "representation redirect URL"
          it_behaves_like "no blob attachments fetched"

          context "and default URL options do not define the host" do
            let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

            include_context "without default URL options host"
            it_behaves_like "representation redirect URL"
          end

          context "when the resource does not have an attached organization record" do
            let(:asset) { blob.variant(resize_to_fit: [160, 160], format: "png") }
            let(:blob) { create(:blob) }
            let(:filename) { blob.filename.to_s.ext("png") }

            it_behaves_like "representation redirect URL"
            it_behaves_like "no blob attachments fetched"

            context "and default URL options do not define the host" do
              include_context "without default URL options host"
              it_behaves_like "representation redirect path"
            end
          end

          context "when the asset has been processed" do
            before { asset.processed }

            it_behaves_like "disk service URL"
            it_behaves_like "no blob attachments fetched"

            context "and default URL options do not define the host" do
              let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

              include_context "without default URL options host"
              it_behaves_like "disk service URL"
            end

            context "and the resource does not have an attached organization record" do
              let(:asset) { blob.variant(resize_to_fit: [160, 160], format: "png") }
              let(:blob) { create(:blob) }
              let(:filename) { blob.filename.to_s.ext("png") }

              it_behaves_like "disk service URL"
              it_behaves_like "no blob attachments fetched"

              context "and default URL options do not define the host" do
                include_context "without default URL options host"
                it_behaves_like "representation redirect path"
              end
            end
          end

          context "when track_variants is disabled" do
            let(:track_variants) { false }

            it_behaves_like "representation redirect URL"
            it_behaves_like "no blob attachments fetched"

            context "and default URL options do not define the host" do
              let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

              include_context "without default URL options host"
              it_behaves_like "representation redirect URL"
            end

            context "and the asset has been processed" do
              before { asset.processed }

              it_behaves_like "disk service URL"
              it_behaves_like "no blob attachments fetched"

              context "and default URL options do not define the host" do
                let(:expected_host_url) { "http://#{organization.host}:#{default_port}" }

                include_context "without default URL options host"
                it_behaves_like "disk service URL"
              end

              context "and the resource does not have an attached organization record" do
                let(:asset) { blob.variant(resize_to_fit: [160, 160], format: "png") }
                let(:blob) { create(:blob) }
                let(:filename) { blob.filename.to_s.ext("png") }

                it_behaves_like "disk service URL"
                it_behaves_like "no blob attachments fetched"

                context "and default URL options do not define the host" do
                  include_context "without default URL options host"
                  it_behaves_like "representation redirect path"
                end
              end
            end

            context "and the resource does not have an attached organization record" do
              let(:asset) { blob.variant(resize_to_fit: [160, 160], format: "png") }
              let(:blob) { create(:blob) }
              let(:filename) { blob.filename.to_s.ext("png") }

              it_behaves_like "representation redirect URL"
              it_behaves_like "no blob attachments fetched"

              context "and default URL options do not define the host" do
                include_context "without default URL options host"
                it_behaves_like "representation redirect path"
              end
            end
          end
        end
      end

      # This is used by the generator specs to check that some default
      # configurations are set correctly.
      context "with nil" do
        let(:asset) { nil }

        it { is_expected.to be_nil }
      end

      context "when the CDN host is defined" do
        let(:expected_host_url) { "https://cdn.example.org" }

        before do
          allow(Decidim).to receive(:storage_cdn_host).and_return("https://cdn.example.org")
        end

        it_behaves_like "blob redirect URL"
        it_behaves_like "no blob attachments fetched"

        context "with extra URL options" do
          let(:options) { { utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }
          let(:expected_url_suffix) { "?utm_campaign=testing&utm_medium=email&utm_source=website" }

          it_behaves_like "blob redirect URL"
          it_behaves_like "no blob attachments fetched"
        end
      end

      context "when using an external storage service" do
        let(:service) { ActiveStorage::Service::DummyService.new(host: "https://storage.lvh.me") }
        let(:service_registry) { double }

        before do
          allow(ActiveStorage::Blob).to receive(:services).and_return(service_registry)
          allow(ActiveStorage::Blob).to receive(:service).and_return(service)
          allow(service_registry).to receive(:fetch) do |name|
            raise KeyError, "Unknown storage service: #{name}" unless name.to_sym == :dummy

            service
          end
        end

        context "with an ActiveStorage::Attached" do
          it "generates the URL to the storage service" do
            expect(subject).to eq("#{service.host}/public/#{asset.blob.key}")
          end

          context "when requesting the local redirect path to the asset" do
            let(:options) { { only_path: true } }

            it_behaves_like "blob redirect path"
          end

          context "with the host option" do
            let(:options) { { host: "another.example.org" } }

            it "generates the URL to the storage service" do
              expect(subject).to eq("#{service.host}/public/#{asset.blob.key}")
            end
          end
        end

        context "with an ActiveStorage::Blob" do
          let(:asset) { organization.official_img_footer.blob }

          it "generates the URL to the storage service" do
            expect(subject).to eq("#{service.host}/public/#{asset.key}")
          end

          context "when requesting the local redirect path to the asset" do
            let(:options) { { only_path: true } }

            it_behaves_like "blob redirect path"
          end

          context "with the host option" do
            let(:options) { { host: "another.example.org" } }

            it "generates the URL to the storage service" do
              expect(subject).to eq("#{service.host}/public/#{asset.key}")
            end
          end
        end

        context "with a variant" do
          let(:asset) { organization.official_img_footer.variant(resize_to_fit: [160, 160]) }
          let(:expected_host_url) { "http://localhost:#{default_port}" }
          let(:track_variants) { true }

          before do
            allow(ActiveStorage).to receive(:track_variants).and_return(track_variants)
          end

          it_behaves_like "representation redirect URL"
          it_behaves_like "no blob attachments fetched"

          context "when requesting the local redirect path to the asset" do
            let(:options) { { only_path: true } }

            it_behaves_like "representation redirect path"
          end

          context "with the host option" do
            let(:expected_host_url) { "http://another.example.org:#{default_port}" }
            let(:options) { { host: "another.example.org" } }

            it_behaves_like "representation redirect URL"
          end

          context "when the asset has been processed" do
            before { asset.processed }

            it "generates the URL to the storage service" do
              expect(subject).to eq("#{service.host}/public/#{asset.key}")
            end

            context "when requesting the local redirect path to the asset" do
              let(:options) { { only_path: true } }

              it_behaves_like "representation redirect path"
            end

            context "with the host option" do
              let(:expected_host_url) { "http://another.example.org:#{default_port}" }
              let(:options) { { host: "another.example.org" } }

              it "generates the URL to the storage service" do
                expect(subject).to eq("#{service.host}/public/#{asset.key}")
              end
            end
          end

          context "when track_variants is disabled" do
            let(:track_variants) { false }

            it_behaves_like "representation redirect URL"
            it_behaves_like "no blob attachments fetched"

            context "when requesting the local redirect path to the asset" do
              let(:options) { { only_path: true } }

              it_behaves_like "representation redirect path"
            end

            context "with the host option" do
              let(:expected_host_url) { "http://another.example.org:#{default_port}" }
              let(:options) { { host: "another.example.org" } }

              it_behaves_like "representation redirect URL"
            end

            context "and the asset has been processed" do
              before { asset.processed }

              it "generates the URL to the storage service" do
                expect(subject).to eq("#{service.host}/public/#{asset.key}")
              end

              context "when requesting the local redirect path to the asset" do
                let(:options) { { only_path: true } }

                it_behaves_like "representation redirect path"
              end

              context "with the host option" do
                let(:expected_host_url) { "http://another.example.org:#{default_port}" }
                let(:options) { { host: "another.example.org" } }

                it "generates the URL to the storage service" do
                  expect(subject).to eq("#{service.host}/public/#{asset.key}")
                end
              end
            end
          end
        end
      end
    end
  end
end
