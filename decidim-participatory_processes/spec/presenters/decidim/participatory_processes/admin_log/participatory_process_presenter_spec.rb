# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module AdminLog
      describe ParticipatoryProcessPresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:admin_log_resource) { create(:participatory_process, organization: organization) }
          let(:action) { "unpublish" }
        end
      end
    end
  end
end
