# frozen_string_literal: true

require "decidim/core/test/shared_examples/download_open_data_shared_context"

RSpec.shared_examples "includes it in the open data file" do
  include_context "when downloading open data files"

  it do
    download_open_data_file
    content = extract_content_from_zip(download_path, file_name)
    expect(content).to include(participatory_space_title)
  end
end

RSpec.shared_examples "does not include it in the open data file" do
  include_context "when downloading open data files"

  it do
    download_open_data_file
    content = extract_content_from_zip(download_path, file_name)
    expect(content).not_to include(participatory_space_title)
  end
end
