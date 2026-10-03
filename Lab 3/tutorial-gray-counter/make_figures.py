"""Diagrams for Lab 3 (ICC tutorial, gray counter). Same look as the Lab 2 figures.
The icc_*.png files in figures/ are cropped screenshots from my ICC session."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

OUT = "figures/"

# palette from the Lab 2 figures
BLUE = ("#E6F0FA", "#1B5FA5", "#0E3F72")
ORNG = ("#FAEBDA", "#8A4C0E", "#6B3A08")
GREY = ("#F1EEE8", "#5E5D58", "#2A2A28")
GREEN = ("#E3F4EE", "#0F6E56", "#0B4E3D")
PURP = ("#EEEDFB", "#3C3489", "#2C2668")
TXT = "#444444"


def box(ax, x, y, w, h, title, sub, c, fs=13):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.12",
                                fc=c[0], ec=c[1], lw=1.8))
    ax.text(x + w / 2, y + h / 2 + (0.14 if sub else 0), title, ha="center", va="center",
            fontsize=fs, fontweight="bold", color=c[2])
    if sub:
        ax.text(x + w / 2, y + h / 2 - 0.2, sub, ha="center", va="center", fontsize=fs - 3, color=c[1])


def arrow(ax, x0, y0, x1, y1, color=TXT, ls="-"):
    ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                arrowprops=dict(arrowstyle="-|>", color=color, lw=1.6, ls=ls, mutation_scale=16))


# ---------------------------------------------------------------- flow
def flow():
    fig, ax = plt.subplots(figsize=(12, 4.6))
    ax.set_xlim(0, 12); ax.set_ylim(0, 4.6); ax.axis("off")
    w, h = 2.3, 1.0
    top = [("Synthesized design", "gray_counter.ddc (Lab 2)", GREY),
           ("Setup + import", "Milkyway lib, SDC, TLU+", BLUE),
           ("Floorplan", "60% utilization, 7 rows", BLUE),
           ("Power plan", "VDD/VSS rings + straps", BLUE)]
    bot = [("Outputs", ".v netlist, .sbpf, reports", GREEN),
           ("Route", "fillers, route_opt, verify", ORNG),
           ("Clock tree", "clock_opt", ORNG),
           ("Placement", "place_opt", ORNG)]
    xs = [0.3, 3.25, 6.2, 9.15]
    for x, (t, s, c) in zip(xs, top):
        box(ax, x, 3.1, w, h, t, s, c, 12)
    for x, (t, s, c) in zip(xs, bot):
        box(ax, x, 0.7, w, h, t, s, c, 12)
    for i in range(3):
        arrow(ax, xs[i] + w + 0.03, 3.6, xs[i + 1] - 0.05, 3.6)
        arrow(ax, xs[i + 1] - 0.03, 1.2, xs[i] + w + 0.05, 1.2)
    arrow(ax, 9.15 + w / 2, 3.08, 9.15 + w / 2, 1.75)
    ax.text(9.15 + w / 2 + 0.12, 2.42, "create_fp_placement", fontsize=9.5, color=TXT, va="center")
    ax.text(6.2 + w / 2, 2.3, "save: gray4bcnt_cts_opt\n+ 4 reports", ha="center", fontsize=9.5, color=GREEN[1])
    ax.text(0.3 + w / 2, 2.3, "save: gray4bcnt_route\n+ 4 reports", ha="center", fontsize=9.5, color=GREEN[1])
    ax.text(3.25 + w / 2, 2.55, "save: gray4bcnt_init", ha="center", fontsize=9.5, color=GREEN[1])
    fig.savefig(OUT + "flow.png", dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)


# ---------------------------------------------------------------- block
def block():
    fig, ax = plt.subplots(figsize=(11, 4.4))
    ax.set_xlim(0, 11); ax.set_ylim(0, 4.4); ax.axis("off")
    box(ax, 2.7, 1.7, 2.8, 1.4, "Next-state logic", "case (gc_out)\n11 gates", ORNG, 13)
    box(ax, 6.6, 1.7, 2.0, 1.4, "gc_out_reg", "4 x DFFARX1\nasync reset", BLUE, 13)
    arrow(ax, 1.25, 2.65, 2.67, 2.65)
    ax.text(0.1, 2.65, "en_count", fontsize=11, va="center", color=TXT)
    arrow(ax, 5.53, 2.4, 6.57, 2.4)
    ax.text(6.05, 2.55, "next", fontsize=10, ha="center", color=TXT)
    ax.plot([8.62, 9.6], [2.4, 2.4], color=TXT, lw=1.6)
    ax.text(9.68, 2.4, "gc_out[3:0]", fontsize=11, va="center", color=TXT)
    # feedback
    ax.plot([9.1, 9.1, 4.25], [2.4, 3.75, 3.75], color=BLUE[1], lw=1.6, ls="--")
    arrow(ax, 4.25, 3.75, 4.25, 3.13, BLUE[1], "--")
    ax.text(6.7, 3.9, "current state picks the next state", fontsize=10, color=BLUE[1], ha="center")
    # clk / reset
    ax.plot([0.9, 7.3], [0.9, 0.9], color=TXT, lw=1.4); arrow(ax, 7.3, 0.9, 7.3, 1.67)
    ax.plot([0.9, 7.9], [0.5, 0.5], color="#A32D2D", lw=1.4); arrow(ax, 7.9, 0.5, 7.9, 1.67, "#A32D2D")
    ax.text(0.1, 0.9, "clk", fontsize=11, va="center", color=TXT)
    ax.text(0.1, 0.5, "reset_n", fontsize=11, va="center", color="#A32D2D")
    fig.savefig(OUT + "gc_block.png", dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)


# ---------------------------------------------------------------- waveform (worked out from the testbench)
def wave():
    T = 510
    fig, ax = plt.subplots(figsize=(12, 3.4))
    ax.set_xlim(-55, T + 5); ax.set_ylim(-0.6, 4.2); ax.axis("off")
    rows = {"clk": 3.5, "rstn": 2.5, "enc": 1.5, "gc_out": 0.4}
    for n, y in rows.items():
        ax.text(-50, y, n, fontsize=11, va="center", family="monospace", color=TXT)
    for t in range(10, T + 1, 20):
        ax.axvline(t, color="#E4E4E0", lw=0.8, zorder=0)
    # clock
    xs, ys, lvl = [0], [0], 0
    for t in range(10, T + 1, 10):
        xs += [t, t]; ys += [lvl, 1 - lvl]; lvl = 1 - lvl
    ax.plot(xs, [rows["clk"] - 0.3 + 0.6 * v for v in ys], color=TXT, lw=1.2)

    def dig(y, edges, col):
        xs, ys = [0], [edges[0][1]]
        for t, v in edges[1:]:
            xs += [t, t]; ys += [ys[-1], v]
        xs.append(T); ys.append(ys[-1])
        ax.plot(xs, [y - 0.3 + 0.6 * v for v in ys], color=col, lw=1.8)
    dig(rows["rstn"], [(0, 0), (30, 1)], "#A32D2D")
    dig(rows["enc"], [(0, 0), (70, 1), (230, 0), (270, 1)], BLUE[1])
    bus = [(0, "0"), (90, "1"), (110, "3"), (130, "2"), (150, "6"), (170, "7"), (190, "5"), (210, "4"),
           (230, "C"), (290, "D"), (310, "F"), (330, "E"), (350, "A"), (370, "B"), (390, "9"), (410, "8"),
           (430, "0"), (450, "1"), (470, "3"), (490, "2"), (510, "6")]
    y = rows["gc_out"]
    for i, (t0, v) in enumerate(bus):
        t1 = bus[i + 1][0] if i + 1 < len(bus) else T + 4
        k = 2.5
        px = [t0, t0 + k, t1 - k, t1, t1 - k, t0 + k, t0]
        py = [y, y + 0.3, y + 0.3, y, y - 0.3, y - 0.3, y]
        fc = ORNG[0] if v == "C" else BLUE[0]
        ax.fill(px, py, fc=fc, ec=BLUE[1], lw=1)
        if t1 - t0 > 8:
            ax.text((t0 + t1) / 2, y, v, ha="center", va="center", fontsize=9.5, color=BLUE[2])
    for t0, t1, s, c in [(0, 30, "reset", "#A32D2D"), (90, 230, "8 counts", BLUE[1]),
                         (230, 290, "hold", ORNG[1]), (290, 510, "12 counts, wraps through 0", BLUE[1])]:
        ax.annotate("", xy=(t1, -0.42), xytext=(t0, -0.42), arrowprops=dict(arrowstyle="<->", color=c, lw=1))
        ax.text((t0 + t1) / 2, -0.58, s, ha="center", va="top", fontsize=9, color=c)
    for t in (0, 100, 200, 300, 400, 500):
        ax.text(t, 4.05, f"{t} ns", ha="center", fontsize=8.5, color="#777")
    fig.savefig(OUT + "gc_wave.png", dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)


if __name__ == "__main__":
    flow(); block(); wave()
    print("done")
