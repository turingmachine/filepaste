class UploadsController < ApplicationController


  # GET /uploads/new
  # GET /uploads/new.xml
  def new
    @upload = Upload.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @upload }
    end
  end

  # POST /uploads
  # POST /uploads.xml
  def create
    datafile = params[:uploads][:file]
   
    # Create a new hash
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    hash_key = ""
    @filepaste_settings['general']['hash_length'].to_i.times do
      hash_key << chars[rand(chars.size)]
    end

    dirname = File.join RAILS_ROOT, 'public', 'downloads', hash_key
    filepath = File.join dirname, datafile.original_filename

    # Now we save the File to the disk
    Dir.mkdir dirname 
    File.open(filepath, "wb") { |file| file.write datafile.read }

    # Save the file information to the database
    @upload = Upload.new
    @upload.filename = datafile.original_filename
    @upload.description = params[:uploads][:description]
    @upload.hash_key = hash_key
    @upload.content_type = datafile.content_type
    @upload.updated_at = Time.now
    @upload.created_at = Time.now

    respond_to do |format|
      if @upload.save
        flash[:notice] = 'Upload was successfully created.'
        format.html { redirect_to( :action => 'downloadinfo', :id => hash_key ) }
        format.xml  { render :xml => @upload, :status => :created, :location => @upload }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end

  def downloadinfo
    @upload = Upload.find(:first, :conditions => [ 'hash_key = ?', params[:id] ])
    flash[:notice] = 'No such file.'
    if @upload.nil?
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end
end
