# -*- encoding : utf-8 -*-
class BidItem < ActiveRecord::Base
  belongs_to :BidProject
  belongs_to :category

  default_value_for :can_other, false

  # 从表的XML加ID是为了修改的时候能找到记录
  def self.xml(who='',options={})
    %Q{
      <?xml version='1.0' encoding='UTF-8'?>
      <root>
        <node column='id' data_type='hidden'/>
        <node column='category_id' data_type='hidden'/>
        <node name='品目' column='category_name' class='tree_radio required' json_url='/kobe/shared/category_ztree_json' json_params='{"yw_type":"#{Dictionary.category_yw_type[:wsjj].first}","vv_checklevel":-1}' partner='category_id'/>
        <node name='参考品牌' column='brand_name' class='required'/>
        <node name='参考型号' column='xh' class='required'/>
        <node name='采购数量' column='num' class='required number'/>
        <node name='计量单位' class='zip' column='unit' class='required'/>
        <node name='是否允许投报其他型号的产品' column='can_other' class='required' data='#{Dictionary.yes_or_no}' data_type='radio'/>
        <node name='技术指标和服务要求' column='req' data_type='textarea' class='maxlength_800' placeholder='不超过800字'/>
        <node name='备注' column='remark' data_type='textarea' class='maxlength_800' placeholder='不超过800字'/>
      </root>
    }
  end

end
