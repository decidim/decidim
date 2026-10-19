#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

RENAMES = {
  "participatory_process_steps" => "participatory_process_phases",
  "participatory_process_step" => "participatory_process_phase",
  "ParticipatoryProcessStep" => "ParticipatoryProcessPhase",
  "with_steps" => "with_phases",
  "step_settings" => "phase_settings",
  "import_steps" => "import_phases",
  "duplicate_steps" => "duplicate_phases",
  "#steps" => "#phases",
  ":steps" => ":phases",
  ":step" => ":phase",
  "#step" => "#phase",
  "active_step" => "active_phase",
  "active_step_id" => "active_phase_id",
  "active_step_name" => "active_phase_name",
  "display_steps" => "display_phases",
  "default_step_settings" => "default_phase_settings",
  "default_step" => "default_phase",
  "default_phase_settings=" => "default_phase_settings=",
  "allows_steps?" => "allows_phases?"
}.freeze

def excluded?(file)
  return true if file.start_with?(".github/")
  return true if file.include?("/.github/")
  return true if file.start_with?("docs/")
  return true if file.include?("/docs/")
  return true if file.include?("node_modules/")
  return true if file.include?("spec/decidim_dummy_app/")
  return true if file.end_with?(".txt", ".md", ".adoc")
  return true if file.include?("package-lock.json")
  return true if file == "rename.rb"
  return true if file =~ %r{/db/migrate/}
  return true if file =~ %r{/db/data/}

  return true if (file =~ %r{/config/locales/.*\.yml$}) && !file.end_with?("en.yml")

  false
end

def tracked_files
  `git ls-files`.split("\n")
end

def rename_files(files)
  files.each do |file|
    next if excluded?(file)

    new_file = file.dup
    RENAMES.each do |old, new|
      new_file = new_file.gsub(%r{(?<=/|^|\b)#{Regexp.escape(old)}(?=\b|/|\.)}i) do |match|
        match.match?(/\A[A-Z]/) ? new.capitalize : new
      end
    end

    next if new_file == file

    FileUtils.mkdir_p(File.dirname(new_file))
    FileUtils.mv(file, new_file)
    puts "Renamed: #{file} -> #{new_file}"
  end
end

def replace_strings(files)
  files.each do |file|
    next if excluded?(file)
    next unless File.file?(file)

    begin
      content = File.read(file)
    rescue StandardError
      next
    end

    new_content = content.dup
    RENAMES.each do |old, new|
      new_content = new_content.gsub(old, new)
    end

    if new_content != content
      File.write(file, new_content)
      puts "Updated: #{file}"
    end
  end
end
all_files = tracked_files
rename_files(all_files)
replace_strings(tracked_files)
rename_files(all_files)
