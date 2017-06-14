require_relative '../../build/aws'
require_relative '../../build/config'
require_relative '../../build/dynamodb'

namespace 'dynamodb_table' do
  load '../../build/tasks.rake'

  module DynamoDbTableTest
    def self.test_table(dynamo_db, table_name)
      dynamo_db.put_item(table_name,
                         'ItemKey' => '1',
                         'ItemData' => 'One')

      item = dynamo_db.get_item(table_name,
                                'ItemKey' => '1')['item']

      raise 'Writing/reading test failed' unless item['ItemData'] == 'One'
    end
  end

  task :validate, [:prefix] do |t, args|
    aws_config = AwsConfig.new(Configuration.get('aws'))
    dynamo_db = DynamoDB.new(
      aws_config.credentials,
      aws_config.region
    )

    DynamoDbTableTest.test_table(dynamo_db, "#{args.prefix}Table1")
    DynamoDbTableTest.test_table(dynamo_db, "#{args.prefix}Table2")
  end
end
