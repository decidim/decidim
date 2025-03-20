# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/commands/create_category_examples"

module Decidim::Admin
  describe CreateCategory do
    include_examples "CreateCategory command" do
      let(:participatory_space) { create(:participatory_process, organization:) }
    end
  end
end
