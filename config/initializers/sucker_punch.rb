SuckerPunch.exception_handler { |ex| ExceptionNotifier.notify_exception(ex) }
Rails.application.configure do
  config.active_job.queue_adapter = :sucker_punch unless Rails.env.test? #TODO - use sucker punch in tests
end