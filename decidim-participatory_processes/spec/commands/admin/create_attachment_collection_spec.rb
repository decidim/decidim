# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/commands/create_attachment_collection_examples"

module Decidim::Admin
  describe CreateAttachmentCollection do
    include_examples "CreateAttachmentCollection command" do
      let(:collection_for) { create(:participatory_process, organization:) }
    end
  end
end
