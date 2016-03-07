class Cpanel::NotesController < Cpanel::ApplicationController
  before_filter :require_admin

  def index
    @notes = Note.asc(:name).page(params[:page])
    @note = Note.new
  end

  def show
    @post_candidates = Post.published.limit(30) if (params[:id] == "carousel")
    @asks = Ask.desc(:created_at) if (params[:id] == "asks_list")
    if params[:id]
      render "cpanel/notes/#{params[:id]}"
    else
      redirect_to :index
    end
  end

  def edit
    @notes = Note.asc(:name).page(params[:page])
    @note = Note.find(params[:id])
  end

  def create
    @note = Note.new(params[:note])
    respond_to do |format|
      if @note.save
        expire_cache_for(@note)
        format.html { redirect_to :back, notice: 'Note was successfully created.' }
      else
        format.html { redirect_to :back, notice: 'Note creation failed, have you use duplicated slug?' }
      end
    end
  end

  def update
    @note = Note.find(params[:id])
    respond_to do |format|
      if @note.update_attributes(params[:note])
        expire_cache_for(@note)
        format.html { redirect_to :back, notice: "'#{@note.key}' successfully updated." }
      else
        format.html { redirect_to :back, notice: "'#{@note.key}' value unchanged." }
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    expire_cache_for(@note)
    @note.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: "cache cleared." }
    end
  end
  
  private

  def expire_cache_for(note)
    expire_fragment('wired_home_banner') if note.key.include?("home_carousel") # home carousel articles
    expire_fragment('wired_sidebar') if note.key.include?("RC_") #sidebat recommended reading
  end

end
