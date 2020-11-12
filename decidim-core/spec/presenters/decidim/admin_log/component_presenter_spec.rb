# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AdminLog
    describe ComponentPresenter, type: :helper do
      include_examples "present admin log entry" do
        let(:admin_log_resource) { create(:component, organization: organization) }
        let(:action) { "unpublish" }
      end
    end
  end
end
