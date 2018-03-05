# frozen_string_literal: true

module Capybara
  module ScopesPicker
    def scopes_picker_find(id, multiple: nil, global_value: "")
      Struct.new(:data_picker, :global_value).new(data_picker_find(id, multiple: multiple), global_value)
    end

    RSpec::Matchers.define :have_scope_picked do |expected|
      match do |scope_picker|
        data_picker = scope_picker.data_picker
        scope_name = expected ? translated(expected.name) : t("decidim.scopes.global")
        expect(data_picker).to have_selector(".picker-values div input[value='#{expected&.id || scope_picker.global_value}']", visible: false)
        expect(data_picker).to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,'#{scope_name}')]]")
      end
    end

    RSpec::Matchers.define :have_scope_not_picked do |expected|
      match do |scope_picker|
        data_picker = scope_picker.data_picker
        scope_name = expected ? translated(expected.name) : t("decidim.scopes.global")
        expect(data_picker).not_to have_selector(".picker-values div input[value='#{expected&.id || scope_picker.global_value}']", visible: false)
        expect(data_picker).not_to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,'#{scope_name}')]]")
      end
    end

    def scope_pick(scope_picker, scope)
      data_picker = scope_picker.data_picker
      # use scope_repick to change single scope picker selected scope
      expect(data_picker).to have_selector(".picker-values:empty", visible: false) if data_picker.has_css?(".picker-single")

      expect(data_picker).to have_selector(".picker-prompt")
      data_picker.find(".picker-prompt").click

      scope_picker_browse_scopes(scope.part_of_scopes) if scope
      scope_picker_pick_current

      expect(scope_picker).to have_scope_picked(scope)
    end

    def scope_repick(scope_picker, old_scope, new_scope)
      data_picker = scope_picker.data_picker

      expect(data_picker).to have_selector(".picker-values div input[value='#{old_scope&.id || scope_picker.global_value}']", visible: false)
      data_picker.find(:xpath, "//div[contains(@class,'picker-values')]/div/input[@value='#{old_scope&.id || scope_picker.global_value}']/../a").click

      # browse to lowest common parent between old and new scope
      parent_scope = (old_scope.part_of_scopes & new_scope.part_of_scopes).last

      scope_picker_browse_scope(parent_scope, back: true)
      scope_picker_browse_scopes(new_scope.part_of_scopes - old_scope.part_of_scopes)
      scope_picker_pick_current

      expect(scope_picker).to have_scope_picked(new_scope)
    end

    def scope_unpick(scope_picker, scope)
      data_picker = scope_picker.data_picker

      expect(data_picker).to have_selector(".picker-values div input[value='#{scope&.id || scope_picker.global_value}']", visible: false)
      data_picker.find(".picker-values div input[value='#{scope&.id || scope_picker.global_value}']").click

      expect(scope_picker).to have_scope_not_picked(scope)
    end

    private

    def data_picker_find(id, multiple: nil)
      if multiple.nil?
        expect(page).to have_selector("div.data-picker##{id}")
      else
        expect(page).to have_selector("div.data-picker.picker-#{multiple ? "multiple" : "single"}##{id}")
      end
      find("div.data-picker##{id}")
    end

    def scope_picker_browse_scopes(scopes)
      scopes.each do |scope|
        scope_picker_browse_scope(scope)
      end
    end

    def scope_picker_browse_scope(scope, back: false)
      body = find(:xpath, "//body")
      where = back ? "header" : "content"
      scope_name = scope ? translated(scope.name) : t("decidim.scopes.global")
      expect(body).to have_selector("#data_picker-modal .picker-#{where} a", text: scope_name)
      body.find("#data_picker-modal .picker-#{where} a", text: scope_name).click
    end

    def scope_picker_pick_current
      body = find(:xpath, "//body")
      expect(body).to have_selector("#data_picker-modal .picker-footer a[data-picker-choose]")
      body.find("#data_picker-modal .picker-footer a[data-picker-choose]").click
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::ScopesPicker, type: :system
end
