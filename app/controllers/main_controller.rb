class MainController < ApplicationController
  
  def index
    @landmarks = Districts.landmarks
  end
  
end
