# frozen_string_literal: true

describe "Icon showcase sanity" do
  let(:showcase) { "decidim_app-design/app/views/admin/icon-showcase.html.erb" }
  let(:svg) { "decidim_app-design/app/assets/images/icons.svg" }

  it "is syncronized" do
    expect(line_count(showcase)).to eq(line_count(svg))
  end

  private

  def line_count(file)
    File.readlines(file).count
  end
end
