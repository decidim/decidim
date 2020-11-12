# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AdminLog
    describe UserPresenter, type: :helper do
      include_examples "present admin log entry" do
        let(:admin_log_resource) { organization }
        let(:action) { "officialize" }
      end
    end
  end
end
