# @package MiGA
# @license Artistic-2.0

require "miga/gui/common"
require "miga"

class MiGA::GUI::Controller
  
  # Instance-level

  ##
  # Project model MiGA::Project.
  attr_accessor :project
  # View.
  attr_reader :v

  ##
  # Initialize controller with MiGA::GUI:View +view+.
  def initialize(view)
    @v = view
    set_shortcuts
  end

  ##
  # Set keyboard shortcuts
  def set_shortcuts
    key_shortcuts = {
      :control_o => :open_project,    :super_o => :open_project,
      :control_n => :new_project,     :super_n => :new_project,
      :control_l => :list_datasets,   :super_l => :list_datasets,
      :control_r => :progress_report, :super_r => :progress_report,
      :control_h => :help,            :super_h => :help
    }
    v.keypress do |key|
      funct = key_shortcuts[key]
      send(funct) unless funct.nil?
    end
  end

  ##
  # Open a project.
  def open_project
    v.new_window do |app, nv|
      folder = app.ask_open_folder
      if folder.nil? or not MiGA::Project.exist?(folder)
        app.alert "Cannot find a MiGA project at #{folder}!" unless folder.nil?
        app.close
      else
        nv.c.project = MiGA::Project.new(folder)
        nv.project
      end
    end
  end

  ##
  # Create a project.
  def new_project
    v.new_window do |app, nv|
      if MiGA::MiGA.initialized?
        folder = app.ask_save_folder
        if folder.nil? or MiGA::Project.exist?(folder)
          app.alert "Cannot overwrite MiGA project at #{folder}!" unless
            folder.nil?
          app.close
        else
          nv.c.project = MiGA::Project.new(folder)
          nv.project
        end
      else
        # FIXME Add a way to initialize MiGA from the GUI
        app.alert "MiGA is currently uninitialized, no projects can be created."
      end
    end
  end

  ##
  # List the datasets in a project.
  def list_datasets
    return if project.nil?
    v.new_window(self) { |_, nv| nv.datasets }
  end

  ##
  # Display dataset +name+ details.
  def show_dataset(name)
    return if project.nil?
    v.new_window(self) { |_, nv| nv.dataset(name) }
  end

  ##
  # Generate progress report for a project.
  def progress_report
    return if project.nil?
    v.new_window(self) { |_, nv| nv.report }
  end
  
  ##
  # Query the manual.
  def help
  end

end

