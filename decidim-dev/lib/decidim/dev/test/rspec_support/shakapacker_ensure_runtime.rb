# frozen_string_literal: true
 
runtime = Rails.application.root.join("tmp/shakapacker_runtime.yml")
unless File.exist?(runtime) && File.read(runtime).strip != ""
  FileUtils.mkdir_p(File.dirname(runtime))
  File.write(runtime, <<~YAML)
    default:
      source_path: app/packs
      public_output_path: packs-test
      additional_paths: []
    test:
      <<: *default
  YAML
end

