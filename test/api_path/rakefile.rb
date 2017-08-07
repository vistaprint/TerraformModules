require 'zip'

Zip.setup do |c|
  c.continue_on_exists_proc = true
end

namespace 'api_path' do
  load '../../scripts/tasks.rake'

  task :prepare, [:prefix] do
    Zip::File.open('sample_lambda.zip', Zip::File::CREATE) do |zipfile|
      zipfile.add('hello.py', 'hello.py')
    end
  end

  task :validate, [:prefix] do
    api_url = TDK::TerraformLogFilter.filter(
      TDK::Command.run('terraform output api_url'))[0]

    response = TDK.with_retry(10, sleep_time: 5) do
      TDK::Request.new("#{api_url}/hello/Steve").execute(raise_on_codes: ['500'])
    end

    if response.status[0] != '200' || response.read != 'Hello Steve'
      raise 'Error while querying the API'
    end
  end
end
