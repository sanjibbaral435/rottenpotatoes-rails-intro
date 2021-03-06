class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @order_by = params[:sort] # get the sort key
    
    @all_ratings = Movie.uniq.pluck(:rating) # extract the ratings
    
    @ratings = params[:ratings]
    if @ratings == nil
      if session[:ratings] != nil
        params[:ratings] = session[:ratings]
        return redirect_to params: params
      end
      @ratings = {}
      @all_ratings.each {|key| @ratings[key] = "1"}
    else 
      session[:ratings] = @ratings
    end

    if @ratings.length > 0
      @movies = @movies.where(:rating => @ratings.keys)
    end
   
    if @order_by == nil
      if session[:sort] != nil
        params[:sort] = session[:sort]
        return redirect_to params: params
      end
    else
      session[:sort] = @order_by
    end

    @movies = @movies.order(@order_by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end