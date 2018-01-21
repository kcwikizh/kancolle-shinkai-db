"""Utils
"""
import json

__all__ = ['MyException', 'nedb_parser', 'python_data_to_lua_table']
LUA_INDENT = ' ' * 4


class MyException(Exception):
    """My Exception

    I don't want to check the return value of every function.
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
                raise MyException(
                    'Not a python dict, line number {}'.format(line_num))

            line_num += 1
            item_id = python_object['id']
            result[item_id] = python_object

    print('Loaded {} datas from {}'.format(len(result), nedb))
    return result


def python_data_to_lua_table(data, level=0, indent=LUA_INDENT):
    """Generate Lua string via python structure

    only dict, list, string, number are allowed

    :param data: data to parse
    :param level: indent level
    :param indent: indent characters
    :return: tuple (lua string in this level and
             whether it's a list only contains number and string
    """
    lines = []
    if isinstance(data, list):
        all_elements_is_pure_data = True
        for i in data:
            if isinstance(i, dict):
                line, _ = python_data_to_lua_table(i, level+1, indent)
                lines.append(level*indent + '{\n'
                             + line + '\n' + level*indent + '}')
                all_elements_is_pure_data = False
            elif isinstance(i, list):
                line, pure_data_in_next_level = \
                    python_data_to_lua_table(i, level+1, indent)
                if pure_data_in_next_level:
                    lines.append(level*indent + '{' + line + '}')
                else:
                    lines.append(level*indent + '{\n'
                                 + line + '\n' + level*indent + '}')
                all_elements_is_pure_data = False
            elif isinstance(i, int):
                lines.append(level*indent + str(i))
            elif isinstance(i, str):
                lines.append(level*indent + '"{}"'.format(i))
            else:
                raise MyException('Unsupported data\n' + str(i) + '\n'
                                  + 'with type:' + type(i))

        if all_elements_is_pure_data:
            # All elements in list is pure data, not list or dict
            return ', '.join([i.strip() for i in lines]), True
        return ',\n'.join(lines), False

    if isinstance(data, dict):
        for i in data:
            if isinstance(data[i], dict):
                line, _ = python_data_to_lua_table(data[i], level+1, indent)
                lines.append(level*indent + '["{}"] = {{\n'.format(i)
                             + line + '\n' + level*indent + '}')
            elif isinstance(data[i], list):
                line, pure_data_in_next_level = \
                    python_data_to_lua_table(data[i], level+1, indent)
                if pure_data_in_next_level:
                    lines.append(level*indent + '["{}"] = {{'.format(i)
                                 + line + '}')
                else:
                    lines.append(level*indent + '["{}"] = {{\n'.format(i)
                                 + line + '\n' + level*indent + '}')
            elif isinstance(data[i], int):
                lines.append(level*indent + '["{}"] = {}'.format(i, data[i]))
            elif isinstance(data[i], str):
                lines.append(level*indent + '["{}"] = "{}"'.format(i, data[i]))
            else:
                raise MyException('Unsupported data\n' + str(data[i]) + '\n'
                                  + 'with type:' + str(type(data[i])))
        return ',\n'.join(lines), False
    else:
        raise MyException('Unsupported data\n' + str(data) + '\n'
                          + 'with type:' + type(data))
