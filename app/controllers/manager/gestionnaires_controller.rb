# frozen_string_literal: true

module Manager
  class GestionnairesController < Manager::ApplicationController
    include RequiresFreshSuperAdminOtp

    before_action :verify_fresh_super_admin_otp!, only: [:delete]

    def delete_edit
      @gestionnaire = Gestionnaire.find(params[:id])
    end

    def delete
      gestionnaire = Gestionnaire.find(params[:id])

      if !gestionnaire.can_be_deleted?
        flash[:alert] = "Impossible de supprimer ce gestionnaire car il est gestionnaire d’un groupe racine"
      else
        gestionnaire.destroy!
        logger.info("Le gestionnaire #{gestionnaire.id} est supprimé par #{current_super_admin.id}")
        flash[:notice] = "Le gestionnaire #{gestionnaire.id} est supprimé"
      end

      redirect_to manager_gestionnaires_path
    end
  end
end
