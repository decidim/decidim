# frozen_string_literal: true

shared_examples "having a rich text editor for field" do |selector, toolbar|
  it "has a rich text editor" do
    within selector do
      expect(page).to have_css("div.editor-container[data-toolbar='#{toolbar}']", visible: :all)
    end
  end
end

shared_examples "having a rich text editor" do |css, toolbar|
  it_behaves_like "having a rich text editor for field", "form.#{css}", toolbar
end

shared_context "with rich text editor content" do
  let(:content) { "<p>#{safe_tags}</p>#{script}" }
  let(:safe_tags) { em + u + strong }
  let(:em) { "<em>em</em>" }
  let(:u) { "<u>u</u>" }
  let(:strong) { "<strong>strong</strong>" }
  let(:script) { "<script>alert('SCRIPT')</script>" }
end

shared_examples "rendering safe content" do |css|
  include_context "with rich text editor content"

  it "renders potentially safe HTML tags unescaped" do
    within css do
      expect(page).to have_css("em", text: "em")
      expect(page).to have_css("u", text: "u")
      expect(page).to have_css("strong", text: "strong")
    end
  end

  it "sanitizes potentially malicious HTML tags" do
    within css do
      expect(page).to have_no_css("script", visible: :all)
      expect(page).to have_content("alert('SCRIPT')")
    end
  end
end

shared_examples "rendering unsafe content" do |css|
  include_context "with rich text editor content"

  it "sanitizes potentially safe HTML tags" do
    within css do
      expect(page).to have_no_css("em")
      expect(page).to have_content("em")
      expect(page).to have_no_css("u")
      expect(page).to have_content("u")
      expect(page).to have_no_css("strong")
      expect(page).to have_content("strong")
    end
  end

  it "strips potentially malicious HTML tags" do
    within css do
      expect(page).to have_no_css("script", visible: :all)
      expect(page).to have_no_content("alert('SCRIPT')")
    end
  end
end
