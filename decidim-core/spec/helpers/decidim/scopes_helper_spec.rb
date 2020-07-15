# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ScopesHelper, type: :helper do
    describe "scopes_picker_tag" do
      let(:scope) { create(:scope) }

      it "works wrong" do
        actual = helper.scopes_picker_tag("my_scope_input", scope.id)

        expected = <<~HTML
          <div id="my_scope_input" class="data-picker picker-single" data-picker-name="my_scope_input">
            <div class="picker-values">
              <div>
                <a href="/scopes/picker?current=#{scope.id}&amp;field=my_scope_input" data-picker-value="#{scope.id}">
                  #{scope.name["en"]} (#{scope.scope_type.name["en"]})
                </a>
              </div>
            </div>
            <div class="picker-prompt">
              <a href="/scopes/picker?field=my_scope_input" role="button" aria-label="Select a scope (currently: Global scope)">Global scope</a>
            </div>
          </div>
        HTML

        expect(actual).to have_equivalent_markup_to(expected)
      end
    end
  end
end
