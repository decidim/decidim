# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/commands/update_category_examples"

describe Decidim::Admin::UpdateCategory do
  include_examples "UpdateCategory command" do
    let(:participatory_space) { create(:assembly, organization: organization) }
  end
end
