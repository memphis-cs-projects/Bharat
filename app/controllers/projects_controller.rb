class ProjectsController < ApplicationController
  include Filterable

  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects_created = Project.where('user_id == ?', current_user.id)
    @projects_created = @projects_created.status(Project.statuses[params[:status]]) if params[:status].present?

    @projects_collaborated = Team.where('user_id == ?', current_user.id).pluck(:project_id)
    @projects_collaborated = Project.where(:id => @projects_collaborated)

    @projects_collaborated = @projects_collaborated.status(Project.statuses[params[:status]]) if params[:status].present?

    @projects = (@projects_created + @projects_collaborated).sort_by(&:created_at).reverse!

    @total_projects_count = @projects.length

    @projects = @projects.paginate(:page => params[:page], :per_page => 5)
    @departments = Department.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
    @departments = Department.all
  end

  # GET /projects/1/edit
  def edit
    authorize

    @departments = Department.all
  end

  # POST /projects
  # POST /projects.json
  def create

    @project = Project.new(project_params)
    @project.user_id =  current_user.id
    @departments = Department.all

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    authorize

    @project.user_id =  current_user.id

    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    authorize

    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    @departments = Department.all
    if params[:search] && params[:department][:id]
      @projects_not_created = Project.where('department_id = ? and user_id != ?', params[:department][:id], current_user.id).distinct
      @projects_not_created = @projects_not_created.where('name like ? or description like ?', "%#{params[:search]}%", "%#{params[:search]}%") if params[:search] != ''

      @projects_not_collaborated_ids = Team.where('user_id != ?', current_user.id).distinct.pluck(:project_id)

      @projects_not_collaborated = Project.where(:id => @projects_not_collaborated_ids).where('department_id = ? and user_id != ?', params[:department][:id], current_user.id).distinct
      @projects_not_collaborated = @projects_not_collaborated.where('name like ? or description like ?', "%#{params[:search]}%", "%#{params[:search]}%") if params[:search] != ''

      @projects = (@projects_not_created + @projects_not_collaborated).sort_by(&:created_at).uniq.reverse!
      @total_projects_count = @projects.length
    else
      @projects = nil
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :status, :description, :start_date, :end_date, :funding, :difficulty_level, :user_id, :department_id)
  end

  def authorize
    if current_user != @project.user
      render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
