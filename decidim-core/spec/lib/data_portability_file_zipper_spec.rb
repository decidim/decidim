# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DataPortabilityFileZipper do
    subject { DataPortabilityFileZipper.new(user, data, images) }

    object = "Decidim::DummyResources::DummyResource"
    klass = Object.const_get(object)
    let(:user) { create :user }
    let(:data) { [[klass.model_name.name.parameterize.pluralize, Decidim::Exporters.find_exporter("CSV").new(klass.user_collection(user), klass.export_serializer).export]] }
    let(:images) { [] }

    describe "#make_zip" do
      let(:make_zip) { subject.make_zip }
      let(:token) { SecureRandom.base58(10) }
      let(:file_path) { Decidim::DataPortabilityUploader.new.store_dir + "#{user.nickname}-#{user.organization.name.parameterize}-#{token}.zip" }

      it "zips a file" do
        Zip::InputStream.open(StringIO.new(file_path)) do |io|
          data.each do |element|
            while (entry = io.get_next_entry)
              entries << { name: entry.name, content: entry.get_input_stream.read }
            end
            expect(element.first).to eq("decidim-dummyresources-dummyresources")
          end
        end

        expect(data.length).to eq(1)
      end
    end
  end
end
