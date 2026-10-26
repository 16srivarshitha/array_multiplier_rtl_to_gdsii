import os
import klayout.lay as lay
import klayout.db as db

GDS = "pnr/mult_array.gds"
LYP = "/foss/pdks/sky130A/libs.tech/klayout/tech/sky130A.lyp"

FULL_BOX = db.DBox(0, 0, 150, 150)       # whole die
ZOOM_BOX = db.DBox(48, 58, 76, 86)       

KEEP = {(67, 20): "li1", (67, 44): "mcon",
        (68, 20): "met1", (68, 44): "via",
        (69, 20): "met2", (69, 44): "via2",
        (70, 20): "met3", (70, 44): "via3"}

os.makedirs("report/img", exist_ok=True)

def make_view():
    lv = lay.LayoutView()
    lv.load_layout(GDS, True)
    if os.path.isfile(LYP):
        lv.load_layer_props(LYP)
    lv.max_hier()
    return lv

def only_wiring_layers(lv):
    it = lv.begin_layers()
    while not it.at_end():
        lp = it.current()
        if lp.source_layer >= 0:                       # skip group nodes
            lp.visible = (lp.source_layer, lp.source_datatype) in KEEP
            lv.set_layer_properties(it, lp)
        it.next()

def shot(box, out, wiring_only=False):
    lv = make_view()
    lv.set_config("text-visible", "false")             # hide pin/label text
    if wiring_only:
        only_wiring_layers(lv)
    lv.zoom_box(box)
    lv.save_image(out, 1600, 1600)
    print("saved", out)

shot(FULL_BOX, "report/img/layout_full.png")
shot(ZOOM_BOX, "report/img/layout_zoom.png", wiring_only=True)