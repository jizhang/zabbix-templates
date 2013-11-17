#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
import urllib2

class Job(object):

    def __init__(self, args):
        self.args = args

    def run(self):
        print self.args

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Hadoop metrics collector for Zabbix.')
    parser.add_argument('-t', '--type', required=True, help='collector type',
                        choices=['namenode', 'datanode', 'jobtracker', 'tasktracker'])
    parser.add_argument('-s', '--host', required=True, help='host name')
    args = parser.parse_args()

    Job(args).run()
