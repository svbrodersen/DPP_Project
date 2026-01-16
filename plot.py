#!/usr/bin/env python3
"""
Benchmark Runtime Plotter

This script reads JSON benchmark files and creates plots showing mean running times
for different configurations (number of rectangles, points, and grouping percentages).
"""

import json
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
import re
from collections import defaultdict
import argparse


def parse_filename(filename):
    """
    Parse benchmark filename to extract parameters.
    
    Expected format: data/{rectangles}_{points}_{percent}.in
    Returns: (rectangles, points, percent) as integers/floats
    """
    match = re.match(r'data/(\d+)_(\d+)_([\d.]+)\.in', filename)
    if match:
        rectangles = int(match.group(1))
        points = int(match.group(2))
        percent = float(match.group(3))
        return rectangles, points, percent
    return None


def load_benchmark_data(filepath):
    """
    Load benchmark data from JSON file.
    
    Returns: dict with program_name -> datasets
    """
    with open(filepath, 'r') as f:
        data = json.load(f)
    return data


def extract_mean_runtimes(benchmark_data):
    """
    Extract mean runtimes for all datasets in benchmark data.
    
    Returns: dict with (rectangles, points, percent) -> mean_runtime
    """
    results = {}
    
    for program_name, program_data in benchmark_data.items():
        datasets = program_data.get('datasets', {})
        
        for dataset_name, dataset_info in datasets.items():
            params = parse_filename(dataset_name)
            if params is None:
                continue
                
            runtimes = dataset_info.get('runtimes', [])
            if runtimes:
                mean_runtime = np.mean(runtimes)
                results[params] = mean_runtime
    
    return results


def plot_runtime_by_points(data_dict, title="Runtime vs Number of Points", label=None):
    """
    Plot runtime vs number of points for different rectangle counts and percentages.
    """
    # Group by rectangles and percent
    grouped = defaultdict(lambda: defaultdict(list))
    
    for (rectangles, points, percent), mean_time in data_dict.items():
        grouped[(rectangles, percent)][points].append(mean_time)
    
    # Create plot
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle(title, fontsize=16)
    
    percents = [0.0, 0.25, 0.5]
    
    for idx, percent in enumerate(percents):
        ax = axes[idx]
        ax.set_title(f'Grouping: {percent*100:.0f}%')
        ax.set_xlabel('Number of Points')
        ax.set_ylabel('Mean Runtime (microseconds)')
        ax.set_xscale('log')
        ax.set_yscale('log')
        ax.grid(True, alpha=0.3)
        
        # Get unique rectangle counts
        rect_counts = sorted(set(r for (r, p) in grouped.keys() if p == percent))
        
        for rectangles in rect_counts:
            points_list = []
            times_list = []
            
            for points in sorted(grouped[(rectangles, percent)].keys()):
                times = grouped[(rectangles, percent)][points]
                points_list.append(points)
                times_list.append(np.mean(times))
            
            if points_list:
                ax.plot(points_list, times_list, marker='o', 
                       label=f'{rectangles:,} rectangles', linewidth=2)
        
        ax.legend()
    
    plt.tight_layout()
    return fig


def plot_runtime_by_rectangles(data_dict, title="Runtime vs Number of Rectangles", label=None):
    """
    Plot runtime vs number of rectangles for different point counts and percentages.
    """
    # Group by points and percent
    grouped = defaultdict(lambda: defaultdict(list))
    
    for (rectangles, points, percent), mean_time in data_dict.items():
        grouped[(points, percent)][rectangles].append(mean_time)
    
    # Create plot
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle(title, fontsize=16)
    
    percents = [0.0, 0.25, 0.5]
    
    for idx, percent in enumerate(percents):
        ax = axes[idx]
        ax.set_title(f'Grouping: {percent*100:.0f}%')
        ax.set_xlabel('Number of Rectangles')
        ax.set_ylabel('Mean Runtime (microseconds)')
        ax.set_xscale('log')
        ax.set_yscale('log')
        ax.grid(True, alpha=0.3)
        
        # Get unique point counts
        point_counts = sorted(set(p for (p, pct) in grouped.keys() if pct == percent))
        
        for points in point_counts:
            rect_list = []
            times_list = []
            
            for rectangles in sorted(grouped[(points, percent)].keys()):
                times = grouped[(points, percent)][rectangles]
                rect_list.append(rectangles)
                times_list.append(np.mean(times))
            
            if rect_list:
                ax.plot(rect_list, times_list, marker='o', 
                       label=f'{points:,} points', linewidth=2)
        
        ax.legend()
    
    plt.tight_layout()
    return fig


