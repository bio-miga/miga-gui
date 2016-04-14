# @package MiGA
# @license Artistic-2.0


class MiGA::GUI::Model < MiGA::MiGA
  
  # Instance-level

  ##
  # MiGA::Project loaded
  attr_reader :project
  # MiGA::Dataset loaded
  attr_reader :dataset

  ##
  # Initialize empty model
  def initialize
    @project = nil
    @dataset = nil
  end

  
  

end
