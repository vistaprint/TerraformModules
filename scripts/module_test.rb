class ModuleTest
  def initialize(module_name)
    @module_name = module_name
  end

  def run_task(task_name)
    puts("=== Running task #{task_name} for module #{@module_name} ===")
    module_path = File.join('test', @module_name)
    Dir.chdir(module_path) do
      run_task_in_directory(task_name)
    end
  end

  private

  def run_task_in_directory(task_name)
    load 'rakefile.rb'
    begin
      Rake::Task["#{@module_name}:#{task_name}"].invoke(DEFAULT_PREFIX)
    rescue RuntimeError => e
      puts e.message
      puts e.backtrace.join("\n")
      Rake::Task["#{@module_name}:clean"].invoke(DEFAULT_PREFIX)
      raise "Error testing module #{@module_name}"
    end
  end
end

class ModuleTestRepository
  def self.each
    modules_path = Rake::FileList.new('test/*')
    modules_path.each do |path|
      module_name = File.basename(path)
      yield ModuleTest.new(module_name) unless excluded?(module_name)
    end
  end

  private_class_method
  def self.excluded?(module_name)
    excluded_modules.include?(module_name)
  end

  private_class_method
  def self.excluded_modules
    ENV.fetch('TM_EXCLUDE_MODULES', '').split(',')
  end
end
