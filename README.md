# Fillet
Glyph script that automatically generates quarter-circle topology in the plane of circular arcs such as those commonly found along the edges of a fillet.

## Operation
The main purpose of this script is to help expidite the manual generation of multi-block structured grids on fillets as seen in the figure below. This script requires the user to select at least one connector that defines the curved edge of a fillet. A quarter-OH topology is generated in the plane defined by each curve. This topology can then be extended (perhaps using the SqueezeCon script) to create the fillet blocks as pictured. 

To run, simply highlight connectors along the curved (short) edge of a fillet and execute the script (for versions >= 17.2R2), or execute the script and then select the connectors. Note that this currently works only with single connector fillet edges. Meaning, each connector selected will have its own corresponding topology.

![ScriptImage](https://raw.github.com/pointwise/Fillet/master/ScriptImage.png)

## Disclaimer
Scripts are freely provided. They are not supported products of
Pointwise, Inc. Some scripts have been written and contributed by third
parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED
BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS
INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF
POINTWISE.
	 

