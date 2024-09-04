# frozen_string_literal: true

RSpec.shared_context "when downloading open data files" do
  def download_open_data_file
    # Prevent using the same cached file
    open_data_file = Rails.root.join("tmp/#{organization.open_data_file_path}")
    FileUtils.rm_f(open_data_file)
    Decidim::OpenDataJob.perform_now(organization)
    switch_to_host(organization.host)
    visit decidim.root_path

    click_on "Download Open Data files"
  end

  def extract_content_from_zip(download_path, file_name)
    Zip::File.open(download_path) do |zipfile|
      entry = zipfile.select { |an_entry| an_entry.name.match?(/.*#{file_name}/) }.first
      content = entry.get_input_stream.read

      return content
    end
  end
end
