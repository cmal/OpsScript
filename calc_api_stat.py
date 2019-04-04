__author__ = 'dyson'

import sys
import pprint
from pygrok import Grok

def merge_api(api):
    if api.startswith('/p/www/stockinfogate/stock/') and api.endswith('/announcements'):
        return '/p/www/stockinfogate/stock/[stockid]/announcements'
    elif api.startswith('/p/www/stockinfogate/user/stock/scores/'):
        return '/p/www/stockinfogate/user/stock/scores/[stockid]'
    elif api.startswith('/asset/') and api.endswith('css'):
        return '/asset/xxx/xx.css'
    elif api.startswith('/asset/') and api.endswith('js'):
        return '/asset/xxx/xx.js'
    elif api.startswith('/chart/img/') and api.endswith('.png'):
        return '/chart/img/xx.png'
    elif api.startswith('/p/www/stockinfogate/stock/summary/'):
        return '/p/www/stockinfogate/stock/summary/[stockid]'
    elif api.startswith('/p/www/stockinfogate/stock/tech-info/'):
        return '/p/www/stockinfogate/stock/tech-info/[stockid]'
    elif api.startswith('/p/www/stockinfogate/stock/unlockinfo/m/'):
        return '/p/www/stockinfogate/stock/unlockinfo/m/[stockid]'
    elif api.startswith('/pdf/') and api.endswith('.html'):
        return '/pdf/xx.html'
    elif api.startswith('/wx/img/'):
        return '/wx/img/xx'
    else:
        return api


def calc_api_stat_daily(logfile):
    with open(logfile, 'r') as fin:
        lines = fin.readlines()
        pattern = '%{IPORHOST:clientip} - - \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response} (?:%{NUMBER:bytes}|-) (?:"(?:%{URI:referrer}|-)"|%{QS:referrer}) %{QS:agent} %{QS:xforwardedfor} %{BASE10NUM:request_duration}'
        grok = Grok(pattern)
        api_stat_dic = {}
        for line in lines:
            res = grok.match(line)
            if res is None:
                continue
            api, duration = res['request'].split('?')[0], float(res['request_duration'])* 1000
            api = merge_api(api)
            val = api_stat_dic.get(api, None)
            if val is None:
                api_stat_dic[api] = {'cnt':1, 'avg': duration, 'max': duration, 'min': duration}
            else:
                val['max'] = max(val['max'], duration)
                val['min'] = min(val['min'], duration)
                val['avg'] = (val['avg'] * val['cnt'] + duration) / (val['cnt'] + 1)
                val['cnt'] += 1
            #pprint.pprint(api_stat_dic)
        for k, v in api_stat_dic.items():
            print('{}\t{}\t{}\t{}\t{}'.format(k, v['cnt'], round(v['avg'], 0), v['max'], v['min']))




if __name__ == '__main__':
    logfile = sys.argv[0]
    logfile = '/OpsScript/nginx-m-access-logs/m-access.log'
    calc_api_stat_daily(logfile)
