# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/forms/attachment_form_examples"

module Decidim
  module Admin
    describe Decidim::Admin::AttachmentForm do
      include_examples "attachment form" do
        let(:attached_to) do
          create :conference, organization:
        end
      end
    end
  end
end
