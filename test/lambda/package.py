import os

def say_hello(event, _):
    return {'Result': 'Hello {}'.format(event['name'])}

def print_vars(event, _):
    return {'Result': os.environ[event['name']]}
