# frozen_string_literal: true

namespace :decidim_participatory_processes do
  desc "Changes active phase automatically in participatory processes"
  task :change_active_phase, [] => :environment do
    Decidim::ParticipatoryProcesses::ChangeActivePhaseJob.perform_later
  end

  desc "DEPRECATED: use change_active_phase"
  task change_active_step: :change_active_phase
end
