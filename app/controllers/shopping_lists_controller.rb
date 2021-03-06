class ShoppingListsController < ApplicationController
  before_action :set_shopping_list, only: %i[show edit update destroy]
  before_action :check_email_selection, only: %i[create update]
  # GET /shopping_lists or /shopping_lists.json
  def index
    @shopping_lists = ShoppingList.all
  end

  # GET /shopping_lists/1 or /shopping_lists/1.json
  def show
    @shopping_list_products = ShoppingListProduct.where(shopping_list_id: @shopping_list)
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=#{file_name}.xlsx"
      }
      format.html
      format.csv {
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=#{file_name}.csv"
      }
      format.pdf {
        pdf = ShoppingListPdf.new(@shopping_list)
        send_data pdf.render, filename: "#{file_name}",
                              type: 'application/pdf',
                              disposition: 'inline'
      }
    end
  end

  # GET /shopping_lists/new
  def new
    @shopping_list = ShoppingList.new
    @shopping_list.shopping_list_products.build
    @shopping_list_product = ShoppingListProduct.new
    @shopping_list.build_shopping_list_email
    @shopping_list_email = ShoppingListEmail.new
  end

  # GET /shopping_lists/1/edit
  def edit
    @shopping_list_product = ShoppingListProduct.new
    @shopping_list_email = ShoppingListEmail.new
  end

  # POST /shopping_lists or /shopping_lists.json
  def create
    @shopping_list = ShoppingList.new(shopping_list_params)

    respond_to do |format|
      if @shopping_list.save
        format.html { redirect_to shopping_list_url(@shopping_list), notice: 'Shopping list was successfully created.' }
        format.json { render :show, status: :created, location: @shopping_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shopping_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shopping_lists/1 or /shopping_lists/1.json
  def update
    respond_to do |format|
      if @shopping_list.update(shopping_list_params)
        format.html { redirect_to shopping_list_url(@shopping_list), notice: 'Shopping list was successfully updated.' }
        format.json { render :show, status: :ok, location: @shopping_list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @shopping_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shopping_lists/1 or /shopping_lists/1.json
  def destroy
    @shopping_list.destroy

    respond_to do |format|
      format.html { redirect_to shopping_lists_url, notice: 'Shopping list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def send_email_now
    @shopping_list = ShoppingList.find(params[:format])
    ShoppingListMailer.with(shopping_list: @shopping_list).shopping_list_email.deliver_now
    redirect_to shopping_list_url(@shopping_list), notice: 'Shopping list was send.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_shopping_list
    @shopping_list = ShoppingList.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def shopping_list_params
    params.require(:shopping_list).permit(:name, :shopping_day, :status, :send_email,
                                          shopping_list_products_attributes:
                                            %i[id shopping_list_id product_id quantity _destroy],
                                          shopping_list_email_attributes:
                                            %i[id shopping_list_id send_date file_format recipient was_send _destroy])
  end

  def check_email_selection
    if params.dig(:shopping_list, :send_email) == "0"
      params[:shopping_list].delete :shopping_list_email_attributes
    end
  end
end
