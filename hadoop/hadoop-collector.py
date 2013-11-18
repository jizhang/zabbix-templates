#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
import urllib2
import re
import subprocess

PTRN_TAG = re.compile('<[^>]+>')

class Job(object):

    def __init__(self, args):
        self.args = args

    def run(self):
        getattr(self, 'collect_%s' % self.args.type)()

    def collect_namenode(self):

        f = urllib2.urlopen('http://%s:%d/dfshealth.jsp' % \
                            (self.args.namenode_host, self.args.namenode_port))
        content = f.read()
        f.close()

        result = {}

        mo = re.search('([0-9]+) files and directories, ([0-9]+) blocks', content)
        result['file_count'] = mo.group(1)
        result['block_count'] = mo.group(2)

        mo = re.search('Heap Size is ([0-9.]+ [KMGTP]?B) / ([0-9.]+ [KMGTP]?B)', content)
        result['heap_used'] = self.regulate_size(mo.group(1))
        result['heap_total'] = self.regulate_size(mo.group(2))

        for dfstable in content.split('\n'):
            if 'Configured Capacity' in dfstable:
                break

        dfstable = re.sub('<tr[^>]*>', '\n', dfstable)
        dfstable = PTRN_TAG.sub('', dfstable)
        dfsmap = {}
        for line in dfstable.split('\n'):
            try:
                k, v = line.split(':')
                dfsmap[k.strip()] = v.strip()
            except ValueError:
                pass

        result['dfs_capacity'] = self.regulate_size(dfsmap['Configured Capacity'])
        result['dfs_used'] = self.regulate_size(dfsmap['DFS Used'])
        result['dfs_used_other'] = self.regulate_size(dfsmap['Non DFS Used'])
        result['dfs_remaining'] = self.regulate_size(dfsmap['DFS Remaining'])
        result['node_alive'] = dfsmap['Live Nodes']
        result['node_dead'] = dfsmap['Dead Nodes']
        result['node_decom'] = dfsmap['Decommissioning Nodes']
        result['block_under'] = dfsmap['Number of Under-Replicated Blocks']

        self.send_result(result)
        
    def collect_jobtracker(self):
        
        f = urllib2.urlopen('http://%s:%d/jobtracker.jsp' % \
                            (self.args.jobtracker_host, self.args.jobtracker_port))
        content = f.read()
        f.close()

        result = {}

        mo = re.search('Heap Size is ([0-9.]+ [KMGTP]?B)/([0-9.]+ [KMGTP]?B)', content)
        result['heap_used'] = self.regulate_size(mo.group(1))
        result['heap_total'] = self.regulate_size(mo.group(2))
        
        lines = iter(content.split('\n'))
        for jthead in lines:
            if 'Running Map Tasks' in jthead:
                jtbody = lines.next()
                break
                
        iter_head = re.finditer('<th[^>]*>(.*?)</th>', jthead)
        iter_body = re.finditer('<td[^>]*>(.*?)</td>', jtbody)
        
        jtmap = {}
        for mo_head in iter_head:
            mo_body = iter_body.next()
            jtmap[mo_head.group(1).strip()] = PTRN_TAG.sub('', mo_body.group(1)).strip()
        
        result['map_running'] = jtmap['Running Map Tasks']
        result['map_occupied'] = jtmap['Occupied Map Slots']
        result['map_reserved'] = jtmap['Reserved Map Slots']
        result['map_capacity'] = jtmap['Map Task Capacity']
        
        result['reduce_running'] = jtmap['Running Reduce Tasks']
        result['reduce_occupied'] = jtmap['Occupied Reduce Slots']
        result['reduce_reserved'] = jtmap['Reserved Reduce Slots']
        result['reduce_capacity'] = jtmap['Reduce Task Capacity']
        
        result['node_count'] = jtmap['Nodes']
        result['node_black'] = jtmap['Blacklisted Nodes']
        result['node_gray'] = jtmap['Graylisted Nodes']
        result['node_excluded'] = jtmap['Excluded Nodes']
        
        result['submission_total'] = jtmap['Total Submissions']

        print self.format_result(result)    

    def send_result(self, result):

        result = self.format_result(result)
        
        print 'Sending:'
        print result

        cmd = [self.args.zabbix_sender]
        cmd.extend(['-z', self.args.zabbix_server])
        cmd.extend(['-p', self.args.zabbix_port])
        cmd.extend(['-s', self.args.host])
        cmd.extend(['-i', '-'])

        p = subprocess.Popen((str(s) for s in cmd),
                             stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
        
        print 'Result:'
        print p.communicate(result)

    def format_result(self, result):
        lines = []
        for k, v in result.iteritems():
            lines.append('- hadoop.namenode.%s %s' % (k, v))
        return '\n'.join(lines)

    def regulate_size(self, size):

        try:
            size, unit = size.split()
            size = float(size)
        except ValueError:
            return 0

        if unit == 'KB':
            size = size * 1024
        elif unit == 'MB':
            size = size * 1024 ** 2
        elif unit == 'GB':
            size = size * 1024 ** 3
        elif unit == 'TB':
            size = size * 1024 ** 4
        elif unit == 'PB':
            size = size * 1024 ** 5

        return int(round(size))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Hadoop metrics collector for Zabbix.')

    parser.add_argument('-t', '--type', required=True, help='collector type',
                        choices=['namenode', 'datanode', 'jobtracker', 'tasktracker'])

    parser.add_argument('--namenode-host', default='127.0.0.1')
    parser.add_argument('--namenode-port', type=int, default=50070)
    
    parser.add_argument('--jobtracker-host', default='127.0.0.1')
    parser.add_argument('--jobtracker-port', type=int, default=50030)

    parser.add_argument('--zabbix-sender', default='zabbix_sender')
    parser.add_argument('-z', '--zabbix-server', required=True, help='zabbix server IP')
    parser.add_argument('-p', '--zabbix-port', type=int, default=10051)
    parser.add_argument('-s', '--host', required=True, help='hostname recognized by zabbix')

    args = parser.parse_args()

    Job(args).run()
