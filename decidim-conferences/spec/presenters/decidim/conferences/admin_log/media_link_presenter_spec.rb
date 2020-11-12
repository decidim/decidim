# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module AdminLog
      describe MediaLinkPresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:conference) { create(:conference, organization: organization) }
          let(:admin_log_resource) { create(:media_link, conference: conference) }
          let(:action) { "delete" }
        end
      end
    end
  end
end
