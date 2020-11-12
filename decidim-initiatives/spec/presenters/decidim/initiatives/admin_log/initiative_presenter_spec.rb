# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module AdminLog
      describe InitiativePresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:admin_log_resource) { create(:initiative, organization: organization) }
          let(:action) { "publish" }
        end
      end
    end
  end
end
