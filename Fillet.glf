#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

#############################################################################
##
## Fillet.glf
##
## CREATE PARTIAL OH TOPOLOGY IN FILLET
## 
## This script automates the creation of an OH topology for each connector in a 
## selection of curves. First, the endpoints and midpoint of the curve are used 
## to locate the approximate center of the circle. Topology is then created to 
## generate a wedge-shaped region, which is then gridded using the TriQuad
## logic.
## 
## 
#############################################################################


package require PWI_Glyph 2

set maxR 1000
set input(Solve) 1
set input(AutoDim) 1
set input(Interp) 1

proc getMatrix {con} {

    set pt1 [$con getXYZ -arc 0.0]
    set pt2 [$con getXYZ -arc 0.5]
    set pt3 [$con getXYZ -arc 1.0]

    set matrix [list]
    for {set ii 0} {$ii<3} {incr ii} {
        lappend matrix [list [lindex $pt1 $ii] [lindex $pt2 $ii] [lindex $pt3 $ii]]
    }
    
    set a [expr abs([pwu::Vector3 length [pwu::Vector3 subtract $pt2 $pt3]])]
    set b [expr abs([pwu::Vector3 length [pwu::Vector3 subtract $pt1 $pt3]])]
    set c [expr abs([pwu::Vector3 length [pwu::Vector3 subtract $pt1 $pt2]])]

    set s [expr ($a+$b+$c)/2.]
    set R [expr $a*$b*$c/4/sqrt($s*($s-$a)*($s-$b)*($s-$c))]
    set b1 [expr $a*$a*($b*$b+$c*$c-$a*$a)]
    set b2 [expr $b*$b*($a*$a+$c*$c-$b*$b)]
    set b3 [expr $c*$c*($a*$a+$b*$b-$c*$c)]
    
    set vector [list $b1 $b2 $b3]
    set sum [expr $b1+$b2+$b3]

    return [list $matrix $vector $sum $R]

}

 ## matrixMultiplication:
 ##    Multiply a 3x3 matrix by a vector (or list of vectors), A*v
 ##
 ## Arguments:
 ##    matrix       Matrix to multiply
 ##    vector       Vector(s)
 ## Result:
 ##    Transformed vector (vector list)
 ## Note:
 ##    A vector list of 3 vectors is identical to a 3x3 matrix,
 ##    hence this procedure can be used for matrix multiplications too
 ##
 proc matrixMultiplication {matrix vector} {
    set n1 11
    set n2 12
    set n3 13
    foreach row $matrix {
       foreach [list m$n1 m$n2 m$n3] $row { break }
       incr n1 10
       incr n2 10
       incr n3 10
    }

    #
    # Add an extra level of list if there is only one vector
    #
    if { [llength [lindex $vector 0]] == 1 } {
       set vector [list $vector]
    }
    set output [list]
    foreach v $vector {
       foreach {x y z} $v { break }
       lappend output [list [expr {$m11*$x+$m12*$y+$m13*$z}] \
                       [expr {$m21*$x+$m22*$y+$m23*$z}] \
                       [expr {$m31*$x+$m32*$y+$m33*$z}] ]
    }
    return $output
 }

## Create two point connectors
proc createTwoPt { pt1 pt2 dim } {
    set creator [pw::Application begin Create]
    set con [pw::Connector create]
        set seg [pw::SegmentSpline create]
            $seg addPoint $pt1
            $seg addPoint $pt2
        $con addSegment $seg
    $creator end
    $con setDimension $dim
    return $con
}

## Calculate split locations for three connectors to create TriQuad domain
proc splitTri { conList } {
    set c1 [lindex $conList 0]
    set c2 [lindex $conList 1]
    set c3 [lindex $conList 2]
    
    set L1 [expr [$c1 getDimension] - 1 ]
    set L2 [expr [$c2 getDimension] - 1 ]
    set L3 [expr [$c3 getDimension] - 1 ]
    
    if { $L1 < [expr $L2 + $L3] } {
        set cond1 1
    } else { set cond1 0 }
    if { $L2 < [expr $L1 + $L3] } {
        set cond2 1
    } else { set cond2 0 }
    if { $L3 < [expr $L1 + $L2] } {
        set cond3 1
    } else { set cond3 0 }
    
    
    if { $cond1 && $cond2 && $cond3 } {
        set a [expr {($L1+$L3-$L2)/2. + 1}]
        set b [expr {($L1+$L2-$L3)/2. + 1}]
        set c [expr {($L2+$L3-$L1)/2. + 1}]
    
        if { $a == [expr int($a)] } {
            set cc1 1
            set a [expr int($a)]
        } else { set cc1 0 }
        if { $b == [expr int($b)] } {
            set cc2 1
            set b [expr int($b)]
        } else { set cc2 0 }
        if { $c == [expr int($c)] } {
            set cc3 1
            set c [expr int($c)]
        } else { set cc3 0 }
        
        if { $cc1 && $cc2 && $cc3 } {
            set sc1 [$c1 split -I $b]
            set sc2 [$c2 split -I $c]
            set sc3 [$c3 split -I $a]
            
            set pt1 [[lindex [lindex $sc1 1] 0] getXYZ -arc 0.0]
            set pt2 [[lindex [lindex $sc2 1] 0] getXYZ -arc 0.0]
            set pt3 [[lindex [lindex $sc3 1] 0] getXYZ -arc 0.0]
            
            lappend splCon [concat [lindex $sc1 0] [lindex $sc1 1]]
            lappend splCon [concat [lindex $sc2 0] [lindex $sc2 1]]
            lappend splCon [concat [lindex $sc3 0] [lindex $sc3 1]]
            
            return [list [list $a $b $c] [list $pt1 $pt2 $pt3] $splCon]
        } else { 
            ## dimensions not even
            return -1
        }
    } else {
        ## One dimension is too large
        return -2
    }
}

