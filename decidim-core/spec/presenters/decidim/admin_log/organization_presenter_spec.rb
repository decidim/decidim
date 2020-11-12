# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AdminLog
    describe OrganizationPresenter, type: :helper do
      include_examples "present admin log entry" do
        let(:admin_log_resource) { organization }
        let(:action) { "update_id_documents_config" }
      end
    end
  end
end
