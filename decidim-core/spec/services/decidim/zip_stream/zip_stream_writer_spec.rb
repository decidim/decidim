# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ZipStream
    DummyUploader = Struct.new(:provider, :file)
    class ZipStreamWriterWrapper
      include ::Decidim::ZipStream::Writer
    end

    describe Writer do
      subject { ZipStreamWriterWrapper.new }

      let(:user) { create(:user) }

      context "when nothing attached" do
        before do
          user.avatar.purge
        end

        describe "#add_attachments_to_zip_stream" do
          it "does nothing" do
            attachment_block = ["some/path", [user.avatar]]
            subject.add_attachments_to_zip_stream(nil, [attachment_block])
          end
        end
      end
    end
  end
end
