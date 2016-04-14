# @package MiGA
# @license Artistic-2.0

require "miga/gui/controller"
require "shoes"
require "shoes/swt"

Shoes::Swt.initialize_backend

class MiGA::GUI::View < Shoes
  
  # Class-level
  url "/",		:index
  url "/blank",		:blank

  $miga_gui_path = File.expand_path("../../../../", __FILE__)

  ##
  # Initialize Shoes with +data+ Hash and contents in +blk+.
  def self.init(data={}, &blk)
    Shoes.app title: "MiGA | Microbial Genomes Atlas",
      width: 750, height: 400, resizable: false, data: data, &blk
  end

  # Instance-level

  ##
  # Controller.
  attr_accessor :c

  ##
  # Open a new window. The new view can inherit a previous MiGA::GUI::Controller
  # +controller+. +blk+ is the code to execute in the new window with two
  # parameters: (1) the Shoes App and (2) the new view.
  def new_window(controller=nil, &blk)
    big_blk = proc do |nv|
      nv.c = controller.nil? ? MiGA::GUI::Controller.new(nv) : controller
      blk[nv.app, nv]
    end
    MiGA::GUI::View.init(blk: big_blk) { visit "/blank" }
  end

  ##
  # Glorious blank window.
  def blank
    data = app.gui.dsl.opts[:data]
    @c = data[:controller] unless data[:controller].nil?
    data[:blk][self] unless data[:blk].nil?
  end
  
  ##
  # Initial screen.
  def index
    @c = MiGA::GUI::Controller.new(self)
    header("Microbial Genomes Atlas")
    stack(margin:40) do
      menu_bar [:open_project, :new_project, :help]
      box alpha: 0.0 do
        para "Welcome to the MiGA GUI. If you use MiGA in your research, ",
          "please consider citing:\n", MiGA::MiGA.CITATION
      end
    end
    status_bar "Microbial Genomes Atlas"
  end

  ##
  # Project window.
  def project
    header "\xC2\xBB #{c.project.name.unmiga_name}"
    stack(margin:40) do
      menu_bar [:list_datasets, :new_dataset, :progress_report, :help]
      stack(margin_top:10) do
        para strong("Path"), ": ", c.project.path
        para strong("Datasets"), ": ", c.project.metadata[:datasets].size
        c.project.metadata.each do |k,v|
          para(strong(k.to_s.capitalize), ": ", v) unless k==:datasets
        end
      end
    end
  end

  ##
  # Datasets list window.
  def datasets
    header "\xC2\xBB #{c.project.name.unmiga_name}"
    stack(margin:40, margin_top:10) do
      subtitle "#{c.project.metadata[:datasets].size} datasets:"
      para ""
      flow(width: 1.0) do
        c.project.metadata[:datasets].each do |name|
          stack(width:160, margin:2) do
	    background miga_blue(0.25)
            para link(name.unmiga_name){ c.show_dataset(name) }, margin:5
          end
        end
      end
    end
  end

  ##
  # Dataset details window.
  def dataset(name)
    header("\xC2\xBB " + c.project.name.unmiga_name +
      " \xC2\xBB " + name.unmiga_name)
    stack(margin:40) do
      ds = c.project.dataset(name)
      stack do
        ds.metadata.each { |k,v| para strong(k.to_s.capitalize), ": ", v }
      end
      flow(margin_top:10) do
        w = 40+30*MiGA::Dataset.PREPROCESSING_TASKS.size
        stack(width:w) do
          subtitle "Advance"
          done = graphic_advance(ds)
          para sprintf("%.1f%% Complete", done*100)
        end
        stack(width:-w) do
          subtitle "Task"
          @task_name_field = stack { para "" }
          animate do
            @task_name_field.clear{ para @task }
          end
        end
      end
    end
  end

  ##
  # Project report window.
  def report
    header("\xC2\xBB " + c.project.name.unmiga_name)
    stack(margin:40) do
      @done_para = subtitle "Dataset tasks advance: "
      @done = 0.0
      w = 40+30*MiGA::Dataset.PREPROCESSING_TASKS.size
      stack(width:w) do
        stack(margin_top:10) do
          @done = c.project.datasets.map{|ds| graphic_advance(ds,7)}.inject(:+)
          motion { |_,y| show_report_hover(w, y) }
          click { c.show_dataset(@dataset) }
        end
        @done /= c.project.metadata[:datasets].size
        @done_para.text += sprintf("%.1f%% Complete.", @done*100)
      end
      @task_ds_box = stack(width:-w)
      stack(margin_top:10) do
        subtitle "Project-wide tasks:"
        tasks = MiGA::Project.DISTANCE_TASKS
        tasks += MiGA::Project.INCLADE_TASK if c.project.metadata[:type]==:clade
        tasks.each do |t|
          para strong(t), ": ",
            (c.project.add_result(t, false).nil? ? "Pending" : "Done")
        end
      end if @done==1.0
    end
  end

  private
    
    #==> Graphical elements
    
    ##
    # Header with the MiGA logo.
    def header(msg)
      flow(margin:[40,10,40,0]) do
	image $miga_gui_path + "/img/MiGA-sm.png", width: 120, height: 50
	title msg, margin_top: 6, margin_left: 6
      end
    end
    
    ##
    # Menu bar.
    def menu_bar actions
      box do
        flow do
          img = {
            open_project: "iconmonstr-archive-5-icon-40",
            new_project: "iconmonstr-plus-5-icon-40",
            list_datasets: "iconmonstr-note-10-icon-40",
            new_dataset: "iconmonstr-note-25-icon-40",
            progress_report: "iconmonstr-bar-chart-2-icon-40",
            help: "iconmonstr-help-3-icon-40"}
          actions.each do |k|
            flow(margin:0, width:200) do
              image $miga_gui_path + "/img/#{img[k]}.png", margin: 2
              button(k.to_s.unmiga_name.capitalize, top:5){ c.send(k) }
            end
          end
        end
      end
    end

    ##
    # Status bar.
    def status_bar(*msg)
      stack(bottom:0) do
        flow bottom:0, height:20, margin:0 do
          background "#CCC"
          stack(width:-300, height:1.0, margin_left:45) do
	    inscription *msg, margin:5
	  end
          stack(width:250, height:1.0, right: 5) do
            inscription MiGA::MiGA.LONG_VERSION, align:"right", margin:5
          end
        end
        image "#{$miga_gui_path}/img/MiGA-sq.png",
          left:10, bottom:5, width:30, height:32
      end
    end

    ##
    # Display processing status of a dataset +ds+ as a horizontal bar of height
    # +h+, as reported by MiGA::Dataset#profile_advance.
    def graphic_advance(ds, h=10)
      ds_adv = ds.profile_advance
      flow(width:30*MiGA::Dataset.PREPROCESSING_TASKS.size) do
        nostroke
        col = ["#CCC", rgb(119,130,61), rgb(160,41,50)]
        ds_adv.each_index do |i|
          stack(width:28,margin:0,top:0,left:i*30,height:h) do
            background col[ ds_adv[i] ]
            t = MiGA::Dataset.PREPROCESSING_TASKS[i]
            hover do
              @task = t
              @dataset = ds.name.unmiga_name
            end
            leave do
              @task = nil
              @dataset = nil
              @task_ds_box.hide unless @task_ds_box.nil?
            end
          end
        end
        nofill
      end
      return 0.0 if ds_adv.count{|i| i>0} <= 1
      (ds_adv.count{|i| i==1}.to_f - 1.0)/(ds_adv.count{|i| i>0}.to_f - 1.0)
    end

    #==> Helpers

    ##
    # The MiGA GUI's blue.
    def miga_blue(alpha=1.0)
      rgb(0,121,166,alpha)
    end

    ##
    # The MIGA GUI's red.
    def miga_red(alpha=1.0)
      rgb(179,0,3,alpha)
    end  

    ##
    # General-purpose box
    def box(opts={}, &blk)
      flow(margin_bottom:5) do
        opts[:alpha] ||= 0.2
        opts[:side_line] ||= miga_blue
        opts[:background] ||= miga_blue(opts[:alpha])
        stack(width: 5, height: 1.0) do
          background opts[:side_line]
        end unless opts[:right]
        stack(width: -5) do
          background opts[:background]
          stack{ background rgb(0,0,0,1.0) } # workaround to shoes/shoes4#1190
          s = stack(margin:5, &blk)
          unless opts[:click].nil?
            s.click{ visit opts[:click] }
          end
        end
        stack(width: 5, height: 1.0) do
          background opts[:side_line]
        end if opts[:right]
      end
    end

    ##
    # Show floating window with additional information on report cells.
    def show_report_hover(w, y)
      unless @task.nil?
        @task_ds_box.clear do
          para strong("Task: "), @task, "\n", strong("Dataset: "), @dataset
        end
        @task_ds_box.show
        @task_ds_box.move(w-20, y-115)
      end
    end
    
end

