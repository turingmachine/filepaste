class UploadsController < ApplicationController

  # GET /uploads/1
  # GET /uploads/1.xml
  def show
    @upload = Upload.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @upload }
    end
  end

  # GET /uploads/new
  # GET /uploads/new.xml
  def new
    @upload = Upload.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @upload }
    end
  end

  # GET /uploads/1/edit
  def edit
    @upload = Upload.find(params[:id])
  end

  # POST /uploads
  # POST /uploads.xml
  def create
    datafile = params[:uploads][:file]
   
    # Create a new hash
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    random_hash = ""
    @filepaste_settings['general']['hash_length'].to_i.times do
      random_hash << chars[rand(chars.size)]
    end

    dirname = File.join RAILS_ROOT, 'public', 'downloads', random_hash
    filepath = File.join dirname, datafile.original_filename

    # Now we save the File to the disk
    Dir.mkdir dirname 
    File.open(filepath, "wb") { |file| file.write datafile.read }

    # Save the file information to the database
    @upload = Upload.new
    @upload.filename = datafile.original_filename
    @upload.description = params[:uploads][:description]
    @upload.hash_key = random_hash
    @upload.content_type = datafile.content_type
    @upload.updated_at = Time.now
    @upload.created_at = Time.now

    respond_to do |format|
      if @upload.save
        flash[:notice] = 'Upload was successfully created.'
        format.html { redirect_to(@upload) }
        format.xml  { render :xml => @upload, :status => :created, :location => @upload }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /uploads/1
  # PUT /uploads/1.xml
  def update
    @upload = Upload.find(params[:id])
   
    respond_to do |format|
      if @upload.update_attributes(params[:upload])
        flash[:notice] = 'Upload was successfully updated.'
        format.html { redirect_to(@upload) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.xml
  def destroy
    @upload = Upload.find(params[:id])

    dirname = File.join RAILS_ROOT, 'public', 'downloads', @upload.random_hash
    filepath = File.join dirname, @upload.filename
    
    File.delete filepath
    Dir.delete dirname
    @upload.destroy

    respond_to do |format|
      format.html { redirect_to(uploads_url) }
      format.xml  { head :ok }
    end
  end

end
