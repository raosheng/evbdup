# -*- encoding : utf-8 -*-
class ChangeBudgetToTotalForBudgets < ActiveRecord::Migration
  def change
    rename_column :budgets, :budget, :total
  end
end
