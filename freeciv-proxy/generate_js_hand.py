#!/usr/bin/env python
# -*- coding: latin-1 -*-
''' 
 Freeciv - Copyright (C) 2009 - Andreas R�sdal   andrearo@pvv.ntnu.no
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
'''
 

import generate_packets

packets = generate_packets.gen_main();

f = open('packhand_gen.js', 'w');

f.write(""" /* Generated by generate_js_hand.py */
function client_handle_packet(p) 
{
 if (p == null) return;
 try {
  for (var i = 0; i < p.length; i++) {
    if (p[i] == null) continue;
    var packet_type = p[i]['pid'];
    switch (packet_type) {
""");

for packet in list(packets.values()):
  if not "sc" in packet.dirs: continue;
  f.write("\n    case  " + str(packet.type_number) + ":\n");  
  f.write("      handle_" + packet.type.lower().replace("packet_", "") + "(p[i]);\n      break;\n");

f.write(""" 
    }
  }
 
  if (p.length > 0) {
    if (debug_active) clinet_debug_collect();
    update_map_canvas_full();
  }

 } catch(e) {
   if (e.message != null && e.fileName != null && e.lineNumber != null) {
     js_breakpad_report(e.message, e.fileName, e.lineNumber);
   } else if (e.message != null) {
     js_breakpad_report(e.message, "generate_js_hand.py", 0);
   } else {
     js_breakpad_report("unknown network error", "generate_js_hand.py", 0);
   }
 }

}
""");


p = open('packets.js', 'w');

p.write(" /* Generated by generate_js_hand.py */ \n");
for packet in list(packets.values()):
  if not "cs" in packet.dirs: continue;
  p.write(" var " + packet.type.lower() + " = " + str(packet.type_number) + "\n");

