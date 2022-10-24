# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/commands/destroy_category_examples"

module Decidim::Admin
  describe DestroyCategory do
    include_examples "DestroyCategory command" do
      let(:participatory_space) { create(:assembly, organization:) }
    end
  end
end
