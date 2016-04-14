# @package MiGA
# @license Artistic-2.0

require "miga/gui/view"

##
# Graphical User Interface for MiGA using Shoes.
class MiGA::GUI

  ##
  # Intitialize an abstract MVC architecture.
  def self.init ; MiGA::GUI::View.init ; end
  
end
