#! /usr/bin/env python3

from re import I
import sys

class Node:
    def __init__(self, name, x, y):
        self.name = name
        self.x = x
        self.y = y

    def __str__(self):
        return f'|> addNode (node "{self.name}" <| position {self.x} {self.y})'

    def scale(self, min_x, max_x, min_y, max_y):
        x = 2 * (self.x - min_x) / (max_x - min_x) - 1
        y = 2 * (self.y - min_y) / (max_y - min_y) - 1
        return Node(self.name, x, y)

class Edge:
    def __init__(self, name, origin, destination):
        self.name = name
        self.origin = origin
        self.destination = destination

    def __str__(self):
        return f'|> addEdge "{self.name}" "{self.origin}" "{self.destination}"'


def sieve(lines):
    nodes = [to_node(line) for line in lines if line.startswith('node')]
    edges = [to_edge(line) for line in lines if line.startswith('edge')]
    return (nodes, edges)

def to_node(record):
    parts = record.rstrip().split()
    return Node(parts[1], float(parts[2]), float(parts[3]))

def to_edge(record):
    parts = record.rstrip().split()
    return Edge(f'{parts[1]}-{parts[2]}', parts[1], parts[2])

def scale_all(nodes):
    x_coordinates = [node.x for node in nodes]
    y_coordinates = [node.y for node in nodes]
    min_x = min(x_coordinates)
    max_x = max(x_coordinates)
    min_y = min(y_coordinates)
    max_y = max(y_coordinates)
    return [node.scale(min_x, max_x, min_y, max_y) for node in nodes]

if __name__ == '__main__':
    lines = [line for line in sys.stdin]
    (nodes, edges) = sieve(lines)
    for node in scale_all(nodes):
        print(f'{node}')
    for edge in edges:
        print(f'{edge}')
    