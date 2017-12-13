# frozen_string_literal: true

module Capybara
  module ScopesPicker
    def scope_pick(scope, from:, global_id: "")
      data_picker = data_picker_find(from)

      # use scope_repick to change single scope picker selected scope
      expect(data_picker).to have_selector(".picker-values:empty", visible: false) if data_picker.has_css?(".picker-single")

      expect(data_picker).to have_selector(".picker-prompt")
      data_picker.find(".picker-prompt").click

      data_picker_browse_scopes(scope.part_of_scopes) if scope
      data_picker_pick_current

      data_picker_expect_scope_picked(data_picker, scope, global_id: global_id)
    end

    def scope_repick(old_scope, new_scope, from:, global_id: "")
      data_picker = data_picker_find(from)

      expect(data_picker).to have_selector(".picker-values div input[value='#{old_scope&.id || global_id}']", visible: false)
      data_picker.find(:xpath, "//div[contains(@class,'picker-values')]/div/input[@value='#{old_scope&.id || global_id}']/..").click

      # browse to lowest common parent between old and new scope
      parent_scope = (old_scope.part_of_scopes & new_scope.part_of_scopes).last

      data_picker_browse_scope(parent_scope, back: true)
      data_picker_browse_scopes(new_scope.part_of_scopes - old_scope.part_of_scopes)
      data_picker_pick_current

      data_picker_expect_scope_picked(data_picker, new_scope, global_id: global_id)
    end

    def scope_unpick(scope, from:, global_id: "")
      data_picker = data_picker_find(from, multiple: true)

      expect(data_picker).to have_selector(".picker-values div input[value='#{scope&.id || global_id}']", visible: false)
      data_picker.find(".picker-values div input[value='#{scope&.id || global_id}']").click

      data_picker_expect_scope_not_picked(data_picker, scope, global_id: global_id)
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

    def data_picker_expect_scope_not_picked(data_picker, scope, global_id: "")
      data_picker_expect_scope_picked(data_picker, scope, inverse: true, global_id: global_id)
    end

    def data_picker_expect_scope_picked(data_picker, scope, inverse: false, global_id: "")
      scope_name = scope ? translated(scope.name) : I18n.t("decidim.scopes.global")
      if inverse
        expect(data_picker).not_to have_selector(".picker-values div input[value='#{scope&.id || global_id}']", visible: false)
        expect(data_picker).not_to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,'#{scope_name}')]]")
      else
        expect(data_picker).to have_selector(".picker-values div input[value='#{scope&.id || global_id}']", visible: false)
        expect(data_picker).to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,'#{scope_name}')]]")
      end
    end

    def data_picker_browse_scopes(scopes)
      scopes.each do |scope|
        data_picker_browse_scope(scope)
      end
    end

    def data_picker_browse_scope(scope, back: false)
      body = find(:xpath, "//body")
      where = back ? "header" : "content"
      scope_name = scope ? translated(scope.name) : I18n.t("decidim.scopes.global")
      expect(body).to have_selector("#data_picker-modal .picker-#{where} a", text: scope_name)
      body.find("#data_picker-modal .picker-#{where} a", text: scope_name).click
    end

    def data_picker_pick_current
      body = find(:xpath, "//body")
      expect(body).to have_selector("#data_picker-modal .picker-footer a[data-picker-choose]")
      body.find("#data_picker-modal .picker-footer a[data-picker-choose]").click
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::ScopesPicker, type: :feature
end
