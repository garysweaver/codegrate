class DashboardController < ApplicationController
  include OpenFlashChart

  def index
    @graph = Graph.new(data_path, 800, 300, :base_path => '/swf/')
  end

  # http://pullmonkey.com/2010/1/5/open-flash-chart-ii-x-axis-date-and-time/
  def show
    puts "#{Score.find(:all, :order => :date).inspect}"
    
    data1 = []
    data2 = []
    
    if Score.minimum(:date) == nil
      chart = OpenFlashChart.new
      render :text => chart, :layout => false
      return
    end
    
    scores_by_date = Score.find(:all, :order => :date)
    first_score = scores_by_date.first
    last_score = scores_by_date.last
    
    (first_score.date...last_score.date).each do |the_date|
        puts "#{the_date}"
        x = the_date.to_time.to_i
        y = 0
        Score.all.each do |score|
          y = y + score.score if (score.date == the_date)
        end
        #Score.find_by_date(the_date).try(:each) do |score|
        #  y = y + score.score
        #end
        #y = Score.sum(:score, :conditions => ["date = ", the_date])
        data1 << ScatterValue.new(x,y)
        data2 << "what is this?"
    end

    #31.times do |i|
    #  x = "#{year}-1-#{i+1}".to_time.to_i
    #  y = (Math.sin(i+1) * 2.5) + 10
    #  data1 << ScatterValue.new(x,y)
    #  data2 << (Math.cos(i+1) * 1.9) + 4
    #end

    dot = HollowDot.new
    dot.size = 3
    dot.halo_size = 2
    dot.tooltip = "#date:d M y#<br>Value: #val#"

    line = ScatterLine.new("#1D7CF2", 2)
    line.values = data1
    line.default_dot_style = dot

    x = XAxis.new
    #x.set_range("#{year}-1-1".to_time.to_i, "#{year}-1-31".to_time.to_i)
    first_time_int = first_score.date.to_time.to_i
    last_time_int = last_score.date.to_time.to_i
    x.set_range(last_time_int, first_time_int)
    diff_time = last_time_int - first_time_int
    x.steps = 86400

    labels = XAxisLabels.new
    labels.text = "#date: l jS, M Y#"
    #labels.steps = 86400
    labels.steps = diff_time / 10
    labels.visible_steps = 1
    labels.rotate = 90

    x.labels = labels

    max_y = Score.maximum(:score) + 1
    y = YAxis.new
    y.set_range(0,max_y,(max_y/3).to_i)

    chart = OpenFlashChart.new
    title = Title.new(data2.size)

    chart.title = title
    chart.add_element(line)
    chart.x_axis = x
    chart.y_axis = y

    render :text => chart, :layout => false

  end
end