def plot_comparison(data_dicts, labels, title="Runtime Comparison"):
    """
    Create comparison plots for multiple benchmark files.
    """
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    fig.suptitle(title, fontsize=16)
    
    percents = [0.0, 0.25, 0.5]
    
    # Plot 1: Runtime vs Points (fixed rectangles=1000)
    for idx, percent in enumerate(percents):
        ax = axes[0, idx]
        ax.set_title(f'Runtime vs Points (1000000 rects, {percent*100:.0f}% grouped)')
        ax.set_xlabel('Number of Points')
        ax.set_ylabel('Mean Runtime (μs)')
        ax.set_xscale('log')
        ax.set_yscale('log')
        ax.grid(True, alpha=0.3)
        
        for data_dict, label in zip(data_dicts, labels):
            points_list = []
            times_list = []
            
            for (rectangles, points, pct), mean_time in sorted(data_dict.items()):
                if rectangles == 1000000 and pct == percent:
                    points_list.append(points)
                    times_list.append(mean_time)
            
            if points_list:
                ax.plot(points_list, times_list, marker='o', label=label, linewidth=2)
        
        ax.legend()
    
    # Plot 2: Runtime vs Rectangles (fixed points=100000)
    for idx, percent in enumerate(percents):
        ax = axes[1, idx]
        ax.set_title(f'Runtime vs Rectangles (10000000 pts, {percent*100:.0f}% grouped)')
        ax.set_xlabel('Number of Rectangles')
        ax.set_ylabel('Mean Runtime (μs)')
        ax.set_xscale('log')
        ax.set_yscale('log')
        ax.grid(True, alpha=0.3)
        
        for data_dict, label in zip(data_dicts, labels):
            rect_list = []
            times_list = []
            
            for (rectangles, points, pct), mean_time in sorted(data_dict.items()):
                if points == 10000000 and pct == percent:
                    rect_list.append(rectangles)
                    times_list.append(mean_time)
            
            if rect_list:
                ax.plot(rect_list, times_list, marker='o', label=label, linewidth=2)
        
        ax.legend()
    
    plt.tight_layout()
    return fig


def main():
    parser = argparse.ArgumentParser(
        description='Plot benchmark runtimes from JSON files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Single file
  python plot_benchmarks.py benchmarks.json
  
  # Multiple files for comparison
  python plot_benchmarks.py file1.json file2.json --labels "Version 1" "Version 2"
  
  # Save plots to files
  python plot_benchmarks.py benchmarks.json --output plots/
        """
    )
    parser.add_argument('files', nargs='+', help='JSON benchmark file(s) to plot')
    parser.add_argument('--labels', nargs='+', help='Labels for each file (for comparison plots)')
    parser.add_argument('--output', '-o', help='Output directory for saving plots (optional)')
    parser.add_argument('--format', default='png', choices=['png', 'pdf', 'svg'], 
                       help='Output format for saved plots')
    
    args = parser.parse_args()
    
    # Load data from all files
    data_dicts = []
    labels = args.labels if args.labels else [Path(f).stem for f in args.files]
    
    if len(labels) != len(args.files):
        print(f"Warning: Number of labels ({len(labels)}) doesn't match number of files ({len(args.files)})")
        labels = [Path(f).stem for f in args.files]
    
    for filepath in args.files:
        print(f"Loading {filepath}...")
        benchmark_data = load_benchmark_data(filepath)
        mean_runtimes = extract_mean_runtimes(benchmark_data)
        data_dicts.append(mean_runtimes)
        print(f"  Found {len(mean_runtimes)} configurations")
    
    # Create output directory if specified
    if args.output:
        output_dir = Path(args.output)
        output_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate plots
    if len(args.files) == 1:
        # Single file: create detailed plots
        print("\nGenerating plots...")
        
        fig1 = plot_runtime_by_points(data_dicts[0], 
                                      title=f"Runtime vs Number of Points - {labels[0]}")
        if args.output:
            fig1.savefig(output_dir / f'runtime_vs_points.{args.format}', 
                        dpi=300, bbox_inches='tight')
            print(f"  Saved: runtime_vs_points.{args.format}")
        
        fig2 = plot_runtime_by_rectangles(data_dicts[0], 
                                          title=f"Runtime vs Number of Rectangles - {labels[0]}")
        if args.output:
            fig2.savefig(output_dir / f'runtime_vs_rectangles.{args.format}', 
                        dpi=300, bbox_inches='tight')
            print(f"  Saved: runtime_vs_rectangles.{args.format}")
    
    else:
        # Multiple files: create comparison plot
        print("\nGenerating comparison plot...")
        
        fig = plot_comparison(data_dicts, labels, 
                             title="Benchmark Comparison")
        if args.output:
            fig.savefig(output_dir / f'comparison.{args.format}', 
                       dpi=300, bbox_inches='tight')
            print(f"  Saved: comparison.{args.format}")
    
    if not args.output:
        print("\nDisplaying plots...")
        plt.show()
    else:
        print(f"\nPlots saved to {output_dir}/")


if __name__ == '__main__':
    main()
