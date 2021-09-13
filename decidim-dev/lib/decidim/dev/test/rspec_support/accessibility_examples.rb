# frozen_string_literal: true

shared_examples_for "accessible page" do
  it "passes accessibility tests" do
    expect(page).to be_axe_clean
  end

  it "passes HTML validation" do
    # Capybara is stripping the doctype out of the HTML which is required for
    # the validation. If it doesn't exist, add it there.
    html = page.source
    html = "<!DOCTYPE html>\n#{html}" unless html.strip.match?(/^<!DOCTYPE/i)

    # This would cause a CSS validation error (added by EmojiPicker). Bug reported in https://github.com/validator/validator/issues/1223.
    html = html.gsub("outline: 1px dotted var(--focus-indicator-color)", "outline: 1px dotted red")

    expect(html).to be_valid_html
  end
end
