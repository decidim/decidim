# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/commands/create_category_examples"

describe Decidim::Admin::CreateCategory do
  include_examples "CreateCategory command" do
    let(:participatory_space) { create(:assembly, organization: organization) }
  end
end
