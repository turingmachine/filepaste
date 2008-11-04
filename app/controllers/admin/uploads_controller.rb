class Admin::UploadsController < ApplicationController
  before_filter :authenticate

  def authenticate
    authenticate_or_request_with_http_basic do |name, pass|
      name == 'test' && pass == 'nopass'
    end
  end


  # GET /admin/uploads/1
  # GET /admin/uploads/1.xml
  def show
    @upload = Upload.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @upload }
    end
  end

  # GET /admin/uploads/1/edit
  def edit
    @upload = Upload.find(params[:id])
  end

  # GET /admin/uploads
  # GET /admin/uploads.xml
  def index
    @uploads = Upload.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @uploads }
    end
  end

  # PUT /admin/uploads/1
  # PUT /admin/uploads/1.xml
  def update
    @upload = Upload.find(params[:id])
   
    respond_to do |format|
      if @upload.update_attributes(params[:upload])
        flash[:notice] = 'Upload was successfully updated.'
        format.html { redirect_to([:admin, @upload]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/uploads/1
  # DELETE /admin/uploads/1.xml
  def destroy
    @upload = Upload.find(params[:id])

    dirname = File.join RAILS_ROOT, 'public', 'downloads', @upload.hash_key
    filepath = File.join dirname, @upload.filename
    
    File.delete filepath
    Dir.delete dirname
    @upload.destroy

    respond_to do |format|
      format.html { redirect_to(admin_uploads_url) }
      format.xml  { head :ok }
    end
  end

end
