# Fillet
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.

Glyph script that automatically generates quarter-circle topology in the plane of circular arcs such as those commonly found along the edges of a fillet.

## Operation
The main purpose of this script is to help expidite the manual generation of multi-block structured grids on fillets as seen in the figure below. This script requires the user to select at least one connector that defines the curved edge of a fillet. A quarter-OH topology is generated in the plane defined by each curve. This topology can then be extended (perhaps using the SqueezeCon script) to create the fillet blocks as pictured. 

To run, simply highlight connectors along the curved (short) edge of a fillet and execute the script (for versions >= 17.2R2), or execute the script and then select the connectors. Note that this currently works only with single connector fillet edges. Meaning, each connector selected will have its own corresponding topology.

![ScriptImage](https://raw.github.com/pointwise/Fillet/master/ScriptImage.png)

## Disclaimer
This file is licensed under the Cadence Public License Version 1.0 (the "License"), a copy of which is found in the LICENSE file, and is distributed "AS IS." 
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE. 
Please see the License for the full text of applicable terms.
	 

