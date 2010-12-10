class ScoresController < ApplicationController
  # GET /scores
  # GET /scores.xml
  def index
    @scores = Score.find(:all, :order => :date)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scores }
    end
  end
end
