class DropSolidQueueTablesFromMainDb < ActiveRecord::Migration[8.0]
  def up
    drop_table :solid_queue_blocked_executions, if_exists: true
    drop_table :solid_queue_claimed_executions, if_exists: true
    drop_table :solid_queue_failed_executions, if_exists: true
    drop_table :solid_queue_jobs, if_exists: true
    drop_table :solid_queue_pauses, if_exists: true
    drop_table :solid_queue_processes, if_exists: true
    drop_table :solid_queue_ready_executions, if_exists: true
    drop_table :solid_queue_recurring_executions, if_exists: true
    drop_table :solid_queue_scheduled_executions, if_exists: true
    drop_table :solid_queue_semaphores, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "To recreate the solid queue tables, please run the following command:\n\n" \
      "rails generate solid_queue:install\n\n" \
      "and then run the migrations again."
  end
end
