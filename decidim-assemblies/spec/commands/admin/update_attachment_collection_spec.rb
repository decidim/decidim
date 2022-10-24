# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/commands/update_attachment_collection_examples"

module Decidim::Admin
  describe UpdateAttachmentCollection do
    include_examples "UpdateAttachmentCollection command" do
      let(:collection_for) { create(:assembly, organization:) }
    end
  end
end
