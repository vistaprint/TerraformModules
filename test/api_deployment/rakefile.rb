require 'time'
require 'zip'

Zip.setup do |c|
  c.continue_on_exists_proc = true
end

namespace 'api_deployment' do
  load '../../scripts/tasks.rake'

  task :prepare, [:prefix] do
    Zip::File.open('lambda.zip', Zip::File::CREATE) do |zipfile|
      zipfile.add('lambda.py', 'lambda.py')
    end
  end

  # TODO: test that caching is enabled
  task :validate, [:prefix] do
    api_url = TDK::TerraformLogFilter.filter(
      TDK::Command.run('terraform output api_url'))[0]

    response = TDK.with_retry(10, sleep_time: 5) do
      TDK::Request.new(api_url).execute(raise_on_codes: ['500'])
    end

    # just do matching on date, as time might be in slightly different format
    if response.status[0] != '200' \
        || /\d{4}-\d{2}-\d{2}/.match(response.read[0..9]).nil?
      raise 'Error while querying the API'
    end
  end
end
