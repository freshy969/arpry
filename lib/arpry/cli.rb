module Arpry
  class CLI
    def initialize(argv)
      @argv = argv
      @database = nil
      @adapter = nil
    end

    def run
      parse_options

      namespace = ClassFactory.create(@params)
      ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer = true if @params[:adapter] == 'sqlite3'

      prompts = [
        proc do |_obj, nest_level, pry|
          "[#{pry.input_ring.size}] arpry#{":#{nest_level}" unless nest_level.zero?}> "
        end,
        proc do |_obj, nest_level, pry|
          "[#{pry.input_ring.size}] arpry#{":#{nest_level}" unless nest_level.zero?}* "
        end,
      ]

      binding.pry(namespace, prompt: prompts)

      return 0
    end

    private

    def parse_options
      opt = OptionParser.new
      opt.on('-a [NAME]', '--adapter [NAME]')
      opt.on('-h [HOST]', '--host [HOST]')
      opt.on('-u [NAME]', '--username [NAME]')
      opt.on('-p [PASSWORD]', '--password [PASSWORD]')
      opt.on('-d [DB]', '--database [DB]')
      @params = {}
      args = opt.parse(@argv, into: @params)

      @params[:database] ||= args[0] if args.present?
      if @params[:database] && File.exist?(@params[:database])
        @params[:adapter] ||= 'sqlite3'
      end
    end
  end
end