## Create domains
proc createTopo { pts dims outerCons } {
    global input

    set pt0 [lindex $pts 0]
    set pt1 [lindex $pts 1]
    set pt2 [lindex $pts 2]
    
    set temp1 [pwu::Vector3 add $pt0 $pt1]
    set temp2 [pwu::Vector3 add $temp1 $pt2]
    set cntr [pwu::Vector3 divide $temp2 3.0]
    
    set nc1 [createTwoPt $pt0 $cntr [lindex $dims 2]]
    set nc2 [createTwoPt $pt1 $cntr [lindex $dims 0]]
    set nc3 [createTwoPt $pt2 $cntr [lindex $dims 1]]
    
    set conList [list $nc1 $nc2 $nc3]
    foreach oc $outerCons {
        foreach c $oc {
            lappend conList $c
        }
    }
    
    set doms [pw::DomainStructured createFromConnectors $conList]
    
    if $input(Solve) {
        solve_Grid $cntr $doms 10
    } else {
        solve_Grid $cntr $doms 0
    }
    
    return $doms
}

## Run elliptic solver for 10 interations with floating BC on interior lines to 
## smooth grid
proc solve_Grid { cntr doms num } {
    global input
    
    set solver_mode [pw::Application begin EllipticSolver $doms]
        if {$input(Interp) == 1} {
            foreach ent $doms {
                foreach bc [list 1 2 3 4] {
                    $ent setEllipticSolverAttribute -edge $bc \
                        EdgeAngleCalculation Interpolate
                }
            }
        }
        
        for {set ii 0} {$ii<3} {incr ii} {
            set tempDom [lindex $doms $ii]
            set inds [list]
            for {set jj 1 } {$jj <= 4 } {incr jj} {
                set tmpEdge [$tempDom getEdge $jj]
                set n1 [$tmpEdge getNode Begin]
                set n2 [$tmpEdge getNode End]
                set c1 [pwu::Vector3 equal -tolerance 1e-6 [$n1 getXYZ] $cntr]
                set c2 [pwu::Vector3 equal -tolerance 1e-6 [$n2 getXYZ] $cntr]
                if { $c1 || $c2 } {
                    lappend inds [list $jj]
                }
            }
            set temp_list [list]
            for {set jj 0} {$jj < [llength $inds] } {incr jj} {
                lappend temp_list [list $tempDom]
            }
            foreach ent $temp_list bc $inds {
                $ent setEllipticSolverAttribute -edge $bc \
                    EdgeConstraint Floating
                $ent setEllipticSolverAttribute -edge $bc \
                    EdgeAngleCalculation Orthogonal
            }
        }
        
        $solver_mode run $num
    $solver_mode end
    
    return
}

## Set Info label
set text1 "Please select fillet connectors."
set mask [pw::Display createSelectionMask -requireConnector {} -requireDomain {}]

###############################################
## This script uses the getSelectedEntities command added in 17.2R2
## Catch statement should check for previous versions
if { [catch {pw::Display getSelectedEntities -selectionmask $mask curSelection}] } {
    set picked [pw::Display selectEntities -description $text1 -single\
        -selectionmask $mask curSelection]
    
    if {!$picked} {
        puts "Script aborted."
        exit
    }
} elseif { [llength $curSelection(Connectors)] == 0 } {
    set picked [pw::Display selectEntities -description $text1 -single\
        -selectionmask $mask curSelection]
    
    if {!$picked} {
        puts "Script aborted."
        exit
    }
}
###############################################

if {[llength $curSelection(Connectors)]>=1} {
    foreach con $curSelection(Connectors) {
        set temp [getMatrix $con]
        set matrix [lindex $temp 0]
        set vector [lindex $temp 1]
        set sum [lindex $temp 2]
        set R [lindex $temp 3]

        if {$R > $maxR} {
            set conName [$con getName]
            puts "$conName radius greater than tolerance: $maxR. Skipping..."
        } else {
        
            set cntr [lindex [matrixMultiplication $matrix $vector] 0]
            set cntr [pwu::Vector3 divide $cntr $sum]
            
            set conDim [$con getDimension]
            if {[expr $conDim%2]==0} {
                if $input(AutoDim) {
                    puts [format "Adjusting dimension of %s" [$con getName]]
                    $con setDimension [expr $conDim+1]
                } else {
                    puts [format "%s must have odd dimension." [$con getName]]
                }
                set conDim [$con getDimension]
            }
            set spoke1 [createTwoPt [$con getXYZ -arc 1.0] $cntr $conDim]
            set spoke2 [createTwoPt $cntr [$con getXYZ -arc 0.0] $conDim]
            
            set temp [splitTri [list $con $spoke1 $spoke2]]

            ## Check results of split
            if {$temp > 0} {
                set dims [lindex $temp 0]
                set pts [lindex $temp 1]
                set splCons [lindex $temp 2]
                
                set doms1 [createTopo $pts $dims $splCons]
            } elseif {$temp == -1} { 
                puts "Unable to match dimensions, check edge dimensions."
                puts "Sum of three connector dimensions must be odd."
            } else {
                puts "Unable to match dimensions, check edge dimensions."
                puts "No edge may have a dimension longer than the sum of the other two."
            }
        }
    }
} else {
    puts "Please select connectors along fillet edges."
}

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
