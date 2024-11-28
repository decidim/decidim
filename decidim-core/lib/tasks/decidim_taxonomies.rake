# frozen_string_literal: true

require "decidim/maintenance"

namespace :decidim do
  namespace :taxonomies do
    desc "Creates a JSON file with the taxonomies structure imported from older models"
    task :make_plan, [] => :environment do |_task, _args|
      Decidim::Organization.find_each do |organization|
        puts "Creating a plan for organization #{organization.id} in #{plan_file_path(organization)}"
        FileUtils.mkdir_p(Rails.root.join("tmp/taxonomies"))
        json = planner(organization).to_json do |model|
          puts "...Exporting taxonomies for #{model.table_name}"
        end
        File.write(plan_file_path(organization), json)
        puts "Plan created, you can review or edit if needed before importing."
        puts "Import the plan with this command:"
        puts "bin/rails decidim:taxonomies:import_plan[#{plan_file_path(organization)}]"
        puts
      end
    end

    desc "Imports taxonomies and filters structure from a JSON file"
    task :import_plan, [:file] => :environment do |_task, args|
      file = args[:file].to_s
      abort "File not found! [#{file}]" unless File.exist?(file)

      data = JSON.parse(File.read(file))
      organization = Decidim::Organization.find_by(id: data.dig("organization", "id"))
      abort "Organization not found! [#{data["organization"]}]" unless organization
      puts "Importing taxonomies and filters for organization #{organization.id}"

      planner(organization).import(data) do |importer, model_name|
        taxonomies = importer.roots
        result = importer.result
        puts "...Importing #{taxonomies.count} root taxonomies from #{model_name}"
        taxonomies.each do |name, taxonomy|
          puts "  - Root taxonomy: #{name}"
          puts "    1st level taxonomies: #{taxonomy["taxonomies"].count}"
          puts "    Filters: #{taxonomy["filters"].count}"
          taxonomy["filters"].each do |filter|
            puts "      - Filter name: #{filter["name"]}"
            puts "        Internal name: #{filter["internal_name"] || "-"}"
            puts "        Manifest: #{filter["space_manifest"]}"
            puts "        Space filter: #{filter["space_filter"]}"
            puts "        Items: #{filter["items"].count}"
            puts "        Components: #{filter["components"].count}"
          end
        end
        importer.import! do |type, detail|
          puts "    !#{type}: #{detail}"
        end
        puts "    Created taxonomies: #{result[:taxonomies_created].count}"
        result[:taxonomies_created].each do |name|
          puts "      - #{name}"
        end
        puts "    Created filters: #{result[:filters_created].count}"
        result[:filters_created].each do |name, items|
          puts "      - #{name}: #{items.count} items"
        end
        puts "    Assigned resources: #{result[:taxonomies_assigned].count}"
        result[:taxonomies_assigned].each do |name, items|
          puts "      - #{name}: #{items.count} resources"
        end
        puts "    Assigned components: #{result[:components_assigned].count}"
        result[:components_assigned].each do |name, items|
          puts "      - #{name}: #{items.count} components"
        end
        puts "    Failed resources: #{result[:failed_resources].count}"
        result[:failed_resources].each do |object_id|
          puts "      - #{object_id}"
        end
        puts "    Failed components: #{result[:failed_components].count}"
        result[:failed_components].each do |component_id|
          puts "      - #{component_id}"
        end
        Rails.root.join("tmp/taxonomies", "#{organization.host}_result.json").write(JSON.pretty_generate(result))
        puts "Result saved in tmp/taxonomies/#{organization.host}_result.json"
      end
      puts "Taxonomies and filters imported successfully."
    end

    desc "Imports taxonomies and filters structure from all JSON files inside tmp/taxonomies"
    task :import_all_plans, [] => :environment do |_task, _args|
      Dir[Rails.root.join("tmp/taxonomies/*_plan.json")].each do |file|
        puts "Importing plan from #{file}"
        Rake::Task["decidim:taxonomies:import_plan"].invoke(file)
      end
    end

    desc "Adds taxonomies to metrics from old categories"
    task :update_metrics, [:file] => :environment do |_task, args|
      file = args[:file].to_s
      abort "File not found! [#{file}]" unless File.exist?(file)

      data = JSON.parse(File.read(file))
      taxonomies = data["taxonomy_map"]
      abort "No taxonomies found in the file" unless taxonomies && taxonomies&.any?

      total = taxonomies.count
      taxonomies.each_with_index do |(id, object_id), index|
        next unless object_id.include?("ImportModels::Category")

        category_id = object_id.split("/").last
        percent = ((index + 1) * 100 / total).to_i

        count = Decidim::Metric.where(decidim_category_id: category_id).count
        puts "...#{percent}% Updating #{count} metrics for category #{category_id} to taxonomy #{id}"
        Decidim::Metric.where(decidim_category_id: category_id).update_all(decidim_taxonomy_id: id) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    desc "Processes all metrics for result files in tmp/taxonomies"
    task :update_all_metrics, [] => :environment do |_task, _args|
      Dir[Rails.root.join("tmp/taxonomies/*_result.json")].each do |file|
        puts "Processing metrics from #{file}"
        Rake::Task["decidim:update_metrics"].invoke(file)
      end
    end

    desc "Reset counters for taxonomies and taxonomy filters"
    task :reset_counters, [] => :environment do |_task, _args|
      Decidim::Taxonomy.find_each do |taxonomy|
        taxonomy.reset_all_counters
        puts "Counters reset for taxonomy #{taxonomy.id}:"
        puts "  Children: #{taxonomy.children_count}"
        puts "  Taxonomizations: #{taxonomy.taxonomizations_count}"
        puts "  Filters: #{taxonomy.filters_count}"
        puts "  Filter items: #{taxonomy.filter_items_count}"
      end
      Decidim::TaxonomyFilter.find_each do |filter|
        filter.reset_all_counters
        puts "Counters reset for taxonomy filter #{filter.id}:"
        puts "  Filter items: #{filter.filter_items_count}"
        puts "  Components: #{filter.components_count}"
      end
    end

    def planner(organization)
      models = ENV.fetch("IMPORTS", "ParticipatoryProcessType AssemblyType Scope Area Category").split.map do |model_name|
        "Decidim::Maintenance::ImportModels::#{model_name}".constantize
      end
      Decidim::Maintenance::TaxonomyPlan.new(organization, models)
    end

    def plan_file_path(organization)
      Rails.root.join("tmp/taxonomies", "#{organization.host}_plan.json")
    end
  end
end
