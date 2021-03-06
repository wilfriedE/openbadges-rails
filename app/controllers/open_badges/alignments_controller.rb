require_dependency "open_badges/application_controller"

module OpenBadges
  class AlignmentsController < ApplicationController
    load_and_authorize_resource :class => 'OpenBadges::Alignment'

    # GET /alignments
    def index
      @alignments = Alignment.all
  
      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /alignments/new
    def new
      @alignment = Alignment.new
  
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /alignments/1/edit
    def edit
      @alignment = Alignment.find(params[:id])
    end
  
    # POST /alignments
    def create
      @alignment = Alignment.new(params[:alignment])
  
      respond_to do |format|
        if @alignment.update_attributes(params[:alignment])
          format.html { redirect_to alignments_url, :flash => { :success => 'Alignment was successfully created.' } }
        else
          format.html {
            flash[:error] = @alignment.errors.full_messages
            render action: "new"
          }
        end
      end
    end
  
    # PUT /alignments/1
    def update
      @alignment = Alignment.find(params[:id])
  
      respond_to do |format|
        if @alignment.update_attributes(params[:alignment])
          format.html { redirect_to alignments_url, :flash => { :success => 'Alignment was successfully updated.' } }
        else
          format.html {
            flash[:error] = @alignment.errors.full_messages
            render action: "edit"
          }
        end
      end
    end
  
    # DELETE /alignments/1
    def destroy
      @alignment = Alignment.find(params[:id])
      @alignment.destroy
  
      respond_to do |format|
        format.html { redirect_to alignments_url, :flash => { :success => 'Alignment was successfully deleted.' } }
      end
    end
  end
end
