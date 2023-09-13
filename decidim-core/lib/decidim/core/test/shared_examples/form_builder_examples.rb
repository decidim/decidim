# frozen_string_literal: true

shared_examples_for "having a help text" do
  it "renders the help text" do
    expect(parsed.css("span.help-text")).not_to be_empty
  end

  it "renders the help text before the field" do
    expect(parsed.to_s.index("help-text")).to be < parsed.to_s.index(field)
  end

  it "renders the help text text only once" do
    expect(parsed.to_s.scan(/#{help_text_text}/).size).to eq 1
  end
end
