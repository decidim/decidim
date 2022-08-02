# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/forms/attachment_collection_form_examples"

module Decidim
  module Admin
    describe AttachmentCollectionForm do
      include_examples "attachment collection form" do
        let(:collection_for) do
          create :conference, organization:
        end
      end
    end
  end
end
