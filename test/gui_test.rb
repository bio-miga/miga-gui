require "test_helper"
require "miga/gui"

class GUITest < Test::Unit::TestCase
  
  def test_gui
    assert_respond_to(MiGA::GUI, :init)
  end

end
