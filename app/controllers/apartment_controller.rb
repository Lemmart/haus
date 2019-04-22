class ApartmentController < ApplicationController
  # GET /apartments
  # GET /apartments.json
  def index
    # @user = current_user
    puts make_post_req
    @apartments = Apartment.all.order('created_at DESC')
  end

  # GET /apartments/1
  # GET /apartments/1.json
  def show
    # @user = current_user
    @apartment 
  end

  # GET /apartments/new
  def new
    @apartment = Apartment.new
  end

  # GET /apartments/1/edit
  def edit
    set_apartment
  end

  # apartment /apartments
  # apartment /apartments.json
  def create
    # @user = current_user
    @apartment = Apartment.new(create_update_params)
    # @apartment.user = current_user
    respond_to do |format|
      if @apartment.save
        format.html { redirect_to apartments_path, notice: 'Apartment was successfully created.' }
        format.json { render :show, status: :created, location: @apartment }
      else
        format.html { render :new }
        format.json { render json: @apartment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apartments/1
  # PATCH/PUT /apartments/1.json
  def update
    # @user = current_user
    # @apartment.user = current_user

    respond_to do |format|
      if @apartment.update(create_update_params)
        format.html { redirect_to @apartment, notice: 'Apartment was successfully updated.' }
        format.json { render :show, status: :ok, location: @apartment }
      else
        format.html { render :edit }
        format.json { render json: @apartment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apartments/1
  # DELETE /apartments/1.json
  def destroy
    @apartment.destroy
    respond_to do |format|
      format.html { redirect_to apartments_url, notice: 'Apartment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_apartment
      p = params.require(:apartment).permit(:id)
      @apartment = Apartment.find(p[:id])
    end

    def create_update_params
      params.require(:apartment).permit(:name, :address, :type, :price, :sq_ft, :unit_num, :bed_bath)
    end

    def make_post_req
      # puts("HERE")
      require 'net/http'
      # require 'json'
      begin
        url = URI.parse('http://www.example.com/index.html')
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.request(req)
        }
        return res.body
      rescue => e
          puts "failed #{e}"
      end
    end
end
