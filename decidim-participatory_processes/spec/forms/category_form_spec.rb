# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/forms/category_form_examples"

module Decidim
  module Admin
    describe CategoryForm do
      include_examples "category form" do
        let(:participatory_space) do
          create :participatory_process, organization:
        end
      end
    end
  end
end
