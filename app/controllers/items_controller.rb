class ItemsController < ApplicationController
  def index
      @items = Item.where(active: true)

      @popular_items = Item.popular_items(5)
      @popular_merchants = User.popular_merchants(5)
      @fastest_merchants = User.fastest_merchants(3)
      @slowest_merchants = User.slowest_merchants(3)
  end

  def new
    @item = Item.new
    @merchant = User.find(params[:merchant_id])
    @form_url = merchant_items_path
  end

  def show
    @item = Item.slug_find(params[:id])
  end

  def edit
    render file: 'errors/not_found', status: 404 if current_user.nil?
    @merchant = User.find(params[:merchant_id])
    render file: 'errors/not_found', status: 404 unless current_admin? || current_user == @merchant
    @item = Item.slug_find(params[:id])
    @form_url = merchant_item_path(@merchant, @item)
  end

  def create
    render file: 'errors/not_found', status: 404 if current_user.nil?
    @merchant = User.find(params[:merchant_id])
    render file: 'errors/not_found', status: 404 unless current_admin? || current_user == @merchant

    @item = @merchant.items.create(item_params)
    if @item.save
      if @item.image.nil? || @item.image.empty?
        @item.image = 'https://picsum.photos/200/300/?image=0&blur=true'
        @item.save
      end
      flash[:success] = "Item created"
      redirect_to current_admin? ? merchant_items_path(@merchant) : dashboard_items_path
    else
      @form_url = merchant_items_path
      render :new
    end
  end

  def update
    render file: 'errors/not_found', status: 404 if current_user.nil?
    @merchant = User.find(params[:merchant_id])
    item_id = :item_id
    if params[:id]
      item_id = :id
    end
    @item = Item.slug_find(params[item_id])
    render file: 'errors/not_found', status: 404 unless current_admin? || current_user == @merchant

    if request.fullpath.split('/')[-1] == 'disable'
      flash[:success] = "Item #{@item.id} is now disabled"
      @item.active = false
      @item.save
      redirect_to current_admin? ? merchant_items_path(@merchant) : dashboard_items_path
    elsif request.fullpath.split('/')[-1] == 'enable'
      flash[:success] = "Item #{@item.id} is now enabled"
      @item.active = true
      @item.save
      redirect_to current_admin? ? merchant_items_path(@merchant) : dashboard_items_path
    else
      @item.update(item_params)
      if @item.save
        flash[:success] = "Item updated"
        redirect_to current_admin? ? merchant_items_path(@merchant) : dashboard_items_path
      else
        @form_url = merchant_item_path(@merchant, @item)
        render :edit
      end
    end
  end


  private
    def item_params
      params.require(:item).permit(:user_id, :name, :description, :image, :price, :inventory, :slug)
    end
end
