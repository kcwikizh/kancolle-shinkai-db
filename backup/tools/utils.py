"""Utils
"""
import json

__all__ = ['MyException', 'nedb_parser', 'python_data_to_lua_table']
LUA_INDENT = ' ' * 4


class MyException(Exception):
    """My Exception

    I don't want to check the return value of every function when error occurs.
    Raise an exception, just easier to programming.
    """
    def __init__(self, msg):
        super().__init__(msg)
        self.message = msg

    def __str__(self):
        return self.message


def nedb_parser(nedb):
    """nedb_parser
    """
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


def python_data_to_lua_table(data, level=0, indent=LUA_INDENT):
    """Generate Lua table using python

    'data' must be a dictionary or list when first invoke.
    """
    lines = []
    if isinstance(data, list):
        for i in data:
            if isinstance(i, dict):
                lines.append(level*indent + '{\n'
                             + python_data_to_lua_table(i, level+1, indent)
                             + '\n' + level*indent + '}')
            elif isinstance(i, list):
                lines.append(level*indent + '{\n'
                             + python_data_to_lua_table(i, level+1, indent)
                             + '\n' + level*indent + '}')
            elif isinstance(i, int):
                lines.append(level*indent + str(i))
            elif isinstance(i, str):
                lines.append(level*indent + '"{}"'.format(i))
            else:
                raise MyException('Unsupported data {} with type: {}'.format(str(i), type(i)))
    elif isinstance(data, dict):
        for i in data:
            if isinstance(data[i], dict):
                lines.append(level*indent
                             + '["{}"] = {{\n'.format(i)
                             + python_data_to_lua_table(data[i], level+1, indent)
                             + '\n' + level*indent + '}')
            elif isinstance(data[i], list):
                lines.append(level*indent
                             + '["{}"] = {{\n'.format(i)
                             + python_data_to_lua_table(data[i], level+1, indent)
                             + '\n' + level*indent + '}')
            elif isinstance(data[i], int):
                lines.append(level*indent + '["{}"] = {}'.format(i, data[i]))
            elif isinstance(data[i], str):
                lines.append(level*indent + '["{}"] = "{}"'.format(i, data[i]))
            else:
                raise MyException('Unsupported data\n{}\nwith type: {}'.format(str(data[i]), type(data[i])))
    else:
        raise MyException('Unsupported data\n{}\nwith type: {}'.format(str(data), type(data)))

    return ',\n'.join(lines)
