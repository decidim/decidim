# frozen_string_literal: true

require "spec_helper"
require "decidim/zip_stream/zip_stream_writer"

module Decidim
  module ZipStream
    DummyUploader = Struct.new(:provider, :file)
    class ZipStreamWriterWrapper
      include ::Decidim::ZipStream::Writer
    end

    describe Writer do
      subject { ZipStreamWriterWrapper.new }

      context "when fog_provider is unknown" do
        describe "#add_attachments_to_zip_stream" do
          it "does nothing" do
            attachment_block = ["some/path", [DummyUploader.new("fog/dummy", Object.new)]]
            subject.add_attachments_to_zip_stream(nil, [attachment_block])
          end
        end
      end
    end
  end
end
