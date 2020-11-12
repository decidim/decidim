# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module AdminLog
      describe AdminLog::ConferencePresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:admin_log_resource) { create(:conference, organization: organization) }
          let(:action) { "unpublish" }
        end
      end
    end
  end
end
