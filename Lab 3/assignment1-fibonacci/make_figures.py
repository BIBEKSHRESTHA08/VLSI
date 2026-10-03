"""Critical-path chain for Lab 3 / Assignment 1, same look as the Lab 2 figures."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

BLUE = ("#E6F0FA", "#1B5FA5", "#0E3F72")
ORNG = ("#FAEBDA", "#8A4C0E", "#6B3A08")
GREY = ("#F1EEE8", "#5E5D58", "#2A2A28")
TXT = "#444444"

# Lab 2 critical path (area run, typ corner): instance, cell, arrival time (ns)
stages = [("current_reg[1]", "DFFARX1", "0.19", BLUE),
          ("r53/U1_1", "FADDX1", "0.58", ORNG),
          ("r53/U1_2", "FADDX1", "0.85", ORNG),
          ("...", "11 more", "", None),
          ("r53/U1_14", "FADDX1", "4.07", ORNG),
          ("r53/U1_15", "XOR3X1", "4.21", ORNG),
          ("U27", "AO22X1", "4.32", GREY),
          ("OUT_reg[15]", "DFFARX1", "4.35", BLUE)]

fig, ax = plt.subplots(figsize=(13, 2.6))
ax.set_xlim(0, 13); ax.set_ylim(0, 2.6); ax.axis("off")
w, h, gap = 1.36, 1.0, 0.27
x = 0.15
for i, (inst, cell, t, c) in enumerate(stages):
    if c is None:
        ax.text(x + w / 2, 1.3, "...", ha="center", va="center", fontsize=20, color=TXT)
        ax.text(x + w / 2, 0.95, cell, ha="center", fontsize=9.5, color=TXT)
    else:
        ax.add_patch(FancyBboxPatch((x, 0.8), w, h, boxstyle="round,pad=0.02,rounding_size=0.1",
                                    fc=c[0], ec=c[1], lw=1.6))
        ax.text(x + w / 2, 1.45, inst, ha="center", va="center", fontsize=9.5, fontweight="bold", color=c[2])
        ax.text(x + w / 2, 1.12, cell, ha="center", va="center", fontsize=9.5, color=c[1])
        ax.text(x + w / 2, 0.5, t + " ns", ha="center", fontsize=9.5, color=TXT)
    if i < len(stages) - 1:
        ax.annotate("", xy=(x + w + gap - 0.03, 1.3), xytext=(x + w + 0.03, 1.3),
                    arrowprops=dict(arrowstyle="-|>", color=TXT, lw=1.3, mutation_scale=12))
    x += w + gap
ax.text(6.5, 2.35, "16-bit ripple-carry adder r53: one full adder per bit, carry passed along the row",
        ha="center", fontsize=10.5, color=ORNG[1])
ax.text(6.5, 0.12, "arrival times from the Lab 2 timing report (typical corner, no wires)",
        ha="center", fontsize=9, color="#777777")
fig.savefig("figures/fibo_path.png", dpi=150, bbox_inches="tight", facecolor="white")
