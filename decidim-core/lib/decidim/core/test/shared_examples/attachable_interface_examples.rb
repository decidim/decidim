# frozen_string_literal: true

require "spec_helper"

shared_examples_for "attachable interface" do
  let!(:attachments) { create_list(:attachment, 3, attached_to: model) }

  describe "attachments" do
    let(:query) { "{ attachments { url } }" }

    it "includes the attachment urls" do
      attachment_urls = response["attachments"].map { |attachment| attachment["url"] }
      expect(attachment_urls).to include(*attachments.map(&:url))
    end
  end
end
