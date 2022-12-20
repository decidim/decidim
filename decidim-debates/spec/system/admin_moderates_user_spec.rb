# frozen_string_literal: true

require "spec_helper"

# this is the admin panel interaction of the tests already implemented in
# decidim/decidim-core/spec/system/user_report_spec.rb
# Please note the actual tests that
describe "Admin reports user", type: :system do
  it_behaves_like "hideable resource during block" do
    let(:reportable) { content.author }

    let(:component) { create(:debates_component, organization:) }
    let(:content) { create(:debate, :participant_author, component:) }
  end
end
