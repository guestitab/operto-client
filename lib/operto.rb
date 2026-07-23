require 'active_support'
require 'active_support/core_ext'
require 'dry/monads'
require 'faraday'
require 'faraday/retry'
require 'oj'

require_relative 'operto/version'
require_relative 'operto/error'
require_relative 'operto/memory_token_store'
require_relative 'operto/config'
require_relative 'operto/operation'
require_relative 'operto/client'
require_relative 'operto/issue_types'
require_relative 'operto/filtered_pagination'
require_relative 'operto/access_tokens/upsert'
require_relative 'operto/tasks/shared'
require_relative 'operto/tasks/create'
require_relative 'operto/tasks/update'
require_relative 'operto/tasks/index'
require_relative 'operto/staff_tasks/create'
require_relative 'operto/staff_tasks/destroy'
require_relative 'operto/staff_task_times/index'
require_relative 'operto/issues/index'
require_relative 'operto/issues/close'
require_relative 'operto/homes/index'
require_relative 'operto/staff/index'

module Operto
  class << self
    # @rbs () { (Config) -> void } -> void
    def configure
      yield(config)
    end

    # @rbs () -> Config
    def config
      @config ||= Config.new
    end
  end
end
