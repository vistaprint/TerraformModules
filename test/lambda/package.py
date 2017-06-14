def say_hello(event, context):
    return {'Result': 'Hello {}'.format(event['name'])}

def say_goodbye(event, context):
    return {'Result': 'Goodbye {}'.format(event['name'])}
