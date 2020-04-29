# frozen_string_literal: true

require_relative "capybara_data_picker"

module Capybara
  module ProposalsPicker
    include DataPicker

    RSpec::Matchers.define :have_data_picked do |expected, text|
      match do |data_picker|
        data_picker_elem = data_picker.data_picker
        expect(data_picker_elem).to have_selector(".picker-values div input[value='#{expected&.id || data_picker.global_value}']", visible: false)
        expect(data_picker_elem).to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,'#{text}')]]")
      end
    end

    def proposal_pick(proposal_picker, proposal)
      data_picker = proposal_picker.data_picker
      # use scope_repick to change single scope picker selected scope
      expect(data_picker).to have_selector(".picker-values:empty", visible: false) if data_picker.has_css?(".picker-single")

      expect(data_picker).to have_selector(".picker-prompt")
      data_picker.find(".picker-prompt").click

      proposal_picker_search_perform(proposal.title)
      proposal_picker_search_choose_result(proposal.id)
      data_picker_pick_current

      expect(proposal_picker).to have_data_picked(proposal, proposal.title)
    end

    private

    def proposal_picker_search_perform(term)
      body = find(:xpath, "//body")
      input_selector = "#data_picker-modal .picker-content input#data_picker-autocomplete"
      expect(body).to have_selector(input_selector)
      body.find("#data_picker-modal .picker-content").fill_in("data_picker-autocomplete", with: term)
    end

    def proposal_picker_search_choose_result(proposal_id)
      body = find(:xpath, "//body")
      expect(body).to have_selector(".autocomplete-suggestions .autocomplete-suggestion")
      body.find(".autocomplete-suggestions div.autocomplete-suggestion[data-model-id='#{proposal_id}']").click
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::ProposalsPicker, type: :system
end
