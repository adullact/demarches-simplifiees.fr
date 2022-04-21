module FranceConnectHelper
  def france_connect_enabled?(procedure: nil)
    return false if !Flipper.enabled?(:france_connect, current_user)

    fcp_secrets = Rails.application.secrets.france_connect_particulier

    procedure&.fc_particulier_validated? || fcp_secrets[:identifier].present? && fcp_secrets[:secret].present?
  end
end
