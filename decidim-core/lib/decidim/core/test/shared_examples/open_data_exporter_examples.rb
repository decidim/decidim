# frozen_string_literal: true

shared_examples_for "default open data exporter" do
  let(:organization) { create(:organization) }
  let(:path) { "/tmp/test-open-data-#{resource_file_name}.zip" }
  let(:zip_contents) { Zip::File.open(path) }

  let(:file_name) { "*open-data-#{resource_file_name}.csv" }
  let(:file) { zip_contents.glob(file_name).first }
  let(:data) { file.get_input_stream.read }

  before do
    subject.export
  end

  it "includes a CSV" do
    expect(file).not_to be_nil
  end

  describe "README content" do
    let(:file_name) { "README.md" }

    it "includes the resource help description" do
      expect(data).to include(resource_title)
      help_lines.each do |line|
        expect(data).to include(line)
      end
    end

    it "does not have any missing translation" do
      expect(data).not_to include("Translation missing")
    end
  end
end

shared_examples_for "open users data exporter" do
  include_examples "default open data exporter"

  it "includes the resource data" do
    expect(data).to include(resource.nickname.gsub("\"", "\"\""))
  end

  context "with unpublished components" do
    it "does not include the resource data" do
      expect(data).not_to include(unpublished_resource.nickname.gsub("\"", "\"\""))
    end
  end
end

shared_examples_for "open moderation data exporter" do
  include_examples "default open data exporter"

  it "includes the resource data" do
    if resource.respond_to?(:reportable)
      expect(data).to include(resource.reportable.reported_content_url.gsub("\"", "\"\""))
    elsif resource.respond_to?(:reported?)
      expect(data).to include(resource.id.to_s)
    else
      raise "Failed to understand the model"
    end
  end

  context "with unpublished components" do
    it "does not include the resource data" do
      if unpublished_resource.respond_to?(:reportable)
        expect(data).not_to include(unpublished_resource.reportable.reported_content_url.gsub("\"", "\"\""))
      elsif unpublished_resource.respond_to?(:reported?)
        expect(data).not_to include(unpublished_resource.id.to_s)
      else
        raise "Failed to understand the model"
      end
    end
  end
end

shared_examples_for "open data exporter" do
  include_examples "default open data exporter"

  it "includes the resource data" do
    if resource.respond_to?(:title)
      expect(data).to include(translated(resource.title).gsub("\"", "\"\""))
    elsif resource.respond_to?(:body)
      # Seems like the comments are always taking the first alphabetical language for the export
      # We should fix it in the future
      expect(data).to include(resource.body.min.second)
    else
      raise "Failed to understand the model"
    end
  end

  context "with unpublished components" do
    it "does not include the resource data" do
      if unpublished_resource.respond_to?(:title)
        expect(data).not_to include(translated(unpublished_resource.title).gsub("\"", "\"\""))
      elsif unpublished_resource.respond_to?(:body)
        expect(data).not_to include(translated(unpublished_resource.body).gsub("\"", "\"\""))
      else
        raise "Failed to understand the model"
      end
    end
  end
end
