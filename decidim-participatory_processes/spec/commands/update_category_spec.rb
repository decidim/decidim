# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/commands/update_category_examples"

module Decidim::Admin
  describe UpdateCategory do
    include_examples "UpdateCategory command" do
      let(:participatory_space) { create(:participatory_process, organization:) }
    end
  end
end
