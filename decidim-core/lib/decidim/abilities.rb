# frozen_string_literal: true

module Decidim
  module Abilities
    autoload :AdminUser, "decidim/abilities/admin_user"
    autoload :ParticipatoryProcessRoleUser, "decidim/abilities/participatory_process_role_user"
    autoload :ParticipatoryProcessAdminUser, "decidim/abilities/participatory_process_admin_user"
    autoload :ParticipatoryProcessCollaboratorUser, "decidim/abilities/participatory_process_collaborator_user"
  end
end
