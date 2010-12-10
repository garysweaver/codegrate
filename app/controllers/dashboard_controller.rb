class DashboardController < ApplicationController
  include OpenFlashChart

  def index
    @graph = Graph.new(data_path, 800, 300, :base_path => '/swf/')
  end

  # referenced: http://pullmonkey.com/2010/1/5/open-flash-chart-ii-x-axis-date-and-time/
  def show
    puts "#{Score.find(:all, :order => :date).inspect}"
    
    author_id_to_data = Hash.new(0)
    
    if Score.minimum(:date) == nil
      chart = OpenFlashChart.new
      render :text => chart, :layout => false
      return
    end
    
    scores_by_date = Score.find(:all, :order => :date)
    first_score = scores_by_date.first
    last_score = scores_by_date.last
    
    Author.find(:all).each do |author|
      puts "Handling author #{author.inspect}"
      author_id_to_data[author[:id]] = []
      (first_score.date...last_score.date).each do |the_date|
          puts "#{the_date}"
          x = the_date.to_time.to_i
          y = 0
          Score.find(:all).each do |score|
            puts "Comparing #{score.author_id} to #{author[:id]} and #{score.date} to #{the_date}"
            if ("#{score.author_id}" == "#{author[:id]}") && ("#{score.date}" == "#{the_date}")
              puts "incrementing score"
              y = y + score.score
            end
          end
        
          (author_id_to_data[author.id]) << ScatterValue.new(x,y)
      end
    end
    
    puts "author_id_to_data=#{author_id_to_data.inspect}"
    
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
    title = Title.new("Code Scores")
    chart.title = title
    chart.x_axis = x
    chart.y_axis = y
    
    author_id_to_data.sort.each do |author_id, data|
      
      puts "handling author data #{author_id}. data #{data.inspect}"
      
      author = Author.find(author_id)
      
      dot = HollowDot.new
      dot.size = 3
      dot.halo_size = 2
      #dot.tooltip = "#date:d M y#<br>Value: #val#"
      dot.tooltip = "#{author.name} &lt;#{author.email}&gt;<br>Value: #val#"

      color = "%06x" % (rand * 0xffffff)

      line = ScatterLine.new("##{color}", 2)
      line.values = data
      line.default_dot_style = dot
      
      chart.add_element(line)
    end

    render :text => chart, :layout => false

  end
end
