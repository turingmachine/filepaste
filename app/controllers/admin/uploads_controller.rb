class Admin::UploadsController < ApplicationController
  before_filter :authenticate

  def authenticate
    authenticate_or_request_with_http_basic do |name, pass|
      name == 'test' && pass == 'nopass'
    end
  end

# GET /uploads
  # GET /uploads.xml
  def index
    @uploads = Upload.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @uploads }
    end
  end

end
