'''Utils
'''
import json

__all__ = ['MyException', 'nedb_parser']

class MyException(Exception):
    '''My Exception

    I don't want to check the return value of every function when error occurs.
    Raise an exception, just easier to programming.
    '''
    def __init__(self, msg):
        super().__init__(msg)
        self.message = msg

    def __str__(self):
        return self.message


def nedb_parser(nedb):
    '''nedb_parser
    '''
    result = {}
    line_num = 1

    print('Get raw data from {}'.format(nedb))
    with open(nedb, 'r', encoding='utf-8') as nedb_f:
        for line in nedb_f:
            python_object = json.loads(line)
            if not isinstance(python_object, dict):
                raise MyException('Not a python dict, line number {}'.format(line_num))

            line_num += 1
            item_id = python_object['id']
            result[item_id] = python_object

    print('Loaded {} datas from {}'.format(len(result), nedb))
    return result
