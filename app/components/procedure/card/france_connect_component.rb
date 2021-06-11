class Procedure::Card::FranceConnectComponent < ApplicationComponent
  def initialize(procedure:)
    @procedure = procedure
  end

  private

  def render?
    @procedure.feature_enabled?(:france_connect)
  end

  def fc_particulier_validated?
    @procedure.fc_particulier_validated?
  end
end
