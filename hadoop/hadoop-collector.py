#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
import urllib2
import re
import subprocess

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

        mo = re.search('Heap Size is ([0-9.]+ [MGT]B) / ([0-9.]+ [MGT]B)', content)
        result['heap_used'] = self.regulate_size(mo.group(1))
        result['heap_total'] = self.regulate_size(mo.group(2))

        for dfstable in content.split('\n'):
            if 'Configured Capacity' in dfstable:
                break

        dfstable = re.sub('<tr[^>]*>', '\n', dfstable)
        dfstable = re.sub('<[^>]*>', '', dfstable)
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

        print self.format_result(result)

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

        if unit == 'GB':
            return size * 1024
        elif unit == 'TB':
            return size * 1024 * 1024
        else:
            return size

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Hadoop metrics collector for Zabbix.')
    parser.add_argument('-t', '--type', required=True, help='collector type',
                        choices=['namenode', 'datanode', 'jobtracker', 'tasktracker'])
    parser.add_argument('-s', '--host', required=True, help='zabbix host name')
    parser.add_argument('--zabbix-sender', default='zabbix_sender')
    parser.add_argument('--zabbix-conf')
    parser.add_argument('--namenode-host', default='127.0.0.1')
    parser.add_argument('--namenode-port', default=50070, type=int)
    args = parser.parse_args()

    Job(args).run()
