#!/usr/bin/env python3
"""
BUSCO v6 Plot Generator
Reads short_summary.specific.*.txt and produces a publication-quality PNG
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import re
import os
import sys

# ─────────────────────────────────────────────
# CONFIG — edit these if needed
# ─────────────────────────────────────────────
FILENAME  = 'short_summary.specific.bacteria_odb10.busco_results.txt'
OUTPUT    = 'busco_plot.png'
DPI       = 300
# ─────────────────────────────────────────────


def parse_busco_summary(filepath):
    """
    Parses BUSCO v5/v6 short_summary file.
    Supports both the one-line C:...% format and the tabular block format.
    Returns dict with keys: comp_s, comp_d, frag, miss, total, label, lineage
    """
    comp_s = comp_d = frag = miss = total = 0
    lineage = os.path.basename(filepath)

    # Extract lineage name from filename: short_summary.specific.<lineage>.<run>.txt
    parts = os.path.basename(filepath).split('.')
    if len(parts) >= 4:
        lineage = parts[2]   # e.g. bacteria_odb10
        label   = parts[3]   # e.g. busco_results

    with open(filepath) as fh:
        for line in fh:
            line = line.strip()

            # Tabular lines (most reliable) — covers v5 and v6
            if re.search(r'Complete and single-copy BUSCOs \(S\)', line):
                comp_s = int(line.split()[0])
            elif re.search(r'Complete and duplicated BUSCOs \(D\)', line):
                comp_d = int(line.split()[0])
            elif re.search(r'Fragmented BUSCOs \(F\)', line):
                frag   = int(line.split()[0])
            elif re.search(r'Missing BUSCOs \(M\)', line):
                miss   = int(line.split()[0])
            elif re.search(r'Total BUSCO groups searched', line):
                total  = int(line.split()[0])

            # One-liner fallback: C:98.4%[S:96.8%,D:1.6%],F:0.8%,M:0.8%,n:124
            elif line.startswith('C:') and total == 0:
                m = re.search(
                    r'C:[\d.]+%\[S:([\d.]+)%,D:([\d.]+)%\],'
                    r'F:([\d.]+)%,M:([\d.]+)%,n:(\d+)', line)
                if m:
                    s_pc  = float(m.group(1))
                    d_pc  = float(m.group(2))
                    f_pc  = float(m.group(3))
                    miss_pc = float(m.group(4))
                    total = int(m.group(5))
                    comp_s = round(s_pc  / 100 * total)
                    comp_d = round(d_pc  / 100 * total)
                    frag   = round(f_pc  / 100 * total)
                    miss   = round(miss_pc / 100 * total)

    if total == 0:
        total = comp_s + comp_d + frag + miss

    return dict(comp_s=comp_s, comp_d=comp_d, frag=frag, miss=miss,
                total=total, lineage=lineage, label=label)


def make_plot(data, outfile=OUTPUT, dpi=DPI):
    comp   = data['comp_s'] + data['comp_d']
    total  = data['total']

    # ── percentages ──────────────────────────────────────────
    pcs = {k: round(data[k] / total * 100, 1)
           for k in ('comp_s', 'comp_d', 'frag', 'miss')}
    comp_pc = round(pcs['comp_s'] + pcs['comp_d'], 1)

    cats   = ['Complete (S)', 'Complete (D)', 'Fragmented', 'Missing']
    counts = [data['comp_s'], data['comp_d'], data['frag'], data['miss']]
    percs  = [pcs['comp_s'],  pcs['comp_d'],  pcs['frag'],  pcs['miss']]

    # BUSCO colour palette (canonical)
    COLORS = ['#56B4E9', '#3492C7', '#F0E442', '#F04442']

    # ── figure layout ────────────────────────────────────────
    fig = plt.figure(figsize=(12, 7), facecolor='#0D1117')
    ax  = fig.add_axes([0.08, 0.22, 0.88, 0.60])
    ax.set_facecolor('#161B22')

    # ── horizontal stacked bar ───────────────────────────────
    left = 0
    bar_h = 0.55
    for i, (cat, cnt, pc, col) in enumerate(zip(cats, counts, percs, COLORS)):
        ax.barh(0, pc, left=left, height=bar_h, color=col,
                linewidth=0, zorder=3)

        # label inside bar (only if wide enough)
        if pc >= 3:
            ax.text(left + pc / 2, 0,
                    f'{pc}%\n({cnt})',
                    ha='center', va='center',
                    fontsize=10, fontweight='bold',
                    color='#0D1117' if col in ('#56B4E9', '#3492C7') else '#0D1117',
                    zorder=4)
        left += pc

    # ── axes cosmetics ───────────────────────────────────────
    ax.set_xlim(0, 100)
    ax.set_ylim(-0.5, 0.5)
    ax.set_yticks([])
    ax.set_xticks(range(0, 101, 10))
    ax.set_xticklabels([f'{x}%' for x in range(0, 101, 10)],
                       color='#C9D1D9', fontsize=10)
    ax.tick_params(axis='x', colors='#C9D1D9', length=5)
    ax.spines[:].set_visible(False)
    ax.xaxis.set_tick_params(which='both', bottom=True)
    ax.set_xlabel('% BUSCOs', color='#C9D1D9', fontsize=12, labelpad=8)

    # Gridlines
    for x in range(10, 100, 10):
        ax.axvline(x, color='#30363D', linewidth=0.7, zorder=1, linestyle='--')

    # ── title block ──────────────────────────────────────────
    fig.text(0.5, 0.93,
             'BUSCO Assessment Results',
             ha='center', va='top',
             fontsize=18, fontweight='bold', color='#E6EDF3',
             fontfamily='DejaVu Sans')

    fig.text(0.5, 0.875,
             f'Lineage: {data["lineage"]}   |   Run: {data["label"]}   |   n = {total} BUSCOs',
             ha='center', va='top',
             fontsize=11, color='#8B949E',
             fontfamily='DejaVu Sans')

    # ── summary badge ────────────────────────────────────────
    badge_txt = (f'C:{comp_pc}%  [S:{pcs["comp_s"]}%,  D:{pcs["comp_d"]}%]'
                 f'   F:{pcs["frag"]}%   M:{pcs["miss"]}%   n:{total}')
    fig.text(0.5, 0.17,
             badge_txt,
             ha='center', va='top',
             fontsize=11, color='#58A6FF',
             fontfamily='monospace',
             bbox=dict(boxstyle='round,pad=0.5', facecolor='#161B22',
                       edgecolor='#30363D', linewidth=1.2))

    # ── legend ───────────────────────────────────────────────
    legend_labels = [
        f'Complete & single-copy (S)  — {data["comp_s"]} ({pcs["comp_s"]}%)',
        f'Complete & duplicated (D)   — {data["comp_d"]} ({pcs["comp_d"]}%)',
        f'Fragmented (F)              — {data["frag"]} ({pcs["frag"]}%)',
        f'Missing (M)                 — {data["miss"]} ({pcs["miss"]}%)',
    ]
    patches = [mpatches.Patch(color=c, label=l)
               for c, l in zip(COLORS, legend_labels)]
    leg = fig.legend(handles=patches,
                     loc='lower center',
                     ncol=2,
                     bbox_to_anchor=(0.5, 0.005),
                     frameon=True,
                     framealpha=0.15,
                     facecolor='#161B22',
                     edgecolor='#30363D',
                     fontsize=9.5,
                     labelcolor='#C9D1D9')

    # ── save ─────────────────────────────────────────────────
    plt.savefig(outfile, dpi=dpi, bbox_inches='tight',
                facecolor=fig.get_facecolor())
    plt.close()
    print(f'✅  Saved → {outfile}  ({dpi} DPI)')


# ─────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────
if __name__ == '__main__':
    fp = sys.argv[1] if len(sys.argv) > 1 else FILENAME

    if not os.path.exists(fp):
        sys.exit(f'❌  File not found: {fp}')

    data = parse_busco_summary(fp)
    print(f'📊  Parsed → C:S={data["comp_s"]}, C:D={data["comp_d"]}, '
          f'F={data["frag"]}, M={data["miss"]}, n={data["total"]}')

    make_plot(data, outfile=OUTPUT, dpi=DPI)
