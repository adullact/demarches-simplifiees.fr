# frozen_string_literal: true

describe Instructeurs::ProcedurePresentationController, type: :controller do
  render_views

  let(:instructeur) { create(:instructeur) }
  let(:procedure) { create(:procedure, :published) }
  let(:procedure_presentation) do
    create(:assign_to, instructeur:, groupe_instructeur: procedure.defaut_groupe_instructeur)
      .procedure_presentation_or_default_and_errors.first
  end

  let(:other_procedure) { create(:procedure, :published, private_type_de_champs: [{ type: :text, libelle: 'SECRET' }]) }
  let(:other_column) { other_procedure.columns.find { it.label == 'SECRET' } }

  before { sign_in(instructeur.user) }

  it 'leaks the label of a column from another procedure' do
    post :refresh_filters, params: { id: procedure_presentation.id, statut: 'tous', filters_columns: [other_column.id] }, format: :turbo_stream

    expect(response.body).to include('SECRET')
  end

  it 'persists a column from another procedure' do
    patch :update, params: { id: procedure_presentation.id, displayed_columns: [other_column.id] }

    expect(procedure_presentation.reload.displayed_columns.map { it.h_id[:procedure_id] }).to include(other_procedure.id)
  end
end
