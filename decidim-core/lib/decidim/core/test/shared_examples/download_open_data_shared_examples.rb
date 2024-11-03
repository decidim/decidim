# frozen_string_literal: true

require "decidim/core/test/shared_examples/download_open_data_shared_context"

RSpec.shared_examples "includes it in the open data ZIP file" do
  include_context "when downloading open data files"

  it do
    download_open_data_file
    content = extract_content_from_zip(download_path, file_name)
    expect(content).to include(resource_title)
  end
end

RSpec.shared_examples "does not include it in the open data ZIP file" do
  include_context "when downloading open data files"

  it do
    download_open_data_file
    content = extract_content_from_zip(download_path, file_name)
    expect(content).not_to include(resource_title)
  end
end

RSpec.shared_examples "includes it in the open data CSV file" do
  def download_open_data_csv_file(resource_type)
    open_data_file = Rails.root.join("tmp/#{organization.open_data_file_path(resource_type)}")
    FileUtils.rm_f(open_data_file)
    Decidim::OpenDataJob.perform_now(organization, resource_type)
  end

  it do
    download_open_data_csv_file(resource_type)

    switch_to_host(organization.host)
    visit decidim.root_path
    click_on "Open Data"

    expect(page).to have_content("What are these files?")
    click_on "Download #{resource_type} in CSV format"

    expect(File.basename(download_path)).to include("#{resource_type}.csv")
    expect(File.read(download_path)).to include(resource_title)
  end
end
