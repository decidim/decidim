# frozen_string_literal: true

shared_examples_for "has embedded video in description" do |description_attribute_name, count: 1|
  let(description_attribute_name) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }
  let(:iframe_src) { "http://www.example.org" }

  it "shows iframe" do
    expect(page).to have_selector("iframe", count: count)
  end
end
