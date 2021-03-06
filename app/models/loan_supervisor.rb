class LoanSupervisor < Role::ProjectRole
  has_many :loans_as_supervisor, through: :loans, source: :supervisor_person_id
  has_many :loaned_collection_objects, through: :loan_items, source: :collection_object

  def self.human_name
    'Loan supervisor'
  end
end