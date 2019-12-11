class Response < ApplicationRecord
  belongs_to :vote
  belongs_to :question

  self.columns.select{ |col| [:text, :string].include? col.type }.each do |col|
    validates_length_of col.name, maximum: col.limit, too_long: "#{ col.name.upcase } too long (#{ col.limit } character max)"
  end

  attr_accessor :choices

  before_save :set_choices

  def set_choices
    if self.frst_choice == "write_in"
      self.frst_choice = self.write_in
    end
  end
end
