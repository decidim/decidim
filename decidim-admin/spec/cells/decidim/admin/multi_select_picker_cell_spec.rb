# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::MultiSelectPickerCell, type: :cell do
  subject { cell_html.to_s }

  controller Decidim::Admin::NewslettersController

  let(:context) do
    {
      select_id: "test-select",
      field_name: "test_field",
      placeholder: "Choose an option",
      class: "custom-class",
      options_for_select: [["Option 1", 1], ["Option 2", 2]],
      selected_values: [1]
    }
  end

  let(:my_cell) { cell("decidim/admin/multi_select_picker", nil, context:) }
  let(:cell_html) { my_cell.call }

  it "renders a select element with the correct attributes" do
    expect(subject).to include("<select")
    expect(subject).to include('id="test-select"')
    expect(subject).to include('name="test_field[]"')
    expect(subject).to include('placeholder="Choose an option"')
    expect(subject).to include('class="custom-class"')
    expect(subject).to include("multiple")
    expect(subject).to include('multiselect="true"')
  end

  it "renders the correct options" do
    expect(subject).to match(%r{<option (selected )?value="1">Option 1</option>})
    expect(subject).to match(%r{<option value="2">Option 2</option>})
  end

  context "when no options are provided" do
    let(:context) do
      {
        select_id: "test-select",
        field_name: "test_field",
        placeholder: "Choose an option",
        class: "custom-class",
        options_for_select: []
      }
    end

    it "renders an empty select element" do
      expect(subject).to include("<select")
      expect(subject).to include('id="test-select"')
      expect(subject).not_to include("<option")
    end
  end

  context "when selected values are provided" do
    let(:context) do
      {
        select_id: "test-select",
        field_name: "test_field",
        placeholder: "Choose an option",
        class: "custom-class",
        options_for_select: [["Option 1", 1], ["Option 2", 2], ["Option 3", 3]],
        selected_values: [1, 3]
      }
    end

    it "renders the correct options with selected attributes" do
      expect(subject).to match(%r{<option (selected )?value="1">Option 1</option>})
      expect(subject).to match(%r{<option value="2">Option 2</option>})
      expect(subject).to match(%r{<option (selected )?value="3">Option 3</option>})
    end
  end

  context "when a placeholder is provided" do
    let(:context) do
      {
        select_id: "test-select",
        field_name: "test_field",
        placeholder: "Choose an option",
        class: "custom-class",
        options_for_select: []
      }
    end

    it "renders the placeholder in the select element" do
      expect(subject).to include('placeholder="Choose an option"')
    end
  end
end
