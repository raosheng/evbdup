# -*- encoding : utf-8 -*-
class Kobe::CategoriesController < KobeController

  skip_before_action :verify_authenticity_token, :only => [:move, :valid_name]
  # protect_from_forgery :except => :index
  before_action :get_category, :only => [:index, :edit, :show, :update, :delete, :destroy, :freeze, :update_freeze, :recover, :update_recover]
  layout false, :only => [:edit, :new, :show, :delete, :freeze, :recover]

  # cancancan验证 如果有before_action cancancan放最后
  load_and_authorize_resource 
  skip_authorize_resource :only => [:ztree, :valid_name]

	def index
	end

  def show
    @arr  = []
    obj_contents = show_obj_info(@category, Category.xml)
    if @category.is_childless?
      create_objs_from_xml_model(@category.params_xml, CategoryParams).each_with_index do |param,index|
        obj_contents << show_obj_info(param,CategoryParams.xml,{title: "参数明细 ##{index+1}"})
      end
      
    end
    @arr << {title: "详细信息", icon: "fa-info", content: obj_contents} 
    @arr << {title: "历史记录", icon: "fa-clock-o", content: show_logs(@category)}
  end

  def new
    category = Category.new
    category.parent_id = params[:pid] if params[:pid].present?
    slave_objs = create_objs_from_xml_model(CategoryParams.default_xml, CategoryParams)
    @ms_form = MasterSlaveForm.new(Category.xml, CategoryParams.xml, category, slave_objs, { form_id: 'new_category', title: '<i class="fa fa-pencil-square-o"></i> 新增品目', action: kobe_categories_path, grid: 2 }, { title: '参数明细', grid: 4 })
  end

  def edit
    slave_objs = create_objs_from_xml_model(@category.params_xml, CategoryParams)
    @my_form = MasterSlaveForm.new(Category.xml, CategoryParams.xml, @category, slave_objs, { action: kobe_category_path(@category), method: "patch", grid: 2 }, { title: '参数明细', grid: 4 })
  end

  def create
    category = create_and_write_logs(Category, Category.xml, { :action => "新增品目" }, { "params_xml" => create_xml(CategoryParams.xml, CategoryParams) })
    if category
      redirect_to kobe_categories_path(id: category)
    else
      redirect_back_or      
    end
  end

  def update
    update_and_write_logs(@category, Category.xml, { :action => "修改品目" }, { "params_xml" => create_xml(CategoryParams.xml, CategoryParams) })
    redirect_to kobe_categories_path(id: @category)
  end

  # 删除
  def delete
    render partial: '/shared/dialog/opt_liyou', locals: { form_id: 'delete_category_form', action: kobe_category_path(@category), method: 'delete' } 
  end
  
  def destroy
    if @category.change_status_and_write_logs("已删除", stateless_logs("删除",params[:opt_liyou],false))
      tips_get("删除品目成功。")
    else
      flash_get(@category.errors.full_messages)
    end
    redirect_to kobe_categories_path(id: @category.parent_id)
  end

  # 冻结
  def freeze
    render partial: '/shared/dialog/opt_liyou', locals: { form_id: 'freeze_category_form', action: update_freeze_kobe_category_path(@category) }
  end

  def update_freeze
    if @category.change_status_and_write_logs("冻结", stateless_logs("冻结",params[:opt_liyou],false))
      tips_get("冻结品目成功。")
    else
      flash_get(@category.errors.full_messages)
    end
    redirect_to kobe_categories_path(id: @category)
  end

  # 恢复
  def recover
    render partial: '/shared/dialog/opt_liyou', locals: { form_id: 'recover_category_form', action: update_recover_kobe_category_path(@category) }
  end

  def update_recover
    if @category.change_status_and_write_logs("正常", stateless_logs("恢复",params[:opt_liyou],false))
      tips_get("恢复品目成功。")
    else
      flash_get(@category.errors.full_messages)
    end
    redirect_to kobe_categories_path(id: @category)
  end

  def move
    ztree_move(Category)
  end

  def ztree
    ztree_nodes_json(Category)
  end

  # 验证品目名称
  def valid_name
    params[:obj_id] ||= 0
    render :text => valid_remote(Category, ["name = ? and id != ?", params[:categories][:name], params[:obj_id]])
  end

  private
    def get_category
      @category = Category.find(params[:id]) if params[:id].present?
    end

end
