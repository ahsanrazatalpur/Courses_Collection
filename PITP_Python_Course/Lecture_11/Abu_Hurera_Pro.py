#!/usr/bin/env python3
"""
Basic Data Analyzer (pure Python)
Usage:
    python data_analyzer.py sample.csv
Outputs summary to console. No external libraries required.
"""

import sys
import math
import csv
from collections import defaultdict, Counter

def read_csv(filepath, delimiter=','):
    """Read CSV file and return header list and rows (list of lists)."""
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        reader = csv.reader(f, delimiter=delimiter)
        rows = [r for r in reader if r and any(cell.strip() for cell in r)]
    if not rows:
        return [], []
    header = rows[0]
    data = rows[1:]
    # normalize row lengths
    for i, r in enumerate(data):
        if len(r) < len(header):
            data[i] = r + [''] * (len(header) - len(r))
        elif len(r) > len(header):
            data[i] = r[:len(header)]
    return header, data

def is_number(s):
    """Return True if string s can be converted to float."""
    if s is None:
        return False
    s = s.strip()
    if s == '':
        return False
    try:
        float(s)
        return True
    except:
        return False

def to_number(s):
    try:
        return float(s)
    except:
        return None

def summary_numeric(values):
    """Compute count, mean, median, mode(s), min, max, std for numeric list."""
    nums = [v for v in values if v is not None]
    n = len(nums)
    if n == 0:
        return None
    s = sum(nums)
    mean = s / n
    sorted_nums = sorted(nums)
    # median
    mid = n // 2
    if n % 2 == 1:
        median = sorted_nums[mid]
    else:
        median = (sorted_nums[mid - 1] + sorted_nums[mid]) / 2.0
    # mode(s)
    freq = Counter(sorted_nums)
    maxc = max(freq.values())
    modes = sorted([val for val, cnt in freq.items() if cnt == maxc])
    minimum = sorted_nums[0]
    maximum = sorted_nums[-1]
    # standard deviation (sample)
    if n > 1:
        var = sum((x - mean) ** 2 for x in nums) / (n - 1)
        std = math.sqrt(var)
    else:
        std = 0.0
    return {
        'count': n,
        'mean': mean,
        'median': median,
        'modes': modes,
        'min': minimum,
        'max': maximum,
        'std': std
    }

def summary_categorical(values):
    """Return counts, unique, top (most common)"""
    cats = [v for v in values if v is not None and v != '']
    n = len(cats)
    if n == 0:
        return None
    freq = Counter(cats)
    unique = len(freq)
    most_common = freq.most_common(5)
    return {
        'count': n,
        'unique': unique,
        'top5': most_common
    }

def ascii_histogram(freq_items, width=40, max_bars=20):
    """Return a small ASCII histogram as string from (value, count) pairs."""
    lines = []
    # limit to top max_bars
    items = freq_items[:max_bars]
    if not items:
        return ''
    max_count = items[0][1]
    for val, cnt in items:
        bar_len = int((cnt / max_count) * width) if max_count > 0 else 0
        lines.append(f"{str(val)[:20]:20} | {'#' * bar_len} ({cnt})")
    return '\n'.join(lines)

def detect_column_types(rows, col_index):
    """Detect whether a column is numeric or categorical based on content."""
    values = [row[col_index].strip() if col_index < len(row) else '' for row in rows]
    num_count = sum(1 for v in values if is_number(v))
    non_empty = sum(1 for v in values if v != '')
    # if majority numeric -> numeric
    if non_empty == 0:
        return 'empty'
    if num_count >= max(1, non_empty * 0.6):
        return 'numeric'
    return 'categorical'

def analyze(header, rows):
    """Main analyzer: returns dict of column_name -> analysis results."""
    results = {}
    nrows = len(rows)
    for i, col in enumerate(header):
        col_values = []
        raw_values = []
        for r in rows:
            val = r[i].strip() if i < len(r) else ''
            raw_values.append(val)
            if is_number(val):
                col_values.append(to_number(val))
            elif val == '':
                col_values.append(None)
            else:
                col_values.append(val)
        col_type = detect_column_types(rows, i)
        if col_type == 'numeric':
            nums = [v for v in col_values if isinstance(v, float)]
            num_summary = summary_numeric(nums)
            freq = Counter(nums)
            freq_items = sorted(freq.items(), key=lambda x: (-x[1], x[0]))
            results[col] = {
                'type': 'numeric',
                'rows_with_value': sum(1 for v in col_values if v not in (None, '')),
                'summary': num_summary,
                'frequency_top': freq_items[:10],
                'histogram': ascii_histogram(freq_items)
            }
        elif col_type == 'categorical':
            cats = [v for v in col_values if v not in (None, '')]
            cat_summary = summary_categorical(cats)
            freq = Counter(cats)
            freq_items = freq.most_common()
            results[col] = {
                'type': 'categorical',
                'rows_with_value': sum(1 for v in col_values if v not in (None, '')),
                'summary': cat_summary,
                'frequency_top': freq_items[:10],
                'histogram': ascii_histogram(freq_items)
            }
        else:
            results[col] = {
                'type': 'empty',
                'rows_with_value': 0,
                'summary': None,
                'frequency_top': [],
                'histogram': ''
            }
    return results

def print_report(filepath, header, rows, analysis):
    print("="*80)
    print(f"File: {filepath}")
    print(f"Rows (excluding header): {len(rows)}")
    print(f"Columns: {len(header)} -> {', '.join(header)}")
    print("="*80)
    for col in header:
        res = analysis[col]
        print(f"\nColumn: {col}")
        print("-"*40)
        print(f"Detected type: {res['type']}")
        print(f"Non-empty values: {res['rows_with_value']}")
        if res['summary'] is None:
            print("No data to summarize.")
            continue
        if res['type'] == 'numeric':
            s = res['summary']
            print(f"Count: {s['count']}")
            print(f"Mean: {s['mean']}")
            print(f"Median: {s['median']}")
            print(f"Mode(s): {s['modes']}")
            print(f"Min: {s['min']}")
            print(f"Max: {s['max']}")
            print(f"Std (sample): {s['std']}")
            if res['frequency_top']:
                print("\nTop frequencies (value: count):")
                for v, c in res['frequency_top']:
                    print(f"  {v} -> {c}")
            if res['histogram']:
                print("\nHistogram (ASCII):")
                print(res['histogram'])
        elif res['type'] == 'categorical':
            s = res['summary']
            print(f"Count: {s['count']}")
            print(f"Unique: {s['unique']}")
            print("\nTop categories (value: count):")
            for v, c in s['top5']:
                print(f"  {v} -> {c}")
            if res['histogram']:
                print("\nHistogram (ASCII):")
                print(res['histogram'])
    print("\n" + "="*80)
    print("End of report.")
    print("="*80)

def main():
    if len(sys.argv) < 2:
        print("Usage: python data_analyzer.py <csv_file>")
        sys.exit(1)
    filepath = sys.argv[1]
    header, rows = read_csv(filepath)
    if not header:
        print("Empty or unreadable file.")
        sys.exit(1)
    analysis = analyze(header, rows)
    print_report(filepath, header, rows, analysis)

# if _name_ == '_main_':
#     main()
if __name__ == '__main__':
    main()