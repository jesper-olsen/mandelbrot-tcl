#!/usr/bin/env tclsh

# Default values
set width 100
set height 75
set png 0
set ll_x -1.2
set ll_y  0.20
set ur_x -1.0
set ur_y  0.35
set max_iter 255

# Parse command-line arguments like var=value
foreach arg $argv {
    if {[regexp {^([^=]+)=(.+)$} $arg -> var val]} {
        set $var $val
    }
}

proc cnt2char {value} {
    set symbols "MW2a_. "
    set ns [string length $symbols]
    set idx [expr {int($value / 255.0 * $ns)}]
    return [string index $symbols $idx]
}

proc escape_time {x y max_iter} {
    set zr 0.0
    set zi 0.0
    set cr $x
    set ci $y
    set iter 0

    while {$iter < $max_iter} {
        set zr2 [expr {$zr * $zr}]
        set zi2 [expr {$zi * $zi}]
        if {[expr {$zr2 + $zi2}] > 4.0} {
            break
        }
        set tmp [expr {$zr2 - $zi2 + $cr}]
        set zi [expr {2.0 * $zr * $zi + $ci}]
        set zr $tmp
        incr iter
    }

    return [expr {$max_iter - $iter}]
}

proc ascii_output {ll_x ll_y ur_x ur_y max_iter width height} {
    set fwidth  [expr {$ur_x - $ll_x}]
    set fheight [expr {$ur_y - $ll_y}]

    for {set y 0} {$y < $height} {incr y} {
        for {set x 0} {$x < $width} {incr x} {
            set real [expr {$ll_x + $x * $fwidth / $width}]
            set imag [expr {$ur_y - $y * $fheight / $height}]
            set iter [escape_time $real $imag $max_iter]
            puts -nonewline [cnt2char $iter]
        }
        puts ""
    }
}

proc gptext_output {ll_x ll_y ur_x ur_y max_iter width height} {
    set fwidth  [expr {$ur_x - $ll_x}]
    set fheight [expr {$ur_y - $ll_y}]

    for {set y $height} {$y > 0} {incr y -1} {
        set row ""
        for {set x 0} {$x < $width} {incr x} {
            set real [expr {$ll_x + $x * $fwidth / $width}]
            set imag [expr {$ur_y - $y * $fheight / $height}]
            set iter [escape_time $real $imag $max_iter]
            append row "[expr {$x > 0 ? ", " : ""}]$iter"
        }
        puts $row
    }
}

if {$png == 0} {
    ascii_output $ll_x $ll_y $ur_x $ur_y $max_iter $width $height
} else {
    gptext_output $ll_x $ll_y $ur_x $ur_y $max_iter $width $height
}

