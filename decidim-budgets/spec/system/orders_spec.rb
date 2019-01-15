# frozen_string_literal: true

require "spec_helper"

describe "orders", type: :system do
  include_context "with a component"

  it_behaves_like "orders", :total_budget
  it_behaves_like "orders", :total_projects
end
