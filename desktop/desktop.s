        .setcpu "6502"

        .include "apple2.inc"
        .include "../inc/apple2.inc"
        .include "../inc/auxmem.inc"
        .include "../inc/prodos.inc"
        .include "../mgtk.inc"
        .include "../desktop.inc"
        .include "macros.inc"

;;; ==================================================
;;; DeskTop - the actual application
;;; ==================================================

INVOKER          := $290         ; Invoke other programs
INVOKER_FILENAME := $280         ; File to invoke (PREFIX must be set)

        dummy0000 := $0000         ; overwritten by self-modified code
        dummy1234 := $1234         ; overwritten by self-modified code

.macro MGTK_RELAY_CALL call, addr
    .if .paramcount > 1
        yax_call MGTK_RELAY, (call), (addr)
    .else
        yax_call MGTK_RELAY, (call), 0
    .endif
.endmacro

;;; ==================================================
;;; Segment loaded into AUX $851F-$BFFF (follows MGTK)
;;; ==================================================
.proc desktop_aux

        .org $851F

;;; ==================================================
;;; This chunk of code appears to be used by one or more
;;; of the dynamically loaded segments.

        .byte   $03
        .addr    $85E9

L8522:  php
        lda     $E904,x
        sta     $09
        ldy     #$14
        ldx     #$00
L852C:  lda     ($08),y
        sta     L8590,x
        iny
        inx
        cpx     #$04
        bne     L852C
        ldy     #$1C
        ldx     #$00
L853B:  lda     ($08),y
        sta     L8594,x
        iny
        inx
        cpx     #$04
        bne     L853B
        ldy     #$03
        lda     ($06),y
        sec
        sbc     L8590
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     L8591
        sta     ($06),y
        iny
        lda     ($06),y
        sec
        sbc     L8592
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     L8593
        sta     ($06),y
        ldy     #$03
        lda     ($06),y
        clc
        adc     L8594
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L8595
        sta     ($06),y
        iny
        lda     ($06),y
        clc
        adc     L8596
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L8597
        sta     ($06),y
        jsr     $83A5
        rts

L8590:  .byte   $24
L8591:  .byte   $00
L8592:  .byte   $23
L8593:  .byte   $00
L8594:  .byte   $00
L8595:  .byte   $00
L8596:  .byte   $00
L8597:  .byte   $00

        ldax    #0
L859C:  sta     $D409,x
        sta     $D401,x
        sta     $D40D
        inx
        cpx     #$04
        bne     L859C
        lda     #$0A
        sta     $D40D
        sta     $D40F

        MGTK_RELAY_CALL MGTK::SetPort, $D401
        rts

        addr_call $6B17, $1A39
        ldx     $D5CA
        txs
        rts

        addr_call $6B17, $1A56
        ldx     $D5CA
        txs
        rts

        addr_call $6B17, $1A71
        ldx     $D5CA
        txs
        rts

        cmp     #$27
        bne     L85F2
        addr_call $6B17, $1B22
        ldx     $D5CA
        txs
        jmp     L8625

L85F2:  cmp     #$45
        bne     L8604
        addr_call $6B17, $1B3B
        ldx     $D5CA
        txs
        jmp     L8625

L8604:  cmp     #$52
        bne     L8616
        addr_call $6B17, $1B5B
        ldx     $D5CA
        txs
        jmp     L8625

L8616:  cmp     #$57
        bne     L8625
        addr_call $6B17, $1B7C
        ldx     $D5CA
        txs
L8625:  MGTK_RELAY_CALL MGTK::HiliteMenu, winfo18_port ; ???
        rts

        addr_call $6B17, $1B9C
        ldx     $D5CA
        txs
        MGTK_RELAY_CALL MGTK::HiliteMenu, winfo18_port ; ???
        rts

        addr_call $6B17, $1BBF
        ldx     $D5CA
        txs
        MGTK_RELAY_CALL MGTK::HiliteMenu, winfo18_port ; ???
        rts

        sta     L8737
        sty     L8738
        and     #$F0
        sta     online_params_unit_num
        sta     ALTZPOFF
        MLI_CALL ON_LINE, online_params
        sta     ALTZPON
        beq     L867B
L8672:  pha
        dec     $EF8A
        dec     $EF88
        pla
        rts

L867B:  lda     online_params_buffer
        beq     L8672
        jsr     $8388      ; into dynamically loaded code???
        jsr     DESKTOP_FIND_SPACE ; AUX > MAIN call???
        ldy     L8738
        sta     $D464,y
        asl     a
        tax
        copy16  $F13A,x, $06
        ldx     #$00
        ldy     #$09
        lda     #' '
L869E:  sta     ($06),y
        iny
        inx
        cpx     #$12
        bne     L869E
        ldy     #$09
        lda     online_params_buffer
        and     #$0F
        sta     online_params_buffer
        sta     ($06),y
        ldx     #$00
        ldy     #$0B
L86B6:  lda     online_params_buffer+1,x
        cmp     #$41
        bcc     L86C4
        cmp     #$5F
        bcs     L86C4
        clc
        adc     #$20
L86C4:  sta     ($06),y
        iny
        inx
        cpx     online_params_buffer
        bne     L86B6
        ldy     #$09
        lda     ($06),y
        clc
        adc     #$02
        sta     ($06),y
        lda     L8737
        and     #$0F
        cmp     #$04
        bne     L86ED
        ldy     #$07
        lda     #$B4
        sta     ($06),y
        iny
        lda     #$14
        sta     ($06),y
        jmp     L870A

L86ED:  cmp     #$0B
        bne     L86FF
        ldy     #$07
        lda     #$70
        sta     ($06),y
        iny
        lda     #$14
        sta     ($06),y
        jmp     L870A

L86FF:  ldy     #$07
        lda     #$40
        sta     ($06),y
        iny
        lda     #$14
        sta     ($06),y
L870A:  ldy     #$02
        lda     #$00
        sta     ($06),y
        inc     L8738
        lda     L8738
        asl     a
        asl     a
        tax
        ldy     #$03
L871B:  lda     L8739,x
        sta     ($06),y
        inx
        iny
        cpy     #$07
        bne     L871B
        ldx     $EF8A
        dex
        ldy     #$00
        lda     ($06),y
        sta     $EF8B,x
        jsr     $83A5
        lda     #$00
        rts

L8737:  rts

L8738:  .byte   $04
L8739:  .byte   $00,$00,$00,$00

        ;; Desktop icon placements?
L873D:  DEFINE_POINT 500, 16
        DEFINE_POINT 500, 41
        DEFINE_POINT 500, 66
        DEFINE_POINT 500, 91
        DEFINE_POINT 500, 116

        DEFINE_POINT 440, 16
        DEFINE_POINT 440, 41
        DEFINE_POINT 440, 66
        DEFINE_POINT 440, 91
        DEFINE_POINT 440, 116
        DEFINE_POINT 440, 141

        DEFINE_POINT 400, 16
        DEFINE_POINT 400, 41
        DEFINE_POINT 400, 66

.proc online_params
count:  .byte   2
unit_num:       .byte   $60     ; Slot 6 Drive 1
data_buffer:    .addr   online_params_buffer
.endproc
        online_params_unit_num := online_params::unit_num

        ;; Per ProDOS TRM this should be 256 bytes!
online_params_buffer:
        .byte   $0B
        .byte   "GRAPHICS.TK",$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$C8

;;; ==================================================

        .assert * = $8800, error, "Entry point mismatch"
        .include "font.inc"

;;; ==================================================

        ;; ???

L8C83:  .byte   $00,$00,$00,$00,$77,$30,$01
        .byte   $00,$00,$7F,$00,$00,$7F,$00,$00
        .byte   $00,$00,$00,$7A,$00,$00,$00,$00
        .byte   $00,$14,$55,$2A,$00,$7F,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$01,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $0E,$00,$00,$07,$00,$00,$00,$00
        .byte   $00,$03,$18,$00,$00,$00,$00,$00
        .byte   $00,$00,$0E,$00,$00,$00,$00,$00

        .assert * = $8D02, error, "Segment length mismatch"
        PAD_TO $8E00

;;; ==================================================
;;; Entry point for "DESKTOP"
;;; ==================================================

        .assert * = DESKTOP, error, "DESKTOP entry point must be at $8E00"

        jmp     DESKTOP_DIRECT

;;; ==================================================

.macro MGTK_RELAY2_CALL call, addr
    .if .paramcount > 1
        yax_call MGTK_RELAY2, (call), (addr)
    .else
        yax_call MGTK_RELAY2, (call), 0
    .endif
.endmacro

.proc poly
num_vertices:   .byte   8
lastpoly:       .byte   0       ; 0 = last poly
vertices:
v0:     DEFINE_POINT 0, 0, v0
v1:     DEFINE_POINT 0, 0, v1
v2:     DEFINE_POINT 0, 0, v2
v3:     DEFINE_POINT 0, 0, v3
v4:     DEFINE_POINT 0, 0, v4
v5:     DEFINE_POINT 0, 0, v5
v6:     DEFINE_POINT 0, 0, v6
v7:     DEFINE_POINT 0, 0, v7
.endproc

.proc paintbits_params2
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   0
mapwidth:       .byte   0
reserved:       .byte   0
maprect:        DEFINE_RECT 0,0,0,0,maprect
.endproc

.proc paintbits_params
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   0
mapwidth:       .byte   0
reserved:       .byte   0
maprect:        DEFINE_RECT 0,0,0,0,maprect
.endproc

.proc paintrect_params6
left:   .word   0
top:    .word   0
right:  .word   0
bottom: .word   0
.endproc

.proc textwidth_params
textptr:        .addr   text_buffer
textlen:        .byte   0
result: .word   0
.endproc
set_text_mask_params    := textwidth_params::result + 1  ; re-used

.proc drawtext_params
textptr:        .addr   text_buffer
textlen:        .byte   0
.endproc

text_buffer:
        .res    19, 0

white_pattern:
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   $FF

black_pattern:
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   $FF

checkerboard_pattern2:
        .byte   %01010101
        .byte   %10101010
        .byte   %01010101
        .byte   %10101010
        .byte   %01010101
        .byte   %10101010
        .byte   %01010101
        .byte   %10101010
        .byte   $FF

dark_pattern:
        .byte   %00010001
        .byte   %01000100
        .byte   %00010001
        .byte   %01000100
        .byte   %00010001
        .byte   %01000100
        .byte   %00010001
        .byte   %01000100
        .byte   $FF

light_pattern:
        .byte   %11101110
        .byte   %10111011
        .byte   %11101110
        .byte   %10111011
        .byte   %11101110
        .byte   %10111011
        .byte   %11101110
        .byte   %10111011
L8E94:  .byte   $FF

;;; ==================================================
;;; Icon (i.e. file) details

;;; NOTE: Trash is icon #1

num_icons:  .byte   0
icon_table: .res    127, 0      ; index into icon_ptrs
icon_ptrs:  .res    256, 0      ; addresses of icon details (in $ED00)

has_highlight:                  ; 1 = has highlight, 0 = no highlight
        .byte   0
highlight_count:                ; number of highlighted icons
        .byte   $00
highlight_list:                 ; selected icons
        .res    127, 0

;;; Polygon holding the composite outlines of all icons
;;; being dragged.

drag_outline_buffer:
        .res    680, 0

;;; ==================================================

.proc peekevent_params
kind:   .byte   0               ; spills into next block
.endproc

.proc findwindow_params2
mousex: .word   0
mousey: .word   0
which_area:     .byte   0
window_id:      .byte   0
.endproc

        screen_width := 560
        screen_height := 192

.proc grafport
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, screen_width-1, screen_height-1
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   $96     ; ???
textbg: .byte   0
fontptr:        .addr   DEFAULT_FONT
.endproc

.proc getwinport_params
window_id:      .byte   0
a_grafport:     .addr   grafport4
.endproc

.proc grafport4
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   0
mapwidth:       .word   0
cliprect:       DEFINE_RECT 0, 0, 0, 0, cliprect
penpattern:     .res    8, 0
colormasks:     .byte   0, 0
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   0
penheight:      .byte   0
penmode:        .byte   0
textbg: .byte   0
fontptr:        .addr   0
.endproc

        .byte   $00,$00,$00
        .byte   $00,$FF,$80

        ;; Used for FILL_MODE params
pencopy_2:      .byte   0
penOR_2:        .byte   1
penXOR_2:       .byte   2
penBIC_2:       .byte   3
notpencopy_2:   .byte   4
notpenOR_2:     .byte   5
notpenXOR_2:    .byte   6
notpenBIC_2:    .byte   7

;;; ==================================================
;;; DESKTOP command jump table

L939E:  .addr   0               ; $00
        .addr   L9419           ; $01
        .addr   HIGHLIGHT_ICON_IMPL
        .addr   UNHIGHLIGHT_ICON_IMPL
        .addr   L9508           ; $04
        .addr   L95A2           ; $05
        .addr   L9692           ; $06
        .addr   CLOSE_WINDOW_IMPL
        .addr   L975B           ; $08
        .addr   FIND_ICON_IMPL
        .addr   L97F7           ; $0A
        .addr   L9EBE           ; $0B
        .addr   REDRAW_ICONS_IMPL
        .addr   ICON_IN_RECT_IMPL
        .addr   L958F           ; $0E

.macro  DESKTOP_DIRECT_CALL    op, addr, label
        jsr DESKTOP_DIRECT
        .byte   op
        .addr   addr
.endmacro

;;; DESKTOP entry point (after jump)

DESKTOP_DIRECT:

        ;; Stash return value from stack, adjust by 3
        ;; (command byte, params addr)
        pla
        sta     call_params
        clc
        adc     #<3
        tax
        pla
        sta     call_params+1
        adc     #>3
        pha
        txa
        pha

        ;; Save $06..$09 on the stack
        ldx     #0
:       lda     $06,x
        pha
        inx
        cpx     #4
        bne     :-

        ;; Point ($06) at call command
        lda     call_params
        clc
        adc     #<1
        sta     $06
        lda     call_params+1
        adc     #>1
        sta     $07

        ldy     #0
        lda     ($06),y
        asl     a
        tax
        copy16  L939E,x, dispatch + 1
        iny
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        sta     $07
        stx     $06

dispatch:
        jsr     dummy0000

        tay
        ldx     #$03
L9409:  pla
        sta     $06,x
        dex
        cpx     #$FF
        bne     L9409
        tya
        rts

call_params:  .addr     0

.proc moveto_params2
xcoord: .word   0
ycoord: .word   0
.endproc

;;; ==================================================

;;; DESKTOP $01 IMPL

.proc L9419
        ldy     #$00
        lda     ($06),y
        ldx     num_icons
        beq     L9430
        dex
L9423:  cmp     icon_table,x
        beq     L942D
        dex
        bpl     L9423
        bmi     L9430
L942D:  lda     #$01
        rts

L9430:  jsr     L943E
        jsr     L9F98
        lda     #$01
        tay
        sta     ($06),y
        lda     #$00
        rts

L943E:  ldx     num_icons
        sta     icon_table,x
        inc     num_icons
        asl     a
        tax
        copy16  $06, icon_ptrs,x
        rts
.endproc

;;; ==================================================
;;; HIGHLIGHT_ICON IMPL

.proc HIGHLIGHT_ICON_IMPL
        ldx     num_icons
        beq     bail1
        dex
        ldy     #$00
        lda     ($06),y
L945E:  cmp     icon_table,x
        beq     L9469
        dex
        bpl     L945E

bail1:  lda     #1
        rts

L9469:  asl     a
        tax
        copy16  icon_ptrs,x, $06
        ldy     #$01
        lda     ($06),y
        bne     L947E
        lda     #2
        rts

L947E:  lda     has_highlight
        beq     L9498
        dey
        lda     ($06),y
        ldx     highlight_count
        dex
L948A:  cmp     highlight_list,x
        beq     bail3
        dex
        bpl     L948A
        jmp     L949D

bail3:  lda     #3
        rts

L9498:  lda     #$01
        sta     has_highlight
L949D:  ldx     highlight_count
        ldy     #0
        lda     ($06),y
        sta     highlight_list,x
        inc     highlight_count
        lda     ($06),y
        ldx     #1
        jsr     LA324
        ldy     #0
        lda     ($06),y
        ldx     #1
        jsr     LA2E3
        jsr     L9F9F
        lda     #0
        rts
.endproc

;;; ==================================================
;;; UNHILIGHT_ICON IMPL

.proc UNHIGHLIGHT_ICON_IMPL
        ptr := $06

        ldx     num_icons
        beq     bail1
        dex
        ldy     #$00
        lda     (ptr),y
:       cmp     icon_table,x
        beq     found
        dex
        bpl     :-

bail1:  lda     #1
        rts

found:  asl     a
        tax
        copy16  icon_ptrs,x, ptr
        lda     has_highlight
        bne     L94E9
        jmp     done

L94E9:  ldx     highlight_count
        dex
        ldy     #$00
        lda     (ptr),y
L94F1:  cmp     highlight_list,x
        beq     L94FC
        dex
        bpl     L94F1
        jmp     done

L94FC:  jsr     L9F9F
        lda     #0
        rts

done:   jsr     L9F98
        lda     #0
        rts
.endproc

;;; ==================================================

;;; DESKTOP $04 IMPL

.proc L9508
        ptr := $6

        ;; Search for passed icon
        ldy     #0
        ldx     num_icons
        beq     bail1
        dex
        lda     (ptr),y
:       cmp     icon_table,x
        beq     found
        dex
        bpl     :-
bail1:  lda     #1
        rts

        ;; Pointer to icon details
found:  asl     a
        tax
        copy16  icon_ptrs,x, ptr
        ldy     #1              ; offset 1 is ... ???
        lda     (ptr),y
        bne     :+

        lda     #2
        rts

:       jsr     calc_icon_poly
        MGTK_CALL MGTK::SetPenMode, pencopy_2
        jsr     LA39D
        ldy     #0
        lda     (ptr),y
        ldx     num_icons
        jsr     LA2E3
        dec     num_icons
        lda     #0
        ldx     num_icons
        sta     icon_table,x
        ldy     #1
        lda     #0
        sta     (ptr),y
        lda     has_highlight
        beq     done

        ldx     highlight_count
        dex
        ldy     #0
        lda     (ptr),y
L9566:  cmp     highlight_list,x
        beq     L9571
        dex
        bpl     L9566

        jmp     done

L9571:  ldx     highlight_count
        jsr     LA324
        dec     highlight_count
        lda     highlight_count
        bne     L9584
        lda     #0
        sta     has_highlight
L9584:  lda     #0
        ldx     highlight_count
        sta     highlight_list,x

done:   lda     #0
        rts
.endproc

;;; ==================================================

;;; DESKTOP $0E IMPL

.proc L958F
        ldy     #$00
        lda     ($06),y
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        jmp     LA39D
.endproc

;;; ==================================================

;;; DESKTOP $05 IMPL

.proc L95A2
        jmp     start

        ;; DT_HIGHLIGHT_ICON params
icon:   .byte   0
buffer: .res    127, 0

start:  lda     HIGHLIGHT_ICON_IMPL ; ???
        beq     start2
        lda     highlight_list
        sta     icon
        DESKTOP_DIRECT_CALL $0B, icon
        jmp     start

start2:
        ;; zero out buffer
        ldx     #$7E
        lda     #0
:       sta     buffer,x
        dex
        bpl     :-
        ldx     #0
        stx     icon

L9648:  lda     icon_table,x
        asl     a
        tay
        copy16  icon_ptrs,y, $08
        ldy     #2
        lda     ($08),y
        and     #$0F
        ldy     #0
        cmp     ($06),y
        bne     L9670
        ldy     #0
        lda     ($08),y
        ldy     icon
        sta     buffer,y
        inc     icon
L9670:  inx
        cpx     num_icons
        bne     L9648
        ldx     #$00
        txa
        pha
L967A:  lda     buffer,x
        bne     L9681
        pla
        rts

L9681:  sta     icon
        DESKTOP_DIRECT_CALL DT_HIGHLIGHT_ICON, icon
        pla
        tax
        inx
        txa
        pha
        jmp     L967A
.endproc

;;; ==================================================

;;; DESKTOP $06 IMPL

.proc L9692
        jmp     L9697

L9695:  .byte   0
L9696:  .byte   0

L9697:  lda     num_icons
        sta     L9696
L969D:  ldx     L9696
        cpx     #$00
        beq     L96CF
        dec     L9696
        dex
        lda     icon_table,x
        sta     L9695
        asl     a
        tax
        copy16  icon_ptrs,x, $08
        ldy     #2
        lda     ($08),y
        and     #$0F
        ldy     #$00
        cmp     ($06),y
        bne     L969D
        DESKTOP_DIRECT_CALL $04, L9695
        jmp     L969D
L96CF:  lda     #$00
        rts
.endproc

;;; ==================================================
;;; CLOSE_WINDOW IMPL

.proc CLOSE_WINDOW_IMPL
        jmp     L96D7

L96D5:  .byte   0
L96D6:  .byte   0

L96D7:  lda     num_icons
        sta     L96D6
L96DD:  ldx     L96D6
        bne     L96E5
        lda     #$00
        rts

L96E5:  dec     L96D6
        dex
        lda     icon_table,x
        sta     L96D5
        asl     a
        tax
        copy16  icon_ptrs,x, $08
        ldy     #$02
        lda     ($08),y
        and     #$0F
        ldy     #$00
        cmp     ($06),y
        bne     L96DD
        ldy     #$00
        lda     ($08),y
        ldx     num_icons
        jsr     LA2E3
        dec     num_icons
        lda     #$00
        ldx     num_icons
        sta     icon_table,x
        ldy     #$01
        lda     #$00
        sta     ($08),y
        lda     has_highlight
        beq     L9758
        ldx     #$00
        ldy     #$00
L972B:  lda     ($08),y
        cmp     highlight_list,x
        beq     L973B
        inx
        cpx     highlight_count
        bne     L972B
        jmp     L9758

L973B:  lda     ($08),y
        ldx     highlight_count
        jsr     LA324
        dec     highlight_count
        lda     highlight_count
        bne     L9750
        lda     #$00
        sta     has_highlight
L9750:  lda     #$00
        ldx     highlight_count
        sta     highlight_list,x
L9758:  jmp     L96DD
.endproc

;;; ==================================================

;;; DESKTOP $08 IMPL

.proc L975B
        ldx     #$00
        txa
        tay
L975F:  sta     ($06),y
        iny
        inx
        cpx     #$14
        bne     L975F
        ldx     #$00
        ldy     #$00
L976B:  lda     highlight_list,x
        sta     ($06),y
        cpx     highlight_count
        beq     L977A
        iny
        inx
        jmp     L976B

L977A:  lda     #$00
        rts
.endproc

;;; ==================================================
;;; FIND_ICON IMPL

.proc FIND_ICON_IMPL
        jmp     start

        .res    9, 0            ; ???


        coords := $6

        ;; Copy coords at $6 to param block
start:  ldy     #3
:       lda     (coords),y
        sta     moveto_params2,y
        dey
        bpl     :-

        ;; Overwrite y with x ???
        copy16  $06, $08

        ;; ???
        ldy     #$05
        lda     ($06),y
        sta     L97F5
        MGTK_CALL MGTK::MoveTo, moveto_params2
        ldx     #$00
L97AA:  cpx     num_icons
        bne     L97B9
        ldy     #$04
        lda     #$00
        sta     ($08),y
        sta     L97F6
        rts

L97B9:  txa
        pha
        lda     icon_table,x
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        cmp     L97F5
        bne     L97E0
        jsr     calc_icon_poly
        MGTK_CALL MGTK::InPoly, poly
        bne     inside
L97E0:  pla
        tax
        inx
        jmp     L97AA

inside: pla
        tax
        lda     icon_table,x
        ldy     #$04
        sta     ($08),y
        sta     L97F6
        rts

        rts                     ; ???

        .byte   0
L97F5:  .byte   0
L97F6:  .byte   0
.endproc

;;; ==================================================

;;; DESKTOP $0A IMPL

.proc L97F7
        ldy     #0
        lda     ($06),y
        sta     L982A
        tya
        sta     ($06),y
        ldy     #4
L9803:  lda     ($06),y
        sta     L9C8D,y
        sta     L9C91,y
        dey
        cpy     #0
        bne     L9803
        jsr     push_zp_addrs
        lda     L982A
        jsr     L9EB4
        stax    $06
        ldy     #2
        lda     ($06),y
        and     #$0F
        sta     L9829
        jmp     L983D

L9829:  .byte   $00
L982A:  .byte   $00,$00
L982C:  .byte   $00
L982D:  .byte   $00
L982E:  .byte   $00
L982F:  .byte   $00

        ;; DT_HIGHLIGHT_ICON params
L9830:  .byte   $00

L9831:  .byte   $00
L9832:  .byte   $00
L9833:  .byte   $00
L9834:  .byte   $00
L9835:  .byte   $00,$00,$00,$00,$00,$00,$00,$00

L983D:  lda     #0
        sta     L9830
        sta     L9833
L9845:  MGTK_CALL MGTK::PeekEvent, peekevent_params
        lda     peekevent_params::kind
        cmp     #MGTK::event_kind_drag
        beq     L9857
L9852:  lda     #$02
        jmp     L9C65

L9857:  sub16   findwindow_params2::mousex, L9C8E, L982C
        sub16   findwindow_params2::mousey, L9C90, L982E

        lda     L982D
        bpl     L988C
        lda     L982C
        cmp     #$FB
        bcc     L98AC
        jmp     L9893

L988C:  lda     L982C
        cmp     #$05
        bcs     L98AC
L9893:  lda     L982F
        bpl     L98A2
        lda     L982E
        cmp     #$FB
        bcc     L98AC
        jmp     L9845

L98A2:  lda     L982E
        cmp     #$05
        bcs     L98AC
        jmp     L9845

L98AC:  lda     highlight_count
        cmp     #$15
        bcc     L98B6
        jmp     L9852

L98B6:  copy16  #drag_outline_buffer, $08
        lda     has_highlight
        bne     L98C8
        lda     #$03
        jmp     L9C65

L98C8:  lda     highlight_list
        jsr     L9EB4
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        sta     L9832
        MGTK_CALL MGTK::InitPort, grafport
        ldx     #$07
L98E3:  lda     grafport::cliprect,x
        sta     L9835,x
        dex
        bpl     L98E3
        ldx     highlight_count
        stx     L9C74
L98F2:  lda     highlight_count,x
        jsr     L9EB4
        stax    $06
        ldy     #$00
        lda     ($06),y
        cmp     #$01
        bne     L9909
        ldx     #$80
        stx     L9833
L9909:  sta     L9834
        DESKTOP_DIRECT_CALL DT_ICON_IN_RECT, L9834
        beq     L9954
        jsr     calc_icon_poly
        lda     L9C74
        cmp     highlight_count
        beq     L9936
        jsr     push_zp_addrs
        lda     $08
        sec
        sbc     #$22
        sta     $08
        bcs     L992D
        dec     $08+1
L992D:  ldy     #$01
        lda     #$80
        sta     ($08),y
        jsr     pop_zp_addrs
L9936:  ldx     #$21
        ldy     #$21
L993A:  lda     poly,x
        sta     ($08),y
        dey
        dex
        bpl     L993A
        lda     #$08
        ldy     #$00
        sta     ($08),y
        lda     $08
        clc
        adc     #$22
        sta     $08
        bcc     L9954
        inc     $08+1
L9954:  dec     L9C74
        beq     L995F
        ldx     L9C74
        jmp     L98F2

L995F:  ldx     #$07
L9961:  lda     drag_outline_buffer+2,x
        sta     L9C76,x
        dex
        bpl     L9961
        copy16  #drag_outline_buffer, $08
L9972:  ldy     #$02
L9974:  lda     ($08),y
        cmp     L9C76
        iny
        lda     ($08),y
        sbc     L9C77
        bcs     L9990
        lda     ($08),y
        sta     L9C77
        dey
        lda     ($08),y
        sta     L9C76
        iny
        jmp     L99AA

L9990:  dey
        lda     ($08),y
        cmp     L9C7A
        iny
        lda     ($08),y
        sbc     L9C7B
        bcc     L99AA
        lda     ($08),y
        sta     L9C7B
        dey
        lda     ($08),y
        sta     L9C7A
        iny
L99AA:  iny
        lda     ($08),y
        cmp     L9C78
        iny
        lda     ($08),y
        sbc     L9C79
        bcs     L99C7
        lda     ($08),y
        sta     L9C79
        dey
        lda     ($08),y
        sta     L9C78
        iny
        jmp     L99E1

L99C7:  dey
        lda     ($08),y
        cmp     L9C7C
        iny
        lda     ($08),y
        sbc     L9C7D
        bcc     L99E1
        lda     ($08),y
        sta     L9C7D
        dey
        lda     ($08),y
        sta     L9C7C
        iny
L99E1:  iny
        cpy     #$22
        bne     L9974
        ldy     #$01
        lda     ($08),y
        beq     L99FC
        add16 $08, #$22, $08
        jmp     L9972

L99FC:  MGTK_CALL MGTK::SetPattern, checkerboard_pattern2
        MGTK_CALL MGTK::SetPenMode, penXOR_2
        MGTK_CALL MGTK::FramePoly, drag_outline_buffer
L9A0E:  MGTK_CALL MGTK::PeekEvent, peekevent_params
        lda     peekevent_params::kind
        cmp     #MGTK::event_kind_drag
        beq     L9A1E
        jmp     L9BA5

L9A1E:  ldx     #3
L9A20:  lda     findwindow_params2,x
        cmp     L9C92,x
        bne     L9A31
        dex
        bpl     L9A20
        jsr     L9E14
        jmp     L9A0E

L9A31:  ldx     #$03
L9A33:  lda     findwindow_params2,x
        sta     L9C92,x
        dex
        bpl     L9A33
        lda     L9830
        beq     L9A84
        lda     L9831
        sta     findwindow_params2::window_id
        DESKTOP_DIRECT_CALL DT_FIND_ICON, findwindow_params2
        lda     findwindow_params2::which_area
        cmp     L9830
        beq     L9A84
        MGTK_CALL MGTK::SetPattern, checkerboard_pattern2
        MGTK_CALL MGTK::SetPenMode, penXOR_2
        MGTK_CALL MGTK::FramePoly, drag_outline_buffer
        DESKTOP_DIRECT_CALL $0B, L9830
        MGTK_CALL MGTK::SetPattern, checkerboard_pattern2
        MGTK_CALL MGTK::SetPenMode, penXOR_2
        MGTK_CALL MGTK::FramePoly, drag_outline_buffer
        lda     #$00
        sta     L9830
L9A84:  sub16 findwindow_params2::mousex, L9C8E, L9C96
        sub16 findwindow_params2::mousey, L9C90, L9C98
        jsr     L9C9E
        ldx     #$00
L9AAF:  lda     L9C7A,x
        clc
        adc     L9C96,x
        sta     L9C7A,x
        lda     L9C7B,x
        adc     L9C97,x
        sta     L9C7B,x
        lda     L9C76,x
        clc
        adc     L9C96,x
        sta     L9C76,x
        lda     L9C77,x
        adc     L9C97,x
        sta     L9C77,x
        inx
        inx
        cpx     #$04
        bne     L9AAF
        lda     #$00
        sta     L9C75
        lda     L9C77
        bmi     L9AF7
        lda     L9C7A
        cmp     #$30
        lda     L9C7B
        sbc     #$02
        bcs     L9AFE
        jsr     L9DFA
        jmp     L9B0E

L9AF7:  jsr     L9CAA
        bmi     L9B0E
        bpl     L9B03
L9AFE:  jsr     L9CD1
        bmi     L9B0E
L9B03:  jsr     L9DB8
        lda     L9C75
        ora     #$80
        sta     L9C75
L9B0E:  lda     L9C79
        bmi     L9B31
        lda     L9C78
        cmp     #$0D
        lda     L9C79
        sbc     #$00
        bcc     L9B31
        lda     L9C7C
        cmp     #$C0
        lda     L9C7D
        sbc     #$00
        bcs     L9B38
        jsr     L9E07
        jmp     L9B48

L9B31:  jsr     L9D31
        bmi     L9B48
        bpl     L9B3D
L9B38:  jsr     L9D58
        bmi     L9B48
L9B3D:  jsr     L9DD9
        lda     L9C75
        ora     #$40
        sta     L9C75
L9B48:  bit     L9C75
        bpl     L9B52
        bvc     L9B52
        jmp     L9A0E

L9B52:  MGTK_CALL MGTK::FramePoly, drag_outline_buffer
        copy16  #drag_outline_buffer, $08
L9B60:  ldy     #$02
L9B62:  lda     ($08),y
        clc
        adc     L9C96
        sta     ($08),y
        iny
        lda     ($08),y
        adc     L9C97
        sta     ($08),y
        iny
        lda     ($08),y
        clc
        adc     L9C98
        sta     ($08),y
        iny
        lda     ($08),y
        adc     L9C99
        sta     ($08),y
        iny
        cpy     #$22
        bne     L9B62
        ldy     #$01
        lda     ($08),y
        beq     L9B9C
        lda     $08
        clc
        adc     #$22
        sta     $08
        bcc     L9B99
        inc     $08+1
L9B99:  jmp     L9B60

L9B9C:  MGTK_CALL MGTK::FramePoly, drag_outline_buffer
        jmp     L9A0E

L9BA5:  MGTK_CALL MGTK::FramePoly, drag_outline_buffer
        lda     L9830
        beq     L9BB9
        DESKTOP_DIRECT_CALL $0B, L9830
        jmp     L9C63

L9BB9:  MGTK_CALL MGTK::FindWindow, findwindow_params2
        lda     findwindow_params2::window_id
        cmp     L9832
        beq     L9BE1
        bit     L9833
        bmi     L9BDC
        lda     findwindow_params2::window_id
        bne     L9BD4
L9BD1:  jmp     L9852

L9BD4:  ora     #$80
        sta     L9830
        jmp     L9C63

L9BDC:  lda     L9832
        beq     L9BD1
L9BE1:  jsr     push_zp_addrs
        MGTK_CALL MGTK::InitPort, grafport
        MGTK_CALL MGTK::SetPort, grafport
        ldx     highlight_count
L9BF3:  dex
        bmi     L9C18
        txa
        pha
        lda     highlight_list,x
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        jsr     calc_icon_poly
        MGTK_CALL MGTK::SetPenMode, pencopy_2
        jsr     LA39D
        pla
        tax
        jmp     L9BF3

L9C18:  jsr     pop_zp_addrs
        ldx     highlight_count
        dex
        txa
        pha
        copy16  #drag_outline_buffer, $08
L9C29:  lda     highlight_list,x
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        ldy     #$02
        lda     ($08),y
        iny
        sta     ($06),y
        lda     ($08),y
        iny
        sta     ($06),y
        lda     ($08),y
        iny
        sta     ($06),y
        lda     ($08),y
        iny
        sta     ($06),y
        pla
        tax
        dex
        bmi     L9C63
        txa
        pha
        lda     $08
        clc
        adc     #$22
        sta     $08
        bcc     L9C60
        inc     $08+1
L9C60:  jmp     L9C29

L9C63:  lda     #$00
L9C65:  tay
        jsr     pop_zp_addrs
        tya
        tax
        ldy     #$00
        lda     L9830
        sta     ($06),y
        txa
        rts

L9C74:  .byte   $00
L9C75:  .byte   $00
L9C76:  .byte   $00
L9C77:  .byte   $00
L9C78:  .byte   $00
L9C79:  .byte   $00
L9C7A:  .byte   $00
L9C7B:  .byte   $00
L9C7C:  .byte   $00
L9C7D:  .byte   $00
L9C7E:  .byte   $00
L9C7F:  .byte   $00
L9C80:  .byte   $0D
L9C81:  .byte   $00
L9C82:  .byte   $30
L9C83:  .byte   $02
L9C84:  .byte   $C0
L9C85:  .byte   $00
L9C86:  .byte   $00
L9C87:  .byte   $00
L9C88:  .byte   $00
L9C89:  .byte   $00
L9C8A:  .byte   $00
L9C8B:  .byte   $00
L9C8C:  .byte   $00
L9C8D:  .byte   $00
L9C8E:  .byte   $00
L9C8F:  .byte   $00
L9C90:  .byte   $00
L9C91:  .byte   $00
L9C92:  .byte   $00,$00,$00,$00
L9C96:  .byte   $00
L9C97:  .byte   $00
L9C98:  .byte   $00
L9C99:  .byte   $00,$00,$00,$00,$00
L9C9E:  ldx     #$07
L9CA0:  lda     L9C76,x
        sta     L9C86,x
        dex
        bpl     L9CA0
        rts

L9CAA:  lda     L9C76
        cmp     L9C7E
        bne     L9CBD
        lda     L9C77
        cmp     L9C7F
        bne     L9CBD
        lda     #$00
        rts

L9CBD:  lda     #$00
        sec
        sbc     L9C86
        sta     L9C96
        lda     #$00
        sbc     L9C87
        sta     L9C97
        jmp     L9CF5

L9CD1:  lda     L9C7A
        cmp     L9C82
        bne     L9CE4
        lda     L9C7B
        cmp     L9C83
        bne     L9CE4
        lda     #$00
        rts

L9CE4:  lda     #$30
        sec
        sbc     L9C8A
        sta     L9C96
        lda     #$02
        sbc     L9C8B
        sta     L9C97
L9CF5:  add16 L9C86, L9C96, L9C76
        add16 L9C8A, L9C96, L9C7A
        add16 L9C8E, L9C96, L9C8E
        lda     #$FF
        rts

L9D31:  lda     L9C78
        cmp     L9C80
        bne     L9D44
        lda     L9C79
        cmp     L9C81
        bne     L9D44
        lda     #$00
        rts

L9D44:  lda     #$0D
        sec
        sbc     L9C88
        sta     L9C98
        lda     #$00
        sbc     L9C89
        sta     L9C99
        jmp     L9D7C

L9D58:  lda     L9C7C
        cmp     L9C84
        bne     L9D6B
        lda     L9C7D
        cmp     L9C85
        bne     L9D6B
        lda     #$00
        rts

L9D6B:  lda     #$BF
        sec
        sbc     L9C8C
        sta     L9C98
        lda     #$00
        sbc     L9C8D
        sta     L9C99
L9D7C:  add16 L9C88, L9C98, L9C78
        add16 L9C8C, L9C98, L9C7C
        add16 L9C90, L9C98, L9C90
        lda     #$FF
        rts

L9DB8:  lda     L9C86
        sta     L9C76
        lda     L9C87
        sta     L9C77
        lda     L9C8A
        sta     L9C7A
        lda     L9C8B
        sta     L9C7B
        lda     #$00
        sta     L9C96
        sta     L9C97
        rts

L9DD9:  lda     L9C88
        sta     L9C78
        lda     L9C89
        sta     L9C79
        lda     L9C8C
        sta     L9C7C
        lda     L9C8D
        sta     L9C7D
        lda     #$00
        sta     L9C98
        sta     L9C99
        rts

L9DFA:  lda     findwindow_params2::mousex+1
        sta     L9C8F
        lda     findwindow_params2::mousex
        sta     L9C8E
        rts

L9E07:  lda     findwindow_params2::mousey+1
        sta     L9C91
        lda     findwindow_params2::mousey
        sta     L9C90
        rts

L9E14:  bit     L9833
        bpl     L9E1A
        rts

L9E1A:  jsr     push_zp_addrs
        MGTK_CALL MGTK::FindWindow, findwindow_params2
        lda     findwindow_params2::which_area
        bne     L9E2B
        sta     findwindow_params2::window_id
L9E2B:  DESKTOP_DIRECT_CALL DT_FIND_ICON, findwindow_params2
        lda     findwindow_params2::which_area
        bne     L9E39
        jmp     L9E97

L9E39:  ldx     highlight_count
        dex
L9E3D:  cmp     highlight_list,x
        beq     L9E97
        dex
        bpl     L9E3D
        sta     L9EB3
        cmp     #$01
        beq     L9E6A
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        sta     L9831
        lda     ($06),y
        and     #$70
        bne     L9E97
        lda     L9EB3
L9E6A:  sta     L9830
        MGTK_CALL MGTK::SetPattern, checkerboard_pattern2
        MGTK_CALL MGTK::SetPenMode, penXOR_2
        MGTK_CALL MGTK::FramePoly, drag_outline_buffer
        DESKTOP_DIRECT_CALL DT_HIGHLIGHT_ICON, L9830
        MGTK_CALL MGTK::SetPattern, checkerboard_pattern2
        MGTK_CALL MGTK::SetPenMode, penXOR_2
        MGTK_CALL MGTK::FramePoly, drag_outline_buffer
L9E97:  MGTK_CALL MGTK::InitPort, grafport
        MGTK_CALL MGTK::SetPort, grafport
        MGTK_CALL MGTK::SetPattern, checkerboard_pattern2
        MGTK_CALL MGTK::SetPenMode, penXOR_2
        jsr     pop_zp_addrs
        rts

L9EB3:  .byte   0
L9EB4:  asl     a
        tay
        lda     icon_ptrs+1,y
        tax
        lda     icon_ptrs,y
        rts
.endproc

;;; ==================================================

;;; DESKTOP $0B IMPL

.proc L9EBE
        jmp     start

        .byte   0               ; ???

        ;; DT_UNHIGHLIGHT_ICON params
icon:   .byte   0

        ptr := $6

start:  lda     has_highlight
        bne     :+
        lda     #1
        rts

:       ldx     highlight_count
        ldy     #0
        lda     (ptr),y
        jsr     LA324
        ldx     highlight_count
        lda     #0
        sta     highlight_count,x
        dec     highlight_count
        lda     highlight_count
        bne     L9EEA
        lda     #$00
        sta     has_highlight
L9EEA:  ldy     #0
        lda     (ptr),y
        sta     icon
        DESKTOP_DIRECT_CALL DT_UNHIGHLIGHT_ICON, icon
        lda     #0
        rts

        rts
.endproc

;;; ==================================================
;;; ICON_IN_RECT IMPL

.proc ICON_IN_RECT_IMPL
        jmp     start

icon:   .byte   0
rect:   DEFINE_RECT 0,0,0,0,rect

start:  ldy     #0
        lda     ($06),y
        sta     icon
        ldy     #8
:       lda     ($06),y
        sta     rect-1,y
        dey
        bne     :-

        lda     icon
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        jsr     calc_icon_poly

        lda     poly::v0::ycoord
        cmp     rect::y2
        lda     poly::v0::ycoord+1
        sbc     rect::y2+1
        bpl     done

        lda     poly::v5::ycoord
        cmp     rect::y1
        lda     poly::v5::ycoord+1
        sbc     rect::y1+1
        bmi     done

        lda     poly::v5::xcoord
        cmp     rect::x2
        lda     poly::v5::xcoord+1
        sbc     rect::x2+1
        bpl     done

        lda     poly::v4::xcoord
        cmp     rect::x1
        lda     poly::v4::xcoord+1
        sbc     rect::x1+1
        bmi     done

        lda     poly::v7::ycoord
        cmp     rect::y2
        lda     poly::v7::ycoord+1
        sbc     rect::y2+1
        bmi     L9F8F

        lda     poly::v7::xcoord
        cmp     rect::x2
        lda     poly::v7::xcoord+1
        sbc     rect::x2+1
        bpl     done

        lda     poly::v2::xcoord
        cmp     rect::x1
        lda     poly::v2::xcoord+1
        sbc     rect::x1+1
        bpl     L9F8F

done:   lda     #0
        rts

L9F8F:  lda     #$01
        rts
.endproc

;;; ==================================================

L9F92:  .byte   0
L9F93:  .byte   0
L9F94:  .byte   0
        .byte   0
        .byte   0
        .byte   0

L9F98:  lda     #$00
        sta     L9F92
        beq     L9FA4
L9F9F:  lda     #$80
        sta     L9F92
L9FA4:  ldy     #$02
        lda     ($06),y
        and     #$0F
        bne     L9FB4
        lda     L9F92
        ora     #$40
        sta     L9F92
L9FB4:  ldy     #$03
L9FB6:  lda     ($06),y
        sta     poly::v7::xcoord+1,y
        iny
        cpy     #$09
        bne     L9FB6
        jsr     push_zp_addrs
        copy16  paintbits_params2::mapbits, $08
        ldy     #$0B
L9FCF:  lda     ($08),y
        sta     paintbits_params2::mapbits,y
        dey
        bpl     L9FCF
        bit     L9F92
        bpl     L9FDF
        jsr     LA12C
L9FDF:  jsr     pop_zp_addrs
        ldy     #$09
L9FE4:  lda     ($06),y
        sta     paintrect_params6::bottom,y
        iny
        cpy     #$1D
        bne     L9FE4
:       lda     drawtext_params::textlen
        sta     textwidth_params::textlen
        MGTK_CALL MGTK::TextWidth, textwidth_params
        lda     textwidth_params::result
        cmp     paintbits_params2::maprect::x2
        bcs     :+
        inc     drawtext_params::textlen
        ldx     drawtext_params::textlen
        lda     #' '
        sta     text_buffer-1,x
        jmp     :-

:       lsr     a
        sta     moveto_params2::xcoord+1
        lda     paintbits_params2::maprect::x2
        lsr     a
        sta     moveto_params2
        lda     moveto_params2::xcoord+1
        sec
        sbc     moveto_params2::xcoord
        sta     moveto_params2::xcoord
        lda     paintbits_params2::viewloc::xcoord
        sec
        sbc     moveto_params2::xcoord
        sta     moveto_params2::xcoord
        lda     paintbits_params2::viewloc::xcoord+1
        sbc     #$00
        sta     moveto_params2::xcoord+1
        add16_8 paintbits_params2::viewloc::ycoord, paintbits_params2::maprect::y2, moveto_params2::ycoord
        add16 moveto_params2::ycoord, #1, moveto_params2::ycoord
        add16_8 moveto_params2::ycoord, font_height, moveto_params2::ycoord
        ldx     #$03
LA06E:  lda     moveto_params2,x
        sta     L9F94,x
        dex
        bpl     LA06E
        bit     L9F92
        bvc     LA097
        MGTK_CALL MGTK::InitPort, grafport
        jsr     LA63F
LA085:  jsr     LA6A3
        jsr     LA097
        lda     L9F93
        bne     LA085
        MGTK_CALL MGTK::SetPortBits, grafport
        rts

LA097:  MGTK_CALL MGTK::HideCursor, DESKTOP_DIRECT ; These params should be ignored - bogus?
        MGTK_CALL MGTK::SetPenMode, notpencopy_2
        bit     L9F92
        bpl     LA0C2
        bit     L9F92
        bvc     LA0B6
        MGTK_CALL MGTK::SetPenMode, pencopy_2
        jmp     LA0C2

LA0B6:  MGTK_CALL MGTK::PaintBits, paintbits_params
        MGTK_CALL MGTK::SetPenMode, penXOR_2
LA0C2:  MGTK_CALL MGTK::PaintBits, paintbits_params2
        ldy     #$02
        lda     ($06),y
        and     #$80
        beq     LA0F2
        jsr     LA14D
        MGTK_CALL MGTK::SetPattern, dark_pattern
        bit     L9F92
        bmi     LA0E6
        MGTK_CALL MGTK::SetPenMode, penBIC_2
        beq     LA0EC
LA0E6:  MGTK_CALL MGTK::SetPenMode, penOR_2
LA0EC:  MGTK_CALL MGTK::PaintRect, paintrect_params6
LA0F2:  ldx     #$03
LA0F4:  lda     L9F94,x
        sta     moveto_params2,x
        dex
        bpl     LA0F4
        MGTK_CALL MGTK::MoveTo, moveto_params2
        bit     L9F92
        bmi     LA10C
        lda     #$7F
        bne     LA10E
LA10C:  lda     #$00
LA10E:  sta     set_text_mask_params
        MGTK_CALL MGTK::SetTextBG, set_text_mask_params
        lda     text_buffer+1
        and     #$DF
        sta     text_buffer+1
        MGTK_CALL MGTK::DrawText, drawtext_params
        MGTK_CALL MGTK::ShowCursor
        rts

LA12C:  ldx     #$0F
LA12E:  lda     paintbits_params2,x
        sta     paintbits_params,x
        dex
        bpl     LA12E
        ldy     paintbits_params::maprect::y2
LA13A:  lda     paintbits_params::mapwidth
        clc
        adc     paintbits_params::mapbits
        sta     paintbits_params::mapbits
        bcc     LA149
        inc     paintbits_params::mapbits+1
LA149:  dey
        bpl     LA13A
        rts

LA14D:  ldx     #$00
LA14F:  lda     paintbits_params2::viewloc::xcoord,x
        clc
        adc     paintbits_params2::maprect::x1,x
        sta     paintrect_params6,x
        lda     paintbits_params2::viewloc::xcoord+1,x
        adc     paintbits_params2::maprect::x1+1,x
        sta     paintrect_params6::left+1,x
        lda     paintbits_params2::viewloc::xcoord,x
        clc
        adc     paintbits_params2::maprect::x2,x
        sta     paintrect_params6::right,x
        lda     paintbits_params2::viewloc::xcoord+1,x
        adc     paintbits_params2::maprect::x2+1,x
        sta     paintrect_params6::right+1,x
        inx
        inx
        cpx     #$04
        bne     LA14F
        lda     paintrect_params6::bottom
        sec
        sbc     #$01
        sta     paintrect_params6::bottom
        bcs     LA189
        dec     paintrect_params6::bottom+1
LA189:  rts

;;; ==================================================

.proc calc_icon_poly
        jsr     push_zp_addrs
        ldy     #$06
        ldx     #$03
LA191:  lda     ($06),y
        sta     poly::vertices,x
        dey
        dex
        bpl     LA191
        copy16  poly::v0::ycoord, poly::v1::ycoord
        copy16  poly::v0::xcoord, poly::v7::xcoord
        ldy     #$07
        lda     ($06),y
        sta     $08
        iny
        lda     ($06),y
        sta     $08+1
        ldy     #$08
        lda     ($08),y
        clc
        adc     poly::v0::xcoord
        sta     poly::v1::xcoord
        sta     poly::v2::xcoord
        iny
        lda     ($08),y
        adc     poly::v0::xcoord+1
        sta     poly::v1::xcoord+1
        sta     poly::v2::xcoord+1
        ldy     #$0A
        lda     ($08),y
        clc
        adc     poly::v0::ycoord
        sta     poly::v2::ycoord
        iny
        lda     ($08),y
        adc     poly::v0::ycoord+1
        sta     poly::v2::ycoord+1
        lda     poly::v2::ycoord
        clc
        adc     #$02
        sta     poly::v2::ycoord
        sta     poly::v3::ycoord
        sta     poly::v6::ycoord
        sta     poly::v7::ycoord
        lda     poly::v2::ycoord+1
        adc     #$00
        sta     poly::v2::ycoord+1
        sta     poly::v3::ycoord+1
        sta     poly::v6::ycoord+1
        sta     poly::v7::ycoord+1
        lda     font_height
        clc
        adc     poly::v2::ycoord
        sta     poly::v4::ycoord
        sta     poly::v5::ycoord
        lda     poly::v2::ycoord+1
        adc     #$00
        sta     poly::v4::ycoord+1
        sta     poly::v5::ycoord+1
        ldy     #$1C
        ldx     #$13
LA22A:  lda     ($06),y
        sta     text_buffer-1,x
        dey
        dex
        bpl     LA22A
LA233:  lda     drawtext_params::textlen
        sta     textwidth_params::textlen
        MGTK_CALL MGTK::TextWidth, textwidth_params
        ldy     #$08
        lda     textwidth_params::result
        cmp     ($08),y
        bcs     LA256
        inc     drawtext_params::textlen
        ldx     drawtext_params::textlen
        lda     #' '
        sta     text_buffer-1,x
        jmp     LA233

LA256:  lsr     a
        sta     LA2A5
        lda     ($08),y
        lsr     a
        sta     LA2A4
        lda     LA2A5
        sec
        sbc     LA2A4
        sta     LA2A4
        lda     poly::v0::xcoord
        sec
        sbc     LA2A4
        sta     poly::v6::xcoord
        sta     poly::v5::xcoord
        lda     poly::v0::xcoord+1
        sbc     #$00
        sta     poly::v6::xcoord+1
        sta     poly::v5::xcoord+1
        inc     textwidth_params::result
        inc     textwidth_params::result
        lda     poly::v5::xcoord
        clc
        adc     textwidth_params::result
        sta     poly::v3::xcoord
        sta     poly::v4::xcoord
        lda     poly::v5::xcoord+1
        adc     #$00
        sta     poly::v3::xcoord+1
        sta     poly::v4::xcoord+1
        jsr     pop_zp_addrs
        rts

LA2A4:  .byte   0
LA2A5:  .byte   0

.endproc

;;; ==================================================
;;; REDRAW_ICONS IMPL

REDRAW_ICONS_IMPL:
        jmp     LA2AE

        ;; DT_UNHIGHLIGHT_ICON params
LA2A9:  .byte   0

LA2AA:  jsr     pop_zp_addrs
        rts

LA2AE:  jsr     push_zp_addrs
        ldx     num_icons
        dex
LA2B5:  bmi     LA2AA
        txa
        pha
        lda     icon_table,x
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        bne     LA2DD
        ldy     #$00
        lda     ($06),y
        sta     LA2A9
        DESKTOP_DIRECT_CALL DT_UNHIGHLIGHT_ICON, LA2A9
LA2DD:  pla
        tax
        dex
        jmp     LA2B5

LA2E3:  stx     LA322
        sta     LA323
        ldx     #$00
LA2EB:  lda     icon_table,x
        cmp     LA323
        beq     LA2FA
        inx
        cpx     num_icons
        bne     LA2EB
        rts

LA2FA:  lda     icon_table+1,x
        sta     icon_table,x
        inx
        cpx     num_icons
        bne     LA2FA
        ldx     num_icons
LA309:  cpx     LA322
        beq     LA318
        lda     L8E94,x
        sta     num_icons,x
        dex
        jmp     LA309

LA318:  ldx     LA322
        lda     LA323
        sta     num_icons,x
        rts
LA322:  .byte   0
LA323:  .byte   0

;;; ==================================================

LA324:  stx     LA363
        sta     LA364
        ldx     #$00
LA32C:  lda     highlight_list,x
        cmp     LA364
        beq     LA33B
        inx
        cpx     highlight_count
        bne     LA32C
        rts

LA33B:  lda     highlight_list+1,x
        sta     highlight_list,x
        inx
        cpx     highlight_count
        bne     LA33B
        ldx     highlight_count
:       cpx     LA363
        beq     LA359
        lda     has_highlight,x
        sta     highlight_count,x
        dex
        jmp     :-

LA359:  ldx     LA363
        lda     LA364
        sta     highlight_count,x
        rts
LA363:  .byte   0
LA364:  .byte   0

;;; ==================================================

.proc push_zp_addrs
        ;; save return addr
        pla
        sta     stash
        pla
        sta     stash+1

        ;; push $06...$09 to stack
        ldx     #0
:       lda     $06,x
        pha
        inx
        cpx     #4
        bne     :-

        ;; restore return addr
        lda     stash+1
        pha
        lda     stash
        pha
        rts

stash:  .word   0
.endproc

;;; ==================================================

.proc pop_zp_addrs
        ;; save return addr
        pla
        sta     stash
        pla
        sta     stash+1

        ;; pull $06...$09 to stack
        ldx     #3
:       pla
        sta     $06,x
        dex
        bpl     :-

        ;; restore return addr
        lda     stash+1
        pha
        lda     stash
        pha
        rts

stash:  .word   0

.endproc

;;; ==================================================

LA39D:  MGTK_CALL MGTK::InitPort, grafport
        MGTK_CALL MGTK::SetPort, grafport
        jmp     LA3B9

LA3AC:  .byte   0
LA3AD:  .byte   0

        ;; DT_UNHIGHLIGHT_ICON params
LA3AE:  .byte   0

LA3AF:  .byte   0
LA3B0:  .byte   0
LA3B1:  .byte   0
LA3B2:  .byte   0
LA3B3:  .byte   0
        .byte   0
        .byte   0
        .byte   0
LA3B7:  .byte   0

.proc frontwindow_params
window_id:      .byte   0
.endproc

.proc LA3B9
        ldy     #0
        lda     ($06),y
        sta     LA3AC
        iny
        iny
        lda     ($06),y
        and     #$0F            ; type - is volume?
        sta     LA3AD
        beq     volume

        ;; File (i.e. icon in window)
        lda     #$80
        sta     LA3B7
        MGTK_CALL MGTK::SetPattern, white_pattern
        MGTK_CALL MGTK::FrontWindow, frontwindow_params
        lda     frontwindow_params::window_id
        sta     getwinport_params::window_id
        MGTK_CALL MGTK::GetWinPort, getwinport_params
        jsr     LA4CC
        jsr     LA938
        jsr     erase_icon
        jmp     LA446

        ;; Volume (i.e. icon on desktop)
volume:
        MGTK_CALL MGTK::InitPort, grafport
        jsr     LA63F
:       jsr     LA6A3
        jsr     erase_desktop_icon
        lda     L9F93
        bne     :-
        MGTK_CALL MGTK::SetPortBits, grafport
        jmp     LA446
.endproc

;;; ==================================================

.proc erase_desktop_icon
        lda     #0
        sta     LA3B7
        MGTK_CALL MGTK::SetPattern, checkerboard_pattern2
        ;; fall through
.endproc

.proc erase_icon
        copy16  poly::v0::ycoord, LA3B1
        copy16  poly::v6::xcoord, LA3AF
        ldx     #3
:       lda     poly::v4::xcoord,x
        sta     LA3B3,x
        dex
        bpl     :-
        MGTK_CALL MGTK::PaintPoly, poly
        rts
.endproc

;;; ==================================================

LA446:  jsr     push_zp_addrs
        ldx     num_icons
        dex                     ; any icons to draw?
LA44D:  cpx     #$FF            ; =-1
        bne     LA466
        bit     LA3B7           ; no, almost done
        bpl     :+
        MGTK_CALL MGTK::InitPort, grafport
        MGTK_CALL MGTK::SetPort, grafport4
:       jsr     pop_zp_addrs
        rts

;;; ==================================================

.proc LA466
        ptr := $8

        txa
        pha
        lda     icon_table,x
        cmp     LA3AC
        beq     LA4C5
        asl     a
        tax
        copy16  icon_ptrs,x, ptr
        ldy     #2              ; type??? offset
        lda     (ptr),y
        and     #$07            ; low bits
        cmp     LA3AD
        bne     LA4C5

        ;; Is icon highlighted?
        lda     has_highlight
        beq     LA49D
        ldy     #0              ; icon num
        lda     (ptr),y
        ldx     #0
:       cmp     highlight_list,x
        beq     LA4C5
        inx
        cpx     highlight_count
        bne     :-

LA49D:  ldy     #0              ; icon num
        lda     (ptr),y
        sta     LA3AE
        bit     LA3B7
        bpl     LA4AC
        jsr     LA4D3
LA4AC:  DESKTOP_DIRECT_CALL DT_ICON_IN_RECT, LA3AE
        beq     LA4BA

        DESKTOP_DIRECT_CALL DT_UNHIGHLIGHT_ICON, LA3AE

LA4BA:  bit     LA3B7
        bpl     LA4C5
        lda     LA3AE
        jsr     LA4DC
LA4C5:  pla
        tax
        dex
        jmp     LA44D
.endproc

;;; ==================================================

LA4CB:  .byte   0

LA4CC:  lda     #$80
        sta     LA4CB
        bmi     LA4E2
LA4D3:  pha
        lda     #$40
        sta     LA4CB
        jmp     LA4E2

LA4DC:  pha
        lda     #$00
        sta     LA4CB
LA4E2:  ldy     #$00
LA4E4:  lda     grafport4,y
        sta     LA567,y
        iny
        cpy     #$04
        bne     LA4E4
        ldy     #$08
LA4F1:  lda     grafport4,y
        sta     LA567-4,y
        iny
        cpy     #$0C
        bne     LA4F1
        bit     LA4CB
        bmi     LA506
        bvc     LA56F
        jmp     LA5CB

LA506:  ldx     #$00
LA508:  lda     poly::vertices,x
        sec
        sbc     LA567
        sta     poly::vertices,x
        lda     poly::vertices+1,x
        sbc     LA568
        sta     poly::vertices+1,x
        lda     poly::vertices+2,x
        sec
        sbc     LA569
        sta     poly::vertices+2,x
        lda     poly::vertices+3,x
        sbc     LA56A
        sta     poly::vertices+3,x
        inx
        inx
        inx
        inx
        cpx     #$20
        bne     LA508
        ldx     #$00
LA538:  lda     poly::vertices,x
        clc
        adc     LA56B
        sta     poly::vertices,x
        lda     poly::vertices+1,x
        adc     LA56C
        sta     poly::vertices+1,x
        lda     poly::vertices+2,x
        clc
        adc     LA56D
        sta     poly::vertices+2,x
        lda     poly::vertices+3,x
        adc     LA56E
        sta     poly::vertices+3,x
        inx
        inx
        inx
        inx
        cpx     #$20
        bne     LA538
        rts

LA567:  .byte   0
LA568:  .byte   0
LA569:  .byte   0
LA56A:  .byte   0
LA56B:  .byte   0
LA56C:  .byte   0
LA56D:  .byte   0
LA56E:  .byte   0
LA56F:  pla
        tay
        jsr     push_zp_addrs
        tya
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        ldy     #$03
        lda     ($06),y
        clc
        adc     LA567
        sta     ($06),y
        iny
        lda     ($06),y
        adc     LA568
        sta     ($06),y
        iny
        lda     ($06),y
        clc
        adc     LA569
        sta     ($06),y
        iny
        lda     ($06),y
        adc     LA56A
        sta     ($06),y
        ldy     #$03
        lda     ($06),y
        sec
        sbc     LA56B
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     LA56C
        sta     ($06),y
        iny
        lda     ($06),y
        sec
        sbc     LA56D
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     LA56E
        sta     ($06),y
        jsr     pop_zp_addrs
        rts

LA5CB:  pla
        tay
        jsr     push_zp_addrs
        tya
        asl     a
        tax
        copy16  icon_ptrs,x, $06
        ldy     #$03
        lda     ($06),y
        sec
        sbc     LA567
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     LA568
        sta     ($06),y
        iny
        lda     ($06),y
        sec
        sbc     LA569
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     LA56A
        sta     ($06),y
        ldy     #$03
        lda     ($06),y
        clc
        adc     LA56B
        sta     ($06),y
        iny
        lda     ($06),y
        adc     LA56C
        sta     ($06),y
        iny
        lda     ($06),y
        clc
        adc     LA56D
        sta     ($06),y
        iny
        lda     ($06),y
        adc     LA56E
        sta     ($06),y
        jsr     pop_zp_addrs
        rts

;;; ==================================================

LA627:  .byte   $00
LA628:  .byte   $00
LA629:  .byte   $00
LA62A:  .byte   $00
LA62B:  .byte   $00
LA62C:  .byte   $00,$00,$00

.proc setportbits_params2
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, 0, 0, cliprect
.endproc

LA63F:  jsr     calc_icon_poly
        lda     poly::v0::ycoord
        sta     LA629
        sta     setportbits_params2::cliprect::y1
        sta     setportbits_params2::viewloc::ycoord
        lda     poly::v0::ycoord+1
        sta     LA62A
        sta     setportbits_params2::cliprect::y1+1
        sta     setportbits_params2::viewloc::ycoord+1
        lda     poly::v5::xcoord
        sta     LA627
        sta     setportbits_params2::cliprect::x1
        sta     setportbits_params2::viewloc::xcoord
        lda     poly::v5::xcoord+1
        sta     LA628
        sta     setportbits_params2::cliprect::x1+1
        sta     setportbits_params2::viewloc::xcoord+1
        ldx     #$03
LA674:  lda     poly::v4::xcoord,x
        sta     LA62B,x
        sta     setportbits_params2::cliprect::x2,x
        dex
        bpl     LA674
        lda     LA62B
        cmp     #$2F
        lda     LA62C
        sbc     #$02
        bmi     LA69C
        lda     #$2E
        sta     LA62B
        sta     setportbits_params2::cliprect::x2
        lda     #$02
        sta     LA62C
        sta     setportbits_params2::cliprect::x2+1
LA69C:  MGTK_CALL MGTK::SetPortBits, setportbits_params2
        rts

LA6A3:  lda     #$00
        jmp     LA6C7

.proc findwindow_params
mousex: .word   0
mousey: .word   0
which_area:     .byte   0
window_id:      .byte   0
.endproc

LA6AE:  .byte   $00
LA6AF:  .byte   $00
LA6B0:  .byte   $00
LA6B1:  .byte   $00
LA6B2:  .byte   $00
LA6B3:  .byte   $00
LA6B4:  .byte   $00
LA6B5:  .byte   $00
LA6B6:  .byte   $00
LA6B7:  .byte   $00
LA6B8:  .byte   $00
LA6B9:  .byte   $00
LA6BA:  .byte   $00
LA6BB:  .byte   $00
LA6BC:  .byte   $00
LA6BD:  .byte   $00
LA6BE:  .byte   $00
LA6BF:  .byte   $00
LA6C0:  .byte   $00
LA6C1:  .byte   $00
LA6C2:  .byte   $00
LA6C3:  .byte   $00
LA6C4:  .byte   $00
LA6C5:  .byte   $00
LA6C6:  .byte   $00
LA6C7:  lda     L9F93
        beq     LA6FA
        lda     setportbits_params2::cliprect::x2
        clc
        adc     #$01
        sta     setportbits_params2::cliprect::x1
        sta     setportbits_params2::viewloc::xcoord
        lda     setportbits_params2::cliprect::x2+1
        adc     #$00
        sta     setportbits_params2::cliprect::x1+1
        sta     setportbits_params2::viewloc::xcoord+1
        ldx     #$05
LA6E5:  lda     LA629,x
        sta     setportbits_params2::cliprect::y1,x
        dex
        bpl     LA6E5
        lda     setportbits_params2::cliprect::y1
        sta     setportbits_params2::viewloc::ycoord
        lda     setportbits_params2::cliprect::y1+1
        sta     setportbits_params2::viewloc::ycoord+1
LA6FA:  lda     setportbits_params2::cliprect::x1
        sta     LA6B3
        sta     LA6BF
        lda     setportbits_params2::cliprect::x1+1
        sta     LA6B4
        sta     LA6C0
        lda     setportbits_params2::cliprect::y1
        sta     LA6B5
        sta     LA6B9
        lda     setportbits_params2::cliprect::y1+1
        sta     LA6B6
        sta     LA6BA
        lda     setportbits_params2::cliprect::x2
        sta     LA6B7
        sta     LA6BB
        lda     setportbits_params2::cliprect::x2+1
        sta     LA6B8
        sta     LA6BC
        lda     setportbits_params2::cliprect::y2
        sta     LA6BD
        sta     LA6C1
        lda     setportbits_params2::cliprect::y2+1
        sta     LA6BE
        sta     LA6C2
        lda     #$00
        sta     LA6B0
LA747:  lda     LA6B0
        cmp     #$04
        bne     LA775
        lda     #$00
        sta     LA6B0
LA753:  MGTK_CALL MGTK::SetPortBits, setportbits_params2
        lda     setportbits_params2::cliprect::x2+1
        cmp     LA62C
        bne     LA76F
        lda     setportbits_params2::cliprect::x2
        cmp     LA62B
        bcc     LA76F
        lda     #$00
        sta     L9F93
        rts

LA76F:  lda     #$01
        sta     L9F93
        rts

LA775:  lda     LA6B0
        asl     a
        asl     a
        tax
        ldy     #$00
LA77D:  lda     LA6B3,x
        sta     findwindow_params,y
        iny
        inx
        cpy     #$04
        bne     LA77D
        inc     LA6B0
        MGTK_CALL MGTK::FindWindow, findwindow_params
        lda     findwindow_params::which_area
        beq     LA747
        lda     findwindow_params::window_id
        sta     getwinport_params
        MGTK_CALL MGTK::GetWinPort, getwinport_params
        jsr     push_zp_addrs
        MGTK_CALL MGTK::GetWinPtr, findwindow_params::window_id
        lda     LA6AE
        sta     $06
        lda     LA6AF
        sta     $07
        ldy     #$01
        lda     ($06),y
        and     #$01
        bne     LA7C3
        sta     LA6B2
        beq     LA7C8
LA7C3:  lda     #$80
        sta     LA6B2
LA7C8:  ldy     #$04
        lda     ($06),y
        and     #$80
        sta     LA6B1
        iny
        lda     ($06),y
        and     #$80
        lsr     a
        ora     LA6B1
        sta     LA6B1
        sub16 grafport4::viewloc::xcoord, #2, grafport4::viewloc::xcoord
        sub16   grafport4::cliprect::x1, #2, grafport4::cliprect::x1
        bit     LA6B2
        bmi     LA820
        lda     grafport4::viewloc::ycoord
        sec
        sbc     #$0E
        sta     grafport4::viewloc::ycoord
        bcs     LA812
        dec     grafport4::viewloc::ycoord+1
LA812:  lda     grafport4::cliprect::y1
        sec
        sbc     #$0E
        sta     grafport4::cliprect::y1
        bcs     LA820
        dec     grafport4::cliprect::y1+1
LA820:  bit     LA6B1
        bpl     LA833
        lda     grafport4::cliprect::y2
        clc
        adc     #12
        sta     grafport4::cliprect::y2
        bcc     LA833
        inc     grafport4::cliprect::y2+1
LA833:  bit     LA6B1
        bvc     LA846
        lda     grafport4::cliprect::x2
        clc
        adc     #20
        sta     grafport4::cliprect::x2
        bcc     LA846
        inc     grafport4::cliprect::x2+1
LA846:  jsr     pop_zp_addrs
        sub16 grafport4::cliprect::x2, grafport4::cliprect::x1, LA6C3
        sub16  grafport4::cliprect::y2, grafport4::cliprect::y1, LA6C5
        lda     LA6C3
        clc
        adc     grafport4::viewloc::xcoord
        sta     LA6C3
        lda     grafport4::viewloc::xcoord+1
        adc     LA6C4
        sta     LA6C4
        add16 LA6C5, grafport4::viewloc::ycoord, LA6C5
        lda     setportbits_params2::cliprect::x2
        cmp     LA6C3
        lda     setportbits_params2::cliprect::x2+1
        sbc     LA6C4
        bmi     LA8B7
        add16 LA6C3, #1, setportbits_params2::cliprect::x2
        jmp     LA8D4

LA8B7:  lda     grafport4::viewloc::xcoord
        cmp     setportbits_params2::cliprect::x1
        lda     grafport4::viewloc::xcoord+1
        sbc     setportbits_params2::cliprect::x1+1
        bmi     LA8D4
        lda     grafport4::viewloc::xcoord
        sta     setportbits_params2::cliprect::x2
        lda     grafport4::viewloc::xcoord+1
        sta     setportbits_params2::cliprect::x2+1
        jmp     LA6FA

LA8D4:  lda     grafport4::viewloc::ycoord
        cmp     setportbits_params2::cliprect::y1
        lda     grafport4::viewloc::ycoord+1
        sbc     setportbits_params2::cliprect::y1+1
        bmi     LA8F6
        lda     grafport4::viewloc::ycoord
        sta     setportbits_params2::cliprect::y2
        lda     grafport4::viewloc::ycoord+1
        sta     setportbits_params2::cliprect::y2+1
        lda     #1
        sta     L9F93
        jmp     LA6FA

LA8F6:  lda     LA6C5
        cmp     setportbits_params2::cliprect::y2
        lda     LA6C6
        sbc     setportbits_params2::cliprect::y2+1
        bpl     LA923
        lda     LA6C5
        clc
        adc     #2
        sta     setportbits_params2::cliprect::y1
        sta     setportbits_params2::viewloc::ycoord
        lda     LA6C6
        adc     #0
        sta     setportbits_params2::cliprect::y1+1
        sta     setportbits_params2::viewloc::ycoord+1
        lda     #1
        sta     L9F93
        jmp     LA6FA

LA923:  lda     setportbits_params2::cliprect::x2
        sta     setportbits_params2::cliprect::x1
        sta     setportbits_params2::viewloc::xcoord
        lda     setportbits_params2::cliprect::x2+1
        sta     setportbits_params2::cliprect::x1+1
        sta     setportbits_params2::viewloc::xcoord+1
        jmp     LA753

LA938:  lda     grafport4::viewloc::ycoord
        clc
        adc     #15
        sta     grafport4::viewloc::ycoord
        lda     grafport4::viewloc::ycoord+1
        adc     #0
        sta     grafport4::viewloc::ycoord+1
        lda     grafport4::cliprect::y1
        clc
        adc     #15
        sta     grafport4::cliprect::y1
        lda     grafport4::cliprect::y1+1
        adc     #0
        sta     grafport4::cliprect::y1+1
        MGTK_CALL MGTK::SetPort, grafport4
        rts

        PAD_TO $A980

;;; ==================================================

        ;; 5.25" Floppy Disk
floppy140_icon:
        .addr   floppy140_pixels; mapbits
        .byte   4               ; mapwidth
        .byte   0               ; reserved
        DEFINE_RECT   0, 1, 26, 15 ; maprect

floppy140_pixels:
        .byte   px(%1010101),px(%0101010),px(%1010101),px(%0101010)
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1111111)
        .byte   px(%1100000),px(%0000011),px(%1000000),px(%0000110)
        .byte   px(%1100000),px(%0000011),px(%1000000),px(%0000111)
        .byte   px(%1100000),px(%0000011),px(%1000000),px(%0000110)
        .byte   px(%1100000),px(%0000011),px(%1000000),px(%0000111)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000110)
        .byte   px(%1100000),px(%0000011),px(%1000000),px(%0000111)
        .byte   px(%1100000),px(%0000111),px(%1100000),px(%0000110)
        .byte   px(%1100000),px(%0000011),px(%1000000),px(%0000111)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000110)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000111)
        .byte   px(%1011000),px(%0000000),px(%0000000),px(%0000110)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000111)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000110)
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1111111)

        ;; RAM Disk
ramdisk_icon:
        .addr   ramdisk_pixels  ; mapbits
        .byte   6               ; mapwidth
        .byte   0               ; reserved
        DEFINE_RECT   1, 0, 38, 11 ; maprect

ramdisk_pixels:
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1111101)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0001110)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0001101)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0001110)
        .byte   px(%1100000),px(%0001111),px(%1000111),px(%1100110),px(%0000110),px(%0001101)
        .byte   px(%1100000),px(%0001100),px(%1100110),px(%0110111),px(%1011110),px(%0001110)
        .byte   px(%1100000),px(%0001111),px(%1000111),px(%1110110),px(%1110110),px(%0001101)
        .byte   px(%1100000),px(%0001100),px(%1100110),px(%0110110),px(%0000110),px(%0001110)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0001101)
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1001100),px(%1100110),px(%0001110)
        .byte   px(%0101010),px(%1010101),px(%0101010),px(%1001100),px(%1100110),px(%0001101)
        .byte   px(%1010101),px(%0101010),px(%1010101),px(%1111111),px(%1111111),px(%1111110)

        ;; 3.5" Floppy Disk
floppy800_icon:
        .addr   floppy800_pixels; mapbits
        .byte   3               ; mapwidth
        .byte   0               ; reserved
        DEFINE_RECT   0, 0, 20, 11 ; maprect

floppy800_pixels:
        .byte   px(%1111111),px(%1111111),px(%1111110)
        .byte   px(%1100011),px(%0000000),px(%1100111)
        .byte   px(%1100011),px(%0000000),px(%1100111)
        .byte   px(%1100011),px(%1111111),px(%1100011)
        .byte   px(%1100000),px(%0000000),px(%0000011)
        .byte   px(%1100000),px(%0000000),px(%0000011)
        .byte   px(%1100111),px(%1111111),px(%1110011)
        .byte   px(%1100110),px(%0000000),px(%0110011)
        .byte   px(%1100110),px(%0000000),px(%0110011)
        .byte   px(%1100110),px(%0000000),px(%0110011)
        .byte   px(%1100110),px(%0000000),px(%0110011)
        .byte   px(%1111111),px(%1111111),px(%1111111)

        ;; Hard Disk
profile_icon:
        .addr   profile_pixels  ; mapbits
        .byte   8               ; mapwidth
        .byte   0               ; reserved
        DEFINE_RECT   1, 0, 51, 9 ; maprect

profile_pixels:
        .byte   px(%0111111),px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1110101)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0011010)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0011101)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0011010)
        .byte   px(%1100011),px(%1000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0011101)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0011101)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0011010)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0011101)
        .byte   px(%0111111),px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1110101)
        .byte   px(%1010111),px(%0101010),px(%1010101),px(%0101010),px(%1010101),px(%0101010),px(%1010111),px(%0101010)

        ;; Trash Can
trash_icon:
        .addr   trash_pixels    ; mapbits
        .byte   5               ; mapwidth
        .byte   0               ; reserved
        DEFINE_RECT   7, 1, 27, 18 ; maprect

trash_pixels:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%1010101),PX(%1111111),px(%1010101),px(%0000000)
        .byte   px(%0000000),px(%0101010),PX(%1100011),px(%0101010),px(%0000000)
        .byte   px(%0000000),PX(%1111111),PX(%1111111),PX(%1111111),px(%0000000)
        .byte   px(%0000000),px(%1100000),px(%0000000),PX(%0000011),px(%0000000)
        .byte   px(%0000000),PX(%1111111),PX(%1111111),PX(%1111111),px(%0000000)
        .byte   px(%0000000),px(%1100000),px(%0000000),px(%0000011),px(%0000000)
        .byte   px(%0000000),px(%1100001),px(%0000100),px(%0010011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100010),px(%0001000),px(%0100011),px(%0000000)
        .byte   px(%0000000),px(%1100001),px(%0000100),px(%0010011),px(%0000000)
        .byte   px(%0000000),px(%1100000),px(%0000000),px(%0000011),px(%0000000)
        .byte   px(%0000000),PX(%1111111),PX(%1111111),PX(%1111111),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)

label_apple:
        PASCAL_STRING GLYPH_SAPPLE
label_file:
        PASCAL_STRING "File"
label_view:
        PASCAL_STRING "View"
label_special:
        PASCAL_STRING "Special"
label_startup:
        PASCAL_STRING "Startup"
label_selector:
        PASCAL_STRING "Selector"

label_new_folder:
        PASCAL_STRING "New Folder ..."
label_open:
        PASCAL_STRING "Open"
label_close:
        PASCAL_STRING "Close"
label_close_all:
        PASCAL_STRING "Close All"
label_select_all:
        PASCAL_STRING "Select All"
label_copy_file:
        PASCAL_STRING "Copy a File ..."
label_delete_file:
        PASCAL_STRING "Delete a File ..."
label_eject:
        PASCAL_STRING "Eject"
label_quit:
        PASCAL_STRING "Quit"

label_by_icon:
        PASCAL_STRING "By Icon"
label_by_name:
        PASCAL_STRING "By Name"
label_by_date:
        PASCAL_STRING "By Date"
label_by_size:
        PASCAL_STRING "By Size"
label_by_type:
        PASCAL_STRING "By Type"

label_check_drives:
        PASCAL_STRING "Check Drives"
label_format_disk:
        PASCAL_STRING "Format a Disk ..."
label_erase_disk:
        PASCAL_STRING "Erase a Disk ..."
label_disk_copy:
        PASCAL_STRING "Disk Copy ..."
label_lock:
        PASCAL_STRING "Lock ..."
label_unlock:
        PASCAL_STRING "Unlock ..."
label_get_info:
        PASCAL_STRING "Get Info ..."
label_get_size:
        PASCAL_STRING "Get Size ..."
label_rename_icon:
        PASCAL_STRING "Rename an Icon ..."


desktop_menu:
        DEFINE_MENU_BAR 6
        DEFINE_MENU_BAR_ITEM 1, label_apple, apple_menu
        DEFINE_MENU_BAR_ITEM 2, label_file, file_menu
        DEFINE_MENU_BAR_ITEM 4, label_view, view_menu
        DEFINE_MENU_BAR_ITEM 5, label_special, special_menu
        DEFINE_MENU_BAR_ITEM 8, label_startup, startup_menu
        DEFINE_MENU_BAR_ITEM 3, label_selector, selector_menu

file_menu:
        DEFINE_MENU 12
        DEFINE_MENU_ITEM label_new_folder, 'F', 'f'
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM label_open, 'O', 'o'
        DEFINE_MENU_ITEM label_close, 'C', 'c'
        DEFINE_MENU_ITEM label_close_all, 'B', 'b'
        DEFINE_MENU_ITEM label_select_all, 'A', 'a'
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM label_copy_file, 'Y', 'y'
        DEFINE_MENU_ITEM label_delete_file, 'D', 'd'
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM label_eject, 'E', 'e'
        DEFINE_MENU_ITEM label_quit, 'Q', 'q'

view_menu:
        DEFINE_MENU 5
        DEFINE_MENU_ITEM label_by_icon, 'J', 'j'
        DEFINE_MENU_ITEM label_by_name, 'N', 'n'
        DEFINE_MENU_ITEM label_by_date, 'T', 't'
        DEFINE_MENU_ITEM label_by_size, 'K', 'k'
        DEFINE_MENU_ITEM label_by_type, 'L', 'l'

special_menu:
        DEFINE_MENU 13
        DEFINE_MENU_ITEM label_check_drives
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM label_format_disk, 'S', 's'
        DEFINE_MENU_ITEM label_erase_disk, 'Z', 'z'
        DEFINE_MENU_ITEM label_disk_copy
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM label_lock
        DEFINE_MENU_ITEM label_unlock
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM label_get_info, 'I', 'i'
        DEFINE_MENU_ITEM label_get_size
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM label_rename_icon

        .addr   $0000,$0000

        .assert * = $AD58, error, "Segment length mismatch"
        PAD_TO $AE00

;;; ==================================================

        ;; Rects
confirm_dialog_outer_rect:  DEFINE_RECT 4,2,396,98
confirm_dialog_inner_rect:  DEFINE_RECT 5,3,395,97
cancel_button_rect:  DEFINE_RECT 40,81,140,92
LAE18:  DEFINE_RECT 193,30,293,41
ok_button_rect:  DEFINE_RECT 260,81,360,92
yes_button_rect:  DEFINE_RECT 200,81,240,92
no_button_rect:  DEFINE_RECT 260,81,300,92
all_button_rect:  DEFINE_RECT 320,81,360,92

str_ok_label:
        PASCAL_STRING {"OK            ",GLYPH_RETURN}

ok_label_pos:  DEFINE_POINT 265,91
cancel_label_pos:  DEFINE_POINT 45,91
yes_label_pos:  DEFINE_POINT 205,91
no_label_pos:  DEFINE_POINT 265,91
all_label_pos:  DEFINE_POINT 325,91

        .byte   $1C,$00,$70,$00
        .byte   $1C,$00,$87,$00

LAE6C:  .byte   $00             ; text mask
LAE6D:  .byte   $7F             ; text mask

press_ok_to_rect:  DEFINE_RECT 39,25,360,80
prompt_rect:  DEFINE_RECT 40,60,360,80
LAE7E:  DEFINE_POINT 65,43
LAE82:  DEFINE_POINT 65,51
LAE86:  DEFINE_RECT 65,35,394,42
LAE8E:  DEFINE_RECT 65,43,394,50

str_cancel_label:
        PASCAL_STRING "Cancel        Esc"
str_yes_label:
        PASCAL_STRING " Yes"
str_no_label:
        PASCAL_STRING " No"
str_all_label:
        PASCAL_STRING " All"

LAEB6:  PASCAL_STRING "Source filename:"
LAEC7:  PASCAL_STRING "Destination filename:"

        ;; "About" dialog resources
about_dialog_outer_rect:  DEFINE_RECT 4, 2, 396, 108
about_dialog_inner_rect:  DEFINE_RECT 5, 3, 395, 107

str_about1:  PASCAL_STRING "Apple II DeskTop"
str_about2:  PASCAL_STRING "Copyright Apple Computer Inc., 1986"
str_about3:  PASCAL_STRING "Copyright Version Soft, 1985 - 1986"
str_about4:  PASCAL_STRING "All Rights Reserved"
str_about5:  PASCAL_STRING "Authors: Stephane Cavril, Bernard Gallet, Henri Lamiraux"
str_about6:  PASCAL_STRING "Richard Danais and Luc Barthelet"
str_about7:  PASCAL_STRING "With thanks to: A. Gerard, J. Gerber, P. Pahl, J. Bernard"
str_about8:  PASCAL_STRING "November 26, 1986"
str_about9:  PASCAL_STRING "Version 1.1"

        ;; "Copy File" dialog strings
str_copy_title:
        PASCAL_STRING "Copy ..."
str_copy_copying:
        PASCAL_STRING "Now Copying "
str_copy_from:
        PASCAL_STRING "from:"
str_copy_to:
        PASCAL_STRING "to :"
str_copy_remaining:
        PASCAL_STRING "Files remaining to copy: "

str_exists_prompt:
        PASCAL_STRING "That file already exists. Do you want to write over it ?"
str_large_prompt:
        PASCAL_STRING "This file is too large to copy, click OK to continue."

LB0B6:  DEFINE_POINT 110, 35
LB0BA:  DEFINE_POINT 170, 59

        ;; "Delete" dialog strings
str_delete_title:
        PASCAL_STRING "Delete ..."
str_delete_ok:
        PASCAL_STRING "Click OK to delete:"
str_ok_empty:
        PASCAL_STRING "Clicking OK will immediately empty the trash of:"
str_file_colon:
        PASCAL_STRING "File:"
str_delete_remaining:
        PASCAL_STRING "Files remaining to be deleted:"
str_delete_locked_file:
        PASCAL_STRING "This file is locked, do you want to delete it anyway ?"

LB16A:  DEFINE_POINT 145, 59
LB16E:  DEFINE_POINT 200, 59
LB172:  DEFINE_POINT 300, 59

        ;; "New Folder" dialog strings
str_new_folder_title:
        PASCAL_STRING "New Folder ..."
str_in_colon:
        PASCAL_STRING "in:"
str_enter_folder_name:
        PASCAL_STRING "Enter the folder name:"

        ;; "Rename Icon" dialog strings
str_rename_title:
        PASCAL_STRING "Rename an Icon ..."
str_rename_old:
        PASCAL_STRING "Rename: "
str_rename_new:
        PASCAL_STRING "New name:"

        ;; "Get Info" dialog strings
str_info_title:
        PASCAL_STRING "Get Info ..."
str_info_name:
        PASCAL_STRING "Name"
str_info_locked:
        PASCAL_STRING "Locked"
str_info_size:
        PASCAL_STRING "Size"
str_info_create:
        PASCAL_STRING "Creation date"
str_info_mod:
        PASCAL_STRING "Last modification"
str_info_type:
        PASCAL_STRING "Type"
str_info_protected:
        PASCAL_STRING "Write protected"
str_info_blocks:
        PASCAL_STRING "Blocks free/size"

str_colon:
        PASCAL_STRING ": "

LB22D:  DEFINE_POINT 160,59
LB231:  DEFINE_POINT 145,59
LB235:  DEFINE_POINT 200,59
LB239:  DEFINE_POINT 185,59
LB23D:  DEFINE_POINT 205,59
LB241:  DEFINE_POINT 195,59

LB245:  PASCAL_STRING "Format a Disk ..."
LB257:  PASCAL_STRING "Select the location where the disk is to be formatted"
LB28D:  PASCAL_STRING "Enter the name of the new volume:"
LB2AF:  PASCAL_STRING "Do you want to format "
LB2C6:  PASCAL_STRING "Formatting the disk...."
LB2DE:  PASCAL_STRING "Formatting error. Check drive, then click OK to try again."

LB319:  PASCAL_STRING "Erase a Disk ..."
LB32A:  PASCAL_STRING "Select the location where the disk is to be erased"
LB35D:  PASCAL_STRING "Do you want to erase "
LB373:  PASCAL_STRING "Erasing the disk...."
LB388:  PASCAL_STRING "Erasing error. Check drive, then click OK to try again."

        ;; "Unlock File" dialog strings
str_unlock_title:
        PASCAL_STRING "Unlock ..."
str_unlock_ok:
        PASCAL_STRING "Click OK to unlock "
str_unlock_remaining:
        PASCAL_STRING "Files remaining to be unlocked: "

        ;; "Lock File" dialog strings
str_lock_title:
        PASCAL_STRING "Lock ..."
str_lock_ok:
        PASCAL_STRING "Click OK to lock "
str_lock_remaining:
        PASCAL_STRING "Files remaining to be locked: "

        ;; "Get Size" dialog strings
str_size_title:
        PASCAL_STRING "Get Size ..."
str_size_number:
        PASCAL_STRING "Number of files"
str_size_blocks:
        PASCAL_STRING "Blocks used on disk"

        .byte   $6E,$00,$23,$00,$6E,$00,$2B,$00

str_download:
        PASCAL_STRING "DownLoad ..."

str_ramcard_full:
        PASCAL_STRING "The RAMCard is full. The copy was not completed."

str_1_space:
        PASCAL_STRING " "

str_warning:
        PASCAL_STRING "Warning !"
str_insert_system_disk:
        PASCAL_STRING "Please insert the system disk."
str_selector_list_full:
        PASCAL_STRING "The Selector list is full. You must delete an entry"
str_before_new_entries:
        PASCAL_STRING "before you can add new entries."
str_window_must_be_closed:
        PASCAL_STRING "A window must be closed before opening this new catalog."

str_too_many_windows:
        PASCAL_STRING "There are too many windows open on the desktop !"
str_save_selector_list:
        PASCAL_STRING "Do you want to save the new Selector list"
str_on_system_disk:
        PASCAL_STRING "on the system disk ?"


        .assert * = $B5D9, error, "Segment length mismatch"
        PAD_TO $B600

;;; ==================================================

show_alert_indirection:
        jmp     show_alert_dialog

alert_bitmap:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),PX(%1111111),PX(%1111111),px(%0000000),px(%0000000)
        .byte   px(%0111100),px(%1111100),px(%0000001),px(%1110000),PX(%0000111),px(%0000000),px(%0000000)
        .byte   px(%0111100),px(%1111100),px(%0000011),px(%1100000),px(%0000011),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0000111),PX(%1100111),px(%1111001),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0001111),PX(%1100111),px(%1111001),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),px(%1111001),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),px(%1110011),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),PX(%1100111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),PX(%1001111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),PX(%0011111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),px(%1111110),PX(%0111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),px(%1111100),PX(%1111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),px(%1111100),PX(%1111111),px(%0000000),px(%0000000)
        .byte   px(%0111110),px(%0000000),PX(%0111111),PX(%1111111),PX(%1111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100000),PX(%1111111),px(%1111100),PX(%1111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100001),PX(%1111111),PX(%1111111),PX(%1111111),px(%0000000),px(%0000000)
        .byte   px(%0111000),px(%0000011),PX(%1111111),PX(%1111111),px(%1111110),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)

.proc alert_bitmap_params
        DEFINE_POINT 20, 8      ; viewloc
        .addr   alert_bitmap    ; mapbits
        .byte   7               ; mapwidth
        .byte   0               ; reserved
        DEFINE_RECT 0, 0, $24, $17 ; maprect
.endproc

alert_rect:
        DEFINE_RECT 65, 87, 485, 142
alert_inner_frame_rect1:
        DEFINE_RECT 4, 2, 416, 53
alert_inner_frame_rect2:
        DEFINE_RECT 5, 3, 415, 52

.proc portmap
viewloc:        DEFINE_POINT $41, $57, viewloc
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .byte   MGTK::screen_mapwidth
reserved:       .byte   0
maprect:        DEFINE_RECT 0, 0, $1A4, $37, maprect
.endproc


;;; ==================================================
;;; Show Alert Dialog
;;; Call show_alert_dialog with prompt number in X (???), A = ???

.proc show_alert_dialog_impl

ok_label:
        PASCAL_STRING {"OK            ",GLYPH_RETURN}

try_again_rect:
        DEFINE_RECT 20,37,120,48
try_again_pos:
        DEFINE_POINT 25,47

cancel_rect:
        DEFINE_RECT 300,37,400,48
cancel_pos:
        DEFINE_POINT 305,47

        .word   $BE,$10     ; ???

point8: DEFINE_POINT 75,29, point8

alert_action:  .byte   $00
prompt_addr:    .addr   0

try_again_label:
        PASCAL_STRING "Try Again     A"
cancel_label:
        PASCAL_STRING "Cancel     Esc"

err_00:  PASCAL_STRING "System Error"
err_27:  PASCAL_STRING "I/O error"
err_28:  PASCAL_STRING "No device connected"
err_2B:  PASCAL_STRING "The disk is write protected."
err_40:  PASCAL_STRING "The syntax of the pathname is invalid."
err_44:  PASCAL_STRING "Part of the pathname doesn't exist."
err_45:  PASCAL_STRING "The volume cannot be found."
err_46:  PASCAL_STRING "The file cannot be found."
err_47:  PASCAL_STRING "That name already exists. Please use another name."
err_48:  PASCAL_STRING "The disk is full."
err_49:  PASCAL_STRING "The volume directory cannot hold more than 51 files."
err_4E:  PASCAL_STRING "The file is locked."
err_52:  PASCAL_STRING "This is not a ProDOS disk."
err_57:  PASCAL_STRING "There is another volume with that name on the desktop."
        ;; Below are internal (not ProDOS MLI) error codes.
err_F9:  PASCAL_STRING "There are 2 volumes with the same name."
err_FA:  PASCAL_STRING "This file cannot be run."
err_FB:  PASCAL_STRING "That name is too long."
err_FC:  PASCAL_STRING "Please insert source disk"
err_FD:  PASCAL_STRING "Please insert destination disk"
err_FE:  PASCAL_STRING "BASIC.SYSTEM not found"

        ;; number of alert messages
alert_count:
        .byte   20

        ;; message number-to-index table
        ;; (look up by scan to determine index)
alert_table:
        ;; ProDOS MLI error codes:
        .byte   $00,$27,$28,$2B,$40,$44,$45,$46
        .byte   $47,$48,$49,$4E,$52,$57
        ;; Internal error codes:
        .byte   $F9,$FA,$FB,$FC,$FD,$FE

        ;; alert index to string address
prompt_table:
        .addr   err_00,err_27,err_28,err_2B,err_40,err_44,err_45,err_46
        .addr   err_47,err_48,err_49,err_4E,err_52,err_57,err_F9,err_FA
        .addr   err_FB,err_FC,err_FD,err_FE

        ;; alert index to action (0 = Cancel, $80 = Try Again)
alert_action_table:
        .byte   $00,$00,$00,$80,$00,$80,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$80,$80,$00

        ;; Actual entry point
start:  pha
        txa
        pha
        MGTK_RELAY2_CALL MGTK::HideCursor
        MGTK_RELAY2_CALL MGTK::SetCursor, pointer_cursor
        MGTK_RELAY2_CALL MGTK::ShowCursor

        ;; play bell
        sta     ALTZPOFF
        sta     ROMIN2
        jsr     BELL1
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1

        ldx     #$03
        lda     #$00
LBA0B:  sta     grafport3_viewloc_xcoord,x
        sta     grafport3_cliprect_x1,x
        dex
        bpl     LBA0B
        copy16  #$226, grafport3_cliprect_x2
        copy16  #$B9, grafport3_cliprect_y2
        MGTK_RELAY2_CALL MGTK::SetPort, grafport3
        ldax    portmap::viewloc::xcoord
        jsr     LBF8B
        sty     LBFCA
        sta     LBFCD
        lda     portmap::viewloc::xcoord
        clc
        adc     portmap::maprect::x2
        pha
        lda     portmap::viewloc::xcoord+1
        adc     portmap::maprect::x2+1
        tax
        pla
        jsr     LBF8B
        sty     LBFCC
        sta     LBFCE
        lda     portmap::viewloc::ycoord
        sta     LBFC9
        clc
        adc     portmap::maprect::y2
        sta     LBFCB
        MGTK_RELAY2_CALL MGTK::HideCursor
        jsr     LBE08
        MGTK_RELAY2_CALL MGTK::ShowCursor
        MGTK_RELAY2_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY2_CALL MGTK::PaintRect, alert_rect ; alert background
        MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR ; ensures corners are inverted
        MGTK_RELAY2_CALL MGTK::FrameRect, alert_rect ; alert outline
        MGTK_RELAY2_CALL MGTK::SetPortBits, portmap::viewloc::xcoord
        MGTK_RELAY2_CALL MGTK::FrameRect, alert_inner_frame_rect1 ; inner 2x border
        MGTK_RELAY2_CALL MGTK::FrameRect, alert_inner_frame_rect2
        MGTK_RELAY2_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY2_CALL MGTK::HideCursor
        MGTK_RELAY2_CALL MGTK::PaintBits, alert_bitmap_params
        MGTK_RELAY2_CALL MGTK::ShowCursor
        pla
        tax
        pla
        ldy     alert_count
        dey
LBAE5:  cmp     alert_table,y
        beq     LBAEF
        dey
        bpl     LBAE5
        ldy     #$00
LBAEF:  tya
        asl     a
        tay
        copy16  prompt_table,y, prompt_addr
        cpx     #$00
        beq     LBB0B
        txa
        and     #$FE
        sta     alert_action
        jmp     LBB14

LBB0B:  tya
        lsr     a
        tay
        lda     alert_action_table,y
        sta     alert_action
LBB14:  MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        bit     alert_action
        bpl     LBB5C
        MGTK_RELAY2_CALL MGTK::FrameRect, cancel_rect
        MGTK_RELAY2_CALL MGTK::MoveTo, cancel_pos
        addr_call draw_pascal_string, cancel_label
        bit     alert_action
        bvs     LBB5C
        MGTK_RELAY2_CALL MGTK::FrameRect, try_again_rect
        MGTK_RELAY2_CALL MGTK::MoveTo, try_again_pos
        addr_call draw_pascal_string, try_again_label
        jmp     LBB75

LBB5C:  MGTK_RELAY2_CALL MGTK::FrameRect, try_again_rect
        MGTK_RELAY2_CALL MGTK::MoveTo, try_again_pos
        addr_call draw_pascal_string, ok_label
LBB75:  MGTK_RELAY2_CALL MGTK::MoveTo, point8
        ldax    prompt_addr
        jsr     draw_pascal_string
LBB87:  MGTK_RELAY2_CALL MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_down
        bne     LBB9A
        jmp     LBC0C

LBB9A:  cmp     #MGTK::event_kind_key_down
        bne     LBB87
        lda     event_params_key
        and     #$7F
        bit     alert_action
        bpl     LBBEE
        cmp     #KEY_ESCAPE
        bne     LBBC3
        MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, cancel_rect
        lda     #$01
        jmp     LBC55

LBBC3:  bit     alert_action
        bvs     LBBEE
        cmp     #'a'
        bne     LBBE3
LBBCC:  MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, try_again_rect
        lda     #$00
        jmp     LBC55

LBBE3:  cmp     #'A'
        beq     LBBCC
        cmp     #$0D
        beq     LBBCC
        jmp     LBB87

LBBEE:  cmp     #KEY_RETURN
        bne     LBC09
        MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, try_again_rect
        lda     #$02
        jmp     LBC55

LBC09:  jmp     LBB87

LBC0C:  jsr     LBDE1
        MGTK_RELAY2_CALL MGTK::MoveTo, event_params_coords
        bit     alert_action
        bpl     LBC42
        MGTK_RELAY2_CALL MGTK::InRect, cancel_rect
        cmp     #MGTK::inrect_inside
        bne     :+
        jmp     LBCE9
:       bit     alert_action
        bvs     LBC42
        MGTK_RELAY2_CALL MGTK::InRect, try_again_rect
        cmp     #MGTK::inrect_inside
        bne     LBC52
        jmp     LBC6D

LBC42:  MGTK_RELAY2_CALL MGTK::InRect, try_again_rect
        cmp     #MGTK::inrect_inside
        bne     LBC52
        jmp     LBD65

LBC52:  jmp     LBB87

LBC55:  pha
        MGTK_RELAY2_CALL MGTK::HideCursor
        jsr     LBE5D
        MGTK_RELAY2_CALL MGTK::ShowCursor
        pla
        rts

LBC6D:  MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, try_again_rect
        lda     #$00
        sta     LBCE8
LBC84:  MGTK_RELAY2_CALL MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_up
        beq     LBCDB
        jsr     LBDE1
        MGTK_RELAY2_CALL MGTK::MoveTo, event_params_coords
        MGTK_RELAY2_CALL MGTK::InRect, try_again_rect
        cmp     #MGTK::inrect_inside
        beq     LBCB5
        lda     LBCE8
        beq     LBCBD
        jmp     LBC84

LBCB5:  lda     LBCE8
        bne     LBCBD
        jmp     LBC84

LBCBD:  MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, try_again_rect
        lda     LBCE8
        clc
        adc     #$80
        sta     LBCE8
        jmp     LBC84

LBCDB:  lda     LBCE8
        beq     LBCE3
        jmp     LBB87

LBCE3:  lda     #$00
        jmp     LBC55

LBCE8:  .byte   0
LBCE9:  MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, cancel_rect
        lda     #$00
        sta     LBD64
LBD00:  MGTK_RELAY2_CALL MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_up
        beq     LBD57
        jsr     LBDE1
        MGTK_RELAY2_CALL MGTK::MoveTo, event_params_coords
        MGTK_RELAY2_CALL MGTK::InRect, cancel_rect
        cmp     #MGTK::inrect_inside
        beq     LBD31
        lda     LBD64
        beq     LBD39
        jmp     LBD00

LBD31:  lda     LBD64
        bne     LBD39
        jmp     LBD00

LBD39:  MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, cancel_rect
        lda     LBD64
        clc
        adc     #$80
        sta     LBD64
        jmp     LBD00

LBD57:  lda     LBD64
        beq     LBD5F
        jmp     LBB87

LBD5F:  lda     #$01
        jmp     LBC55

LBD64:  .byte   0
LBD65:  lda     #$00
        sta     LBDE0
        MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, try_again_rect
LBD7C:  MGTK_RELAY2_CALL MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_up
        beq     LBDD3
        jsr     LBDE1
        MGTK_RELAY2_CALL MGTK::MoveTo, event_params_coords
        MGTK_RELAY2_CALL MGTK::InRect, try_again_rect
        cmp     #MGTK::inrect_inside
        beq     LBDAD
        lda     LBDE0
        beq     LBDB5
        jmp     LBD7C

LBDAD:  lda     LBDE0
        bne     LBDB5
        jmp     LBD7C

LBDB5:  MGTK_RELAY2_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY2_CALL MGTK::PaintRect, try_again_rect
        lda     LBDE0
        clc
        adc     #$80
        sta     LBDE0
        jmp     LBD7C

LBDD3:  lda     LBDE0
        beq     LBDDB
        jmp     LBB87

LBDDB:  lda     #$02
        jmp     LBC55
.endproc
        show_alert_dialog := show_alert_dialog_impl::start

;;; ==================================================

LBDE0:  .byte   0
LBDE1:  sub16  event_params_xcoord, portmap::viewloc::xcoord, event_params_xcoord
        sub16  event_params_ycoord, portmap::viewloc::ycoord, event_params_ycoord
        rts

LBE08:  lda     #$00
        sta     LBE37
        lda     #$08
        sta     LBE38
        lda     LBFC9
        jsr     LBF10
        lda     LBFCB
        sec
        sbc     LBFC9
        tax
        inx
LBE21:  lda     LBFCA
        sta     LBE5C
LBE27:  lda     LBE5C
        lsr     a
        tay
        sta     PAGE2OFF        ; main $2000-$3FFF
        bcs     LBE34
        sta     PAGE2ON         ; aux $2000-$3FFF
LBE34:  lda     ($06),y
LBE37           := * + 1
LBE38           := * + 2
        sta     dummy1234
        inc     LBE37
        bne     LBE41
        inc     LBE38
LBE41:  lda     LBE5C
        cmp     LBFCC
        bcs     LBE4E
        inc     LBE5C
        bne     LBE27
LBE4E:  jsr     LBF52
        dex
        bne     LBE21
        ldax    LBE37
        rts

        .byte   0
LBE5C:  .byte   0
LBE5D:  copy16  #$800, LBEBC
        ldx     LBFCD
        ldy     LBFCE
        lda     #$FF
        cpx     #$00
        beq     LBE78
LBE73:  clc
        rol     a
        dex
        bne     LBE73
LBE78:  sta     LBF0C
        eor     #$FF
        sta     LBF0D
        lda     #$01
        cpy     #$00
        beq     LBE8B
LBE86:  sec
        rol     a
        dey
        bne     LBE86
LBE8B:  sta     LBF0E
        eor     #$FF
        sta     LBF0F
        lda     LBFC9
        jsr     LBF10
        lda     LBFCB
        sec
        sbc     LBFC9
        tax
        inx
        lda     LBFCA
        sta     LBF0B
LBEA8:  lda     LBFCA
        sta     LBF0B
LBEAE:  lda     LBF0B
        lsr     a
        tay
        sta     PAGE2OFF        ; main $2000-$3FFF
        bcs     :+
        sta     PAGE2ON         ; aux $2000-$3FFF

        LBEBC := *+1
:       lda     $0800           ; self-modified

        pha
        lda     LBF0B
        cmp     LBFCA
        beq     LBEDD
        cmp     LBFCC
        bne     LBEEB
        lda     ($06),y
        and     LBF0F
        sta     ($06),y
        pla
        and     LBF0E
        ora     ($06),y
        pha
        jmp     LBEEB

LBEDD:  lda     ($06),y
        and     LBF0D
        sta     ($06),y
        pla
        and     LBF0C
        ora     ($06),y
        pha
LBEEB:  pla
        sta     ($06),y
        inc     LBEBC
        bne     LBEF6
        inc     LBEBC+1
LBEF6:  lda     LBF0B
        cmp     LBFCC
        bcs     LBF03
        inc     LBF0B
        bne     LBEAE
LBF03:  jsr     LBF52
        dex
        bne     LBEA8
        rts

        .byte   $00
LBF0B:  .byte   $00
LBF0C:  .byte   $00
LBF0D:  .byte   $00
LBF0E:  .byte   $00
LBF0F:  .byte   $00

LBF10:  sta     LBFCF
        and     #$07
        sta     LBFB0
        lda     LBFCF
        and     #$38
        sta     LBFAF
        lda     LBFCF
        and     #$C0
        sta     LBFAE
        jsr     LBF2C
        rts

LBF2C:  lda     LBFAE
        lsr     a
        lsr     a
        ora     LBFAE
        pha
        lda     LBFAF
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        sta     LBF51
        pla
        ror     a
        sta     $06
        lda     LBFB0
        asl     a
        asl     a
        ora     LBF51
        ora     #$20
        sta     $07
        clc
        rts

LBF51:  .byte   0
LBF52:  lda     LBFB0
        cmp     #$07
        beq     LBF5F
        inc     LBFB0
        jmp     LBF2C

LBF5F:  lda     #$00
        sta     LBFB0
        lda     LBFAF
        cmp     #$38
        beq     LBF74
        clc
        adc     #$08
        sta     LBFAF
        jmp     LBF2C

LBF74:  lda     #$00
        sta     LBFAF
        lda     LBFAE
        clc
        adc     #$40
        sta     LBFAE
        cmp     #$C0
        beq     LBF89
        jmp     LBF2C

LBF89:  sec
        rts

LBF8B:  ldy     #$00
        cpx     #$02
        bne     LBF96
        ldy     #$49
        clc
        adc     #$01
LBF96:  cpx     #$01
        bne     LBFA4
        ldy     #$24
        clc
        adc     #$04
        bcc     LBFA4
        iny
        sbc     #$07
LBFA4:  cmp     #$07
        bcc     LBFAD
        sbc     #$07
        iny
        bne     LBFA4
LBFAD:  rts

LBFAE:  .byte   $00
LBFAF:  .byte   $00
LBFB0:  .byte   $00,$FF,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
LBFC9:  .byte   $00
LBFCA:  .byte   $00
LBFCB:  .byte   $00
LBFCC:  .byte   $00
LBFCD:  .byte   $00
LBFCE:  .byte   $00
LBFCF:  .byte   $00

        ;; Draw pascal string; address in (X,A)
.proc draw_pascal_string
        ptr := $06

        stax    ptr
        ldy     #$00
        lda     (ptr),y         ; Check length
        beq     end
        sta     ptr+2
        inc     ptr
        bne     call
        inc     ptr+1
call:   MGTK_RELAY2_CALL MGTK::DrawText, ptr
end:    rts
.endproc

        ;; MGTK call in Y, params addr (X,A)
.proc MGTK_RELAY2
        sty     call
        stax    addr
        jsr     MGTK::MLI
call:   .byte   0
addr:   .addr   0
        rts
.endproc

        .assert * = $BFFC, error, "Segment length mismatch"
        PAD_TO $C000
.endproc ; desktop_aux

;;; ==================================================
;;;
;;; $C000 - $CFFF is I/O Space
;;;
;;; ==================================================

        .org $D000

;;; Various routines callable from MAIN

;;; ==================================================
;;; MGTK call from main>aux, call in Y, params at (X,A)
.proc MGTK_RELAY
        .assert * = $D000, error, "Entry point mismatch"
        sty     addr-1
        stax    addr
        sta     RAMRDON
        sta     RAMWRTON
        MGTK_CALL 0, 0, addr
        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts
.endproc

;;; ==================================================
;;; SET_POS with params at (X,A) followed by DRAW_TEXT call

.proc SETPOS_RELAY
        stax    addr
        sta     RAMRDON
        sta     RAMWRTON
        MGTK_CALL MGTK::MoveTo, 0, addr
        MGTK_RELAY_CALL MGTK::DrawText, text_buffer2
        tay
        sta     RAMRDOFF
        sta     RAMWRTOFF
        tya
        rts
.endproc

;;; ==================================================
;;; DESKTOP call from main>aux, call in Y params at (X,A)

.proc DESKTOP_RELAY
        sty     addr-1
        stax    addr
        sta     RAMRDON
        sta     RAMWRTON
        DESKTOP_CALL 0, 0, addr
        tay
        sta     RAMRDOFF
        sta     RAMWRTOFF
        tya
        rts
.endproc

.macro DESKTOP_RELAY_CALL call, addr
        ldy     #(call)
    .if .paramcount > 1
        ldax    #(addr)
    .else
        ldax    #0
    .endif
        jsr     DESKTOP_RELAY
.endmacro

;;; ==================================================
;;; Find first 0 in AUX $1F80 ... $1F7F; if present,
;;; mark it 1 and return index+1 in A

.proc DESKTOP_FIND_SPACE
        sta     RAMRDON
        sta     RAMWRTON
        ldx     #0
loop:   lda     $1F80,x
        beq     :+
        inx
        cpx     #$7F
        bne     loop
        rts

:       inx
        txa
        dex
        tay
        lda     #1
        sta     $1F80,x
        sta     RAMRDOFF
        sta     RAMWRTOFF
        tya
        rts
.endproc

;;; ==================================================
;;; Zero the AUX $1F80 table entry in A

.proc DESKTOP_FREE_SPACE
        tay
        sta     RAMRDON
        sta     RAMWRTON
        dey
        lda     #0
        sta     $1F80,y
        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts
.endproc

;;; ==================================================
;;; Copy data to/from buffers (see bufnum / buf3 / table1/2) ???

.proc DESKTOP_COPY_BUF_IMPL
        ptr := $6

from:
        lda     #$80
        bne     :+              ; always

to:
        lda     #$00

:       sta     flag
        jsr     desktop_main_push_zp_addrs

        lda     bufnum
        asl     a               ; * 2
        tax
        copy16  table1,x, ptr

        sta     RAMRDON
        sta     RAMWRTON
        bit     flag
        bpl     set_length

        ;; assign length from buf3
        lda     buf3len
        ldy     #0
        sta     (ptr),y
        jmp     set_copy_ptr

        ;; assign length to buf3
set_length:
        ldy     #0
        lda     (ptr),y
        sta     buf3len

set_copy_ptr:
        copy16  table2,x, ptr
        bit     flag
        bmi     copy_from

        ;; copy into buf3
        ldy     #0              ; flag clear...
:       cpy     buf3len
        beq     done
        lda     (ptr),y
        sta     buf3,y
        iny
        jmp     :-

        ;; copy from buf3
copy_from:
        ldy     #0
:       cpy     buf3len
        beq     done
        lda     buf3,y
        sta     (ptr),y
        iny
        jmp     :-

done:   sta     RAMRDOFF
        sta     RAMWRTOFF
        jsr     desktop_main_pop_zp_addrs
        rts

flag:   .byte   0
        rts                     ; ???
.endproc
        DESKTOP_COPY_FROM_BUF := DESKTOP_COPY_BUF_IMPL::from
        DESKTOP_COPY_TO_BUF := DESKTOP_COPY_BUF_IMPL::to

;;; ==================================================
;;; Assign active state to active_window_id window

.proc DESKTOP_ASSIGN_STATE
        src := $6
        dst := $8

        sta     RAMRDON
        sta     RAMWRTON
        MGTK_CALL MGTK::GetPort, src ; grab window state

        lda     active_window_id   ; which desktop window?
        asl     a
        tax
        copy16  win_table,x, dst
        lda     dst
        clc
        adc     #20             ; add offset
        sta     dst
        bcc     :+
        inc     dst+1

:       ldy     #35             ; copy 35 bytes into window state
loop:   lda     (src),y
        sta     (dst),y
        dey
        bpl     loop

        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts
.endproc

;;; ==================================================
;;; From MAIN, load AUX (X,A) into A

.proc DESKTOP_AUXLOAD
        stx     op+2
        sta     op+1
        sta     RAMRDON
        sta     RAMWRTON
op:     lda     dummy1234
        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts
.endproc

;;; ==================================================
;;; From MAIN, show alert

;;; ...with prompt #0
.proc DESKTOP_SHOW_ALERT0
        ldx     #$00
        ;; fall through
.endproc

;;; ... with prompt # in X
.proc DESKTOP_SHOW_ALERT
        sta     RAMRDON
        sta     RAMWRTON
        jsr     desktop_aux::show_alert_indirection
        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts
.endproc

;;; ============================================================

        .assert * = $D166, error, "Segment length mismatch"
        PAD_TO $D200

pencopy: .byte   0
penOR: .byte   1
penXOR: .byte   2
penBIC: .byte   3
notpencopy: .byte   4
notpenOR: .byte   5
notpenXOR: .byte   6
notpenBIC: .byte   7

;;; ============================================================
;;; Re-use of param space

.proc event_params
kind:   .byte   0
        key := *
        modifiers := *+1
        coords := *
xcoord: .word   0
ycoord: .word   0
.endproc
        event_params_kind := event_params::kind
        event_params_key := event_params::key
        event_params_modifiers := event_params::modifiers
        event_params_coords := event_params::coords
        event_params_xcoord := event_params::xcoord
        event_params_ycoord := event_params::ycoord

        ;; When event_params_coords is used for FindControl/FindWindow/ScreenToWindow

trackthumb_params := event_params
trackthumb_which_ctl := trackthumb_params
trackthumb_mousex := trackthumb_params + 1
trackthumb_mousey := trackthumb_params + 3
trackthumb_thumbpos := trackthumb_params + 5
trackthumb_thumbmoved := trackthumb_params + 6

updatethumb_params := event_params
updatethumb_params_which_ctl := updatethumb_params
updatethumb_params_thumbpos := updatethumb_params + 1

screentowindow_windowx:
findcontrol_which_ctl:
findwindow_params_which_area:
findicon_which_icon:
        .byte   0
findcontrol_which_part:
findwindow_params_window_id:
        .byte   0

screentowindow_windowy:
        .byte   0
        .byte   0

LD211:  .byte   0


.proc getwinport_params2
window_id:     .byte   0
a_grafport:     .addr   grafport2
.endproc

.proc grafport2
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   0
mapwidth:       .word   0
cliprect:       DEFINE_RECT 0, 0, 0, 0, cliprect
penpattern:     .res    8, 0
colormasks:     .byte   0, 0
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   0
penheight:      .byte   0
penmode:        .byte   0
textbg: .byte   0
fontptr:        .addr   0
.endproc

.proc grafport3
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   0
mapwidth:       .word   0
cliprect:       DEFINE_RECT 0, 0, 0, 0, cliprect
penpattern:     .res    8, 0
colormasks:     .byte   0, 0
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   0
penheight:      .byte   0
penmode:        .byte   0
textbg: .byte   0
fontptr:        .addr   0
.endproc
        grafport3_viewloc_xcoord := grafport3::viewloc::xcoord
        grafport3_cliprect_x1 := grafport3::cliprect::x1
        grafport3_cliprect_x2 := grafport3::cliprect::x2
        grafport3_cliprect_y2 := grafport3::cliprect::y2

.proc grafport5
viewloc:        DEFINE_POINT 0, 0, viewloc
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, 10, 10, cliprect
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg: .byte   0
fontptr:        .addr   DEFAULT_FONT
.endproc


white_pattern3:                 ; unused?
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   %11111111
        .byte   $FF

black_pattern3:                 ; unused?
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   $FF

checkerboard_pattern3:
        .byte   px(%1010101)
        .byte   PX(%0101010)
        .byte   px(%1010101)
        .byte   PX(%0101010)
        .byte   px(%1010101)
        .byte   PX(%0101010)
        .byte   px(%1010101)
        .byte   PX(%0101010)

        .byte   $FF

        ;; Copies of ROM bytes used for machine identification
id_byte_1:  .byte   $06             ; ROM FBB3 ($06 = IIe or later)
id_byte_2:  .byte   $EA             ; ROM FBC0 ($EA = IIe, $E0 = IIe enh/IIgs, $00 = IIc/IIc+)

        .byte   $00,$00,$00,$00,$88,$00,$08,$00
        .byte   $13

zp_use_flag0:
        .byte   0

.proc trackgoaway_params        ; next 3 bytes???
goaway:.byte   0
.endproc
LD2A9:  .byte   0
double_click_flag:
        .byte   0               ; high bit clear if double-clicked, set otherwise

        ;; Set to specific machine type; used for double-click timing.
machine_type:
        .byte   $00             ; Set to: $96 = IIe, $FA = IIc, $FD = IIgs

warning_dialog_num:
        .byte   $00

;;; Cursors (bitmap - 2x12 bytes, mask - 2x12 bytes, hotspot - 2 bytes)

;;; Pointer

pointer_cursor:
        .byte   px(%0000000),px(%0000000)
        .byte   px(%0100000),px(%0000000)
        .byte   px(%0110000),px(%0000000)
        .byte   px(%0111000),px(%0000000)
        .byte   px(%0111100),px(%0000000)
        .byte   px(%0111110),px(%0000000)
        .byte   px(%0111111),px(%0000000)
        .byte   px(%0101100),px(%0000000)
        .byte   px(%0000110),px(%0000000)
        .byte   px(%0000110),px(%0000000)
        .byte   px(%0000011),px(%0000000)
        .byte   px(%0000000),px(%0000000)
        .byte   px(%1100000),px(%0000000)
        .byte   px(%1110000),px(%0000000)
        .byte   px(%1111000),px(%0000000)
        .byte   px(%1111100),px(%0000000)
        .byte   px(%1111110),px(%0000000)
        .byte   px(%1111111),px(%0000000)
        .byte   px(%1111111),px(%1000000)
        .byte   px(%1111111),px(%0000000)
        .byte   px(%0001111),px(%0000000)
        .byte   px(%0001111),px(%0000000)
        .byte   px(%0000111),px(%1000000)
        .byte   px(%0000111),px(%1000000)
        .byte   1,1

;;; Insertion Point
insertion_point_cursor:
        .byte   px(%0000000),px(%0000000)
        .byte   px(%0110001),px(%1000000)
        .byte   px(%0001010),px(%0000000)
        .byte   px(%0000100),px(%0000000)
        .byte   px(%0000100),px(%0000000)
        .byte   px(%0000100),px(%0000000)
        .byte   px(%0000100),px(%0000000)
        .byte   px(%0000100),px(%0000000)
        .byte   px(%0001010),px(%0000000)
        .byte   px(%0110001),px(%1000000)
        .byte   px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000)
        .byte   px(%0110001),px(%1000000)
        .byte   px(%1111011),px(%1100000)
        .byte   px(%0111111),px(%1000000)
        .byte   px(%0001110),px(%0000000)
        .byte   px(%0001110),px(%0000000)
        .byte   px(%0001110),px(%0000000)
        .byte   px(%0001110),px(%0000000)
        .byte   px(%0001110),px(%0000000)
        .byte   px(%0111111),px(%1000000)
        .byte   px(%1111011),px(%1100000)
        .byte   px(%0110001),px(%1000000)
        .byte   px(%0000000),px(%0000000)
        .byte   4, 5

;;; Watch
watch_cursor:
        .byte   px(%0000000),px(%0000000)
        .byte   px(%0011111),px(%1100000)
        .byte   px(%0011111),px(%1100000)
        .byte   px(%0100000),px(%0010000)
        .byte   px(%0100001),px(%0010000)
        .byte   px(%0100110),px(%0011000)
        .byte   px(%0100000),px(%0010000)
        .byte   px(%0100000),px(%0010000)
        .byte   px(%0011111),px(%1100000)
        .byte   px(%0011111),px(%1100000)
        .byte   px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000)
        .byte   px(%0011111),px(%1100000)
        .byte   px(%0111111),px(%1110000)
        .byte   px(%0111111),px(%1110000)
        .byte   px(%1111111),px(%1111000)
        .byte   px(%1111111),px(%1111000)
        .byte   px(%1111111),px(%1111100)
        .byte   px(%1111111),px(%1111000)
        .byte   px(%1111111),px(%1111000)
        .byte   px(%0111111),px(%1110000)
        .byte   px(%0111111),px(%1110000)
        .byte   px(%0011111),px(%1100000)
        .byte   px(%0000000),px(%0000000)
        .byte   5, 5

LD343:  .res    18, 0
LD355:  .res    173, 0

path_buf0:  .res    65, 0
path_buf1:  .res    65, 0
path_buf2:  .res    65, 0


alert_bitmap2:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),px(%0000000),PX(%1111111),PX(%1111111),px(%0000000),px(%0000000)
        .byte   px(%0111100),px(%1111100),px(%0000001),px(%1110000),PX(%0000111),px(%0000000),px(%0000000)
        .byte   px(%0111100),px(%1111100),px(%0000011),px(%1100000),px(%0000011),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0000111),PX(%1100111),px(%1111001),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0001111),PX(%1100111),px(%1111001),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),px(%1111001),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),px(%1110011),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),PX(%1100111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),PX(%1001111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),PX(%1111111),PX(%0011111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),px(%1111110),PX(%0111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),px(%1111100),PX(%1111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1111100),PX(%0011111),px(%1111100),PX(%1111111),px(%0000000),px(%0000000)
        .byte   px(%0111110),px(%0000000),PX(%0111111),PX(%1111111),PX(%1111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100000),PX(%1111111),px(%1111100),PX(%1111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100001),PX(%1111111),PX(%1111111),PX(%1111111),px(%0000000),px(%0000000)
        .byte   px(%0111000),px(%0000011),PX(%1111111),PX(%1111111),px(%1111110),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0111111),px(%1100000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)

alert_bitmap2_params:
        DEFINE_POINT 40, 8      ; viewloc
        .addr   alert_bitmap2   ; mapbits
        .byte   7               ; mapwidth
        .byte   0               ; reserved
        DEFINE_RECT 0, 0, $24, $17 ; maprect

        ;; Looks like window param blocks starting here

.proc winfoF
window_id:      .byte   $0F
options:        .byte   MGTK::option_dialog_box
title:  .addr   0
hscroll:        .byte   MGTK::scroll_option_none
vscroll:        .byte   MGTK::scroll_option_none
hthumbmax:      .byte   0
hthumbpos:      .byte   0
vthumbmax:      .byte   0
vthumbpos:      .byte   0
status: .byte   0
reserved:       .byte   0
mincontwidth:   .word   $96
maxcontwidth:   .word   $32
mincontlength:  .word   $1F4
maxcontlength:  .word   $8C
port:
viewloc:        DEFINE_POINT $4B, $23
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, $190, $64
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg: .byte   MGTK::textbg_white
fontptr:        .addr   DEFAULT_FONT
nextwinfo:      .addr   0
.endproc

.proc winfo12
window_id:      .byte   $12
options:        .byte   MGTK::option_dialog_box
title:  .addr   0
hscroll:        .byte   MGTK::scroll_option_none
vscroll:        .byte   MGTK::scroll_option_none
hthumbmax:      .byte   0
hthumbpos:      .byte   0
vthumbmax:      .byte   0
vthumbpos:      .byte   0
status: .byte   0
reserved:       .byte   0
mincontwidth:   .word   $96
maxcontwidth:   .word   $32
mincontlength:  .word   $1F4
maxcontlength:  .word   $8C
port:
viewloc:        DEFINE_POINT $19, $14
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, $1F4, $99
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg: .byte   MGTK::textbg_white
fontptr:        .addr   DEFAULT_FONT
nextwinfo:      .addr   0
.endproc

.proc winfo15
window_id:      .byte   $15
options:        .byte   MGTK::option_dialog_box
title:  .addr   0
hscroll:        .byte   MGTK::scroll_option_none
vscroll:        .byte   MGTK::scroll_option_normal
hthumbmax:      .byte   0
hthumbpos:      .byte   0
vthumbmax:      .byte   3
vthumbpos:      .byte   0
status: .byte   0
reserved:       .byte   0
mincontwidth:   .word   $64
maxcontwidth:   .word   $46
mincontlength:  .word   $64
maxcontlength:  .word   $46
port:
viewloc:        DEFINE_POINT $35, $32
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, $7D, $46
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg: .byte   MGTK::textbg_white
fontptr:        .addr   DEFAULT_FONT
nextwinfo:      .addr   0
.endproc

.proc winfo18
window_id:      .byte   $18
options:        .byte   MGTK::option_dialog_box
title:  .addr   0
hscroll:        .byte   MGTK::scroll_option_none
vscroll:        .byte   MGTK::scroll_option_none
hthumbmax:      .byte   0
hthumbpos:      .byte   0
vthumbmax:      .byte   0
vthumbpos:      .byte   0
status: .byte   0
reserved:       .byte   0
mincontwidth:   .word   $96
maxcontwidth:   .word   $32
mincontlength:  .word   $1F4
maxcontlength:  .word   $8C
port:
viewloc:        DEFINE_POINT $50, $28
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, $190, $6E
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg: .byte   MGTK::textbg_white
fontptr:        .addr   DEFAULT_FONT
nextwinfo:      .addr   0
.endproc
winfo18_port    := winfo18::port

.proc winfo1B
window_id:      .byte   $1B
options:        .byte   MGTK::option_dialog_box
title:  .addr   0
hscroll:        .byte   MGTK::scroll_option_none
vscroll:        .byte   MGTK::scroll_option_none
hthumbmax:      .byte   0
hthumbpos:      .byte   0
vthumbmax:      .byte   0
vthumbpos:      .byte   0
status: .byte   0
reserved:       .byte   0
mincontwidth:   .word   $96
maxcontwidth:   .word   $32
mincontlength:  .word   $1F4
maxcontlength:  .word   $8C
port:
viewloc:        DEFINE_POINT $69, $19
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, $15E, $6E
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg: .byte   MGTK::textbg_white
fontptr:        .addr   DEFAULT_FONT
nextwinfo:      .addr   0
.endproc

        ;; Coordinates for labels?
        .byte   $28,$00,$25,$00,$68,$01,$2F,$00,$2D,$00,$2E,$00
rect1:  DEFINE_RECT 40,61,360,71, rect1
point6: DEFINE_POINT 45,70, point6
point4: DEFINE_POINT 0, 18, point4
point7: DEFINE_POINT 40,18, point7
pointD: DEFINE_POINT $28, $23, pointD

dialog_label_pos:
        DEFINE_POINT 40,0

.proc setportbits_params3
        DEFINE_POINT 75, 35
        .addr   MGTK::screen_mapbits
        .byte   MGTK::screen_mapwidth
        .byte   0
        DEFINE_RECT 0, 0, $166, $64
.endproc

        ;; ???
        .byte   $00,$04,$00,$02,$00,$5A,$01,$6C,$00,$05,$00,$03,$00,$59,$01,$6B,$00,$06,$00,$16,$00,$58,$01,$16,$00,$06,$00,$59,$00,$58,$01,$59,$00,$D2,$00,$5C,$00,$36,$01,$67,$00,$28,$00,$5C,$00,$8C,$00,$67,$00,$D7,$00,$66,$00,$2D,$00,$66,$00,$82,$00,$07,$00,$DC,$00,$13,$00

LD718:  PASCAL_STRING "Add an Entry ..."
LD729:  PASCAL_STRING "Edit an Entry ..."
LD73B:  PASCAL_STRING "Delete an Entry ..."
LD74F:  PASCAL_STRING "Run an Entry ..."

LD760:  PASCAL_STRING "Run list"
        PASCAL_STRING "Enter the full pathname of the run list file:"
        PASCAL_STRING "Enter the name (14 characters max)  you wish to appear in the run list"
        PASCAL_STRING "Add a new entry to the:"
        PASCAL_STRING {GLYPH_OAPPLE,"1 Run list"}
        PASCAL_STRING {GLYPH_OAPPLE,"2 Other Run list"}
        PASCAL_STRING "Down load:"
        PASCAL_STRING {GLYPH_OAPPLE,"3 at first boot"}
        PASCAL_STRING {GLYPH_OAPPLE,"4 at first use"}
        PASCAL_STRING {GLYPH_OAPPLE,"5 never"}
        PASCAL_STRING "Enter the full pathname of the run list file:"

        .byte   $00,$00,$00,$00,$00,$00,$00
        .byte   $00,$06,$00,$17,$00,$58,$01,$57
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00

        PASCAL_STRING "the DOS 3.3 disk in slot   drive   ?"

        .byte   $1A,$22

        PASCAL_STRING "the disk in slot   drive   ?"

        .byte   $12
        .byte   $1A

buf_filename:
        .res    16, 0

LD8E7:  .byte   0
LD8E8:  .byte   0
LD8E9:  .byte   $14
        .byte   $00
LD8EB:  .byte   0
LD8EC:  .byte   0
LD8ED:  .byte   0
LD8EE:  .byte   1
LD8EF:  .byte   6

LD8F0:  .byte   0
LD8F1:  .byte   0
LD8F2:  .byte   0
LD8F3:  .byte   0
LD8F4:  .byte   0
LD8F5:  .byte   0

str_1_char:
        PASCAL_STRING {0}

str_2_spaces:
        PASCAL_STRING "  "

str_files:
        PASCAL_STRING "Files"

str_7_spaces:
        PASCAL_STRING "       "

LD909:  .byte   $00
LD90A:  .byte   $00

        .byte   $00,$00,$0D
        .byte   $00,$00,$00,$00,$00,$7D,$00,$00
        .byte   $00,$02,$00,$00,$00,$00,$00,$02
        .byte   $01,$02,$00,$00,$57,$01,$28,$00
        .byte   $6B,$01,$30,$00,$6B,$01,$38,$00
        .byte   $57,$01,$4B,$00,$6B,$01,$53,$00
        .byte   $6B,$01,$5B,$00,$6B,$01,$63,$00
        .byte   $5A,$01,$29,$00,$64,$01,$2F,$00
        .byte   $5A,$01,$31,$00,$64,$01,$37,$00
        .byte   $5A,$01,$4C,$00,$64,$01,$52,$00
        .byte   $5A,$01,$54,$00,$64,$01,$5A,$00
        .byte   $5A,$01,$5C,$00,$64,$01,$62,$00
        .byte   $5A,$01,$29,$00,$E0,$01,$30,$00
        .byte   $5A,$01,$31,$00,$E0,$01,$37,$00
        .byte   $5A,$01,$4C,$00,$E0,$01,$53,$00
        .byte   $5A,$01,$54,$00,$E0,$01,$5B,$00
        .byte   $5A,$01,$5C,$00,$E0,$01,$63,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$04,$00,$02,$00,$F0,$01
        .byte   $97,$00,$1B,$00,$10,$00,$AE,$00
        .byte   $1A,$00,$C1,$00,$3A,$00,$25,$01
        .byte   $45,$00,$C1,$00,$59,$00,$25,$01
        .byte   $64,$00,$C1,$00,$2C,$00,$25,$01
        .byte   $37,$00,$C1,$00,$49,$00,$25,$01
        .byte   $54,$00,$C1,$00,$1E,$00,$25,$01
        .byte   $29,$00,$43,$01,$1E,$00,$43,$01
        .byte   $64,$00,$81,$D3,$00

        .word   $C6,$63
        PASCAL_STRING {"OK            ",GLYPH_RETURN}

        .word   $C6,$44
        PASCAL_STRING "Close"

        .word   $C6,$36
        PASCAL_STRING "Open"

        .word   $C6,$53
        PASCAL_STRING "Cancel        Esc"

        .word   $C6,$28
        PASCAL_STRING "Change Drive"

        .byte   $1C,$00,$19,$00,$1C
        .byte   $00,$70,$00,$1C,$00,$87,$00,$00
        .byte   $7F

        PASCAL_STRING " Disk: "

        PASCAL_STRING "Copy a File ..."
        PASCAL_STRING "Source filename:"
        PASCAL_STRING "Destination filename:"

        .byte   $1C,$00,$71,$00,$CF,$01,$7C,$00
        .byte   $1E,$00,$7B,$00,$1C,$00,$88,$00
        .byte   $CF,$01,$93,$00,$1E,$00,$92,$00

        PASCAL_STRING "Delete a File ..."
        PASCAL_STRING "File to delete:"

        .assert * = $DAD8, error, "Segment length mismatch"
        PAD_TO $DB00

;;; ==================================================

        .addr   sd0s, sd1s, sd2s, sd3s, sd4s, sd5s, sd6s
        .addr   sd7s, sd8s, sd9s, sd10s, sd11s, sd12s, sd13s

        .addr   selector_menu

        ;; Buffer for Run List entries
run_list_entries:
        .res    640, 0

LDD9E:  .byte   0

        ;; Icon to File mapping table
        ;;
        ;; each entry is 27 bytes long
        ;;      .byte icon      index
        ;;      .byte ??
        ;;      .byte type/icon (bits 4,5,6 are type)
        ;;                      $00 = directory
        ;;                      $10 = system
        ;;                      $20 = binary
        ;;                      $30 = basic
        ;;                      $50 = text, generic
        ;;      .word iconx     (pixels)
        ;;      .word icony     (pixels)
        ;;      .addr iconbits  (addr of {mapbits, mapwidth, reserved, maprect})
        ;;      .byte len       (name length + 2)
        ;;      .res  17  name  (name, with a space before and after)
        ;;
        ;; (likely point into buffer at $ED00, which has room for 127*27)
file_address_table:
        .assert * = file_table, error, "Entry point mismatch"
        .res    256, 0

        ;; Used by DESKTOP_COPY_*_BUF
        .assert * = bufnum, error, "Entry point mismatch"
bufnum: .byte   $00
buf3len:.byte   0
buf3:   .res    127, 0

selected_window_index: ; index of selected window (used to get prefix)
        .assert * = path_index, error, "Entry point mismatch"
        .byte   0

is_file_selected:               ; 0 if no selection, 1 otherwise
        .assert * = file_selected, error, "Entry point mismatch"
        .byte   0

selected_file_index:            ; index of selected icon (global, not w/in window)
        .assert * = file_index, error, "Entry point mismatch"
        .byte   0

        .res    126, 0


        ;; Buffer for desktop windows
win_table:
        .addr   0,winfo1,winfo2,winfo3,winfo4,winfo5,winfo6,winfo7,winfo8

        ;; Window to Path mapping table
window_address_table:
        .assert * = path_table, error, "Entry point mismatch"
        .addr   $0000
        .repeat 8,i
        .addr   window_path_table+i*65
        .endrepeat

LDFC5:  .byte   0
LDFC6:  .byte   0
LDFC7:  .byte   0
LDFC8:  .byte   0

LDFC9:  .res    145, 0

        .byte   $00,$00,$00,$00,$0D,$00,$00,$00


        ;; In here, at $E196, is a device table
        .res    440, 0

        .byte   $00,$00,$00,$00,$7F,$64,$00,$1C
        .byte   $00,$1E,$00,$32,$00,$1E,$00,$40
        .byte   $00

        ;; DT_HIGHLIGHT_ICON params
LE22B:
        .byte   $00

        .byte   $00,$00

        ;; DT_UNHIGHLIGHT_ICON params
LE22E:
        .byte   $00

        ;; DT_HIGHLIGHT_ICON params
        ;; DT_UNHIGHLIGHT_ICON params
LE22F:  .byte   0

rect_E230:  DEFINE_RECT 0,0,0,0

        .byte   $00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

.proc menu_click_params
menu_id:.byte   0
item_num:.byte  0
.endproc

        .byte   $00,$00,$00,$00,$00,$00
        .byte   $00,$04,$00,$00,$00

.proc checkitem_params
menu_id:        .byte   4
menu_item:      .byte   0
check:          .byte   0
.endproc

.proc disablemenu_params
menu_id:        .byte   4
disable:        .byte   0
.endproc

.proc disableitem_params
menu_id:        .byte   0
menu_item:      .byte   0
disable:        .byte   0
.endproc

        .byte   $00,$04,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .addr   str_all

LE27C:  DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM sd0s
        DEFINE_MENU_ITEM sd1s
        DEFINE_MENU_ITEM sd2s
        DEFINE_MENU_ITEM sd3s
        DEFINE_MENU_ITEM sd4s
        DEFINE_MENU_ITEM sd5s
        DEFINE_MENU_ITEM sd6s
        DEFINE_MENU_ITEM sd7s
        DEFINE_MENU_ITEM sd8s
        DEFINE_MENU_ITEM sd9s
        DEFINE_MENU_ITEM sd10s
        DEFINE_MENU_ITEM sd11s
        DEFINE_MENU_ITEM sd12s
        DEFINE_MENU_ITEM sd13s

startup_menu:
        DEFINE_MENU 7
        DEFINE_MENU_ITEM s00
        DEFINE_MENU_ITEM s01
        DEFINE_MENU_ITEM s02
        DEFINE_MENU_ITEM s03
        DEFINE_MENU_ITEM s04
        DEFINE_MENU_ITEM s05
        DEFINE_MENU_ITEM s06

str_all:PASCAL_STRING "All"

sd0:    DEFINE_STRING "Slot    drive       ", sd0s
sd1:    DEFINE_STRING "Slot    drive       ", sd1s
sd2:    DEFINE_STRING "Slot    drive       ", sd2s
sd3:    DEFINE_STRING "Slot    drive       ", sd3s
sd4:    DEFINE_STRING "Slot    drive       ", sd4s
sd5:    DEFINE_STRING "Slot    drive       ", sd5s
sd6:    DEFINE_STRING "Slot    drive       ", sd6s
sd7:    DEFINE_STRING "Slot    drive       ", sd7s
sd8:    DEFINE_STRING "Slot    drive       ", sd8s
sd9:    DEFINE_STRING "Slot    drive       ", sd9s
sd10:   DEFINE_STRING "Slot    drive       ", sd10s
sd11:   DEFINE_STRING "Slot    drive       ", sd11s
sd12:   DEFINE_STRING "Slot    drive       ", sd12s
sd13:   DEFINE_STRING "Slot    drive       ", sd13s

s00:    PASCAL_STRING "Slot 0 "
s01:    PASCAL_STRING "Slot 0 "
s02:    PASCAL_STRING "Slot 0 "
s03:    PASCAL_STRING "Slot 0 "
s04:    PASCAL_STRING "Slot 0 "
s05:    PASCAL_STRING "Slot 0 "
s06:    PASCAL_STRING "Slot 0 "

        .addr   sd0, sd1, sd2, sd3, sd4, sd5, sd6, sd7
        .addr   sd8, sd9, sd10, sd11, sd12, sd13

str_profile_slot_x:
        PASCAL_STRING "ProFile Slot x     "
str_unidisk_xy:
        PASCAL_STRING "UniDisk 3.5  Sx,y  "
str_ramcard_slot_x:
        PASCAL_STRING "RAMCard Slot x      "
str_slot_drive:
        PASCAL_STRING "Slot    drive       "

selector_menu:
        DEFINE_MENU 5
        DEFINE_MENU_ITEM label_add
        DEFINE_MENU_ITEM label_edit
        DEFINE_MENU_ITEM label_del
        DEFINE_MENU_ITEM label_run, '0', '0'
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM run_list_entries + 0 * $10, '1', '1'
        DEFINE_MENU_ITEM run_list_entries + 1 * $10, '2', '2'
        DEFINE_MENU_ITEM run_list_entries + 2 * $10, '3', '3'
        DEFINE_MENU_ITEM run_list_entries + 3 * $10, '4', '4'
        DEFINE_MENU_ITEM run_list_entries + 4 * $10, '5', '5'
        DEFINE_MENU_ITEM run_list_entries + 5 * $10, '6', '6'
        DEFINE_MENU_ITEM run_list_entries + 6 * $10, '7', '7'
        DEFINE_MENU_ITEM run_list_entries + 7 * $10, '8', '8'

label_add:
        PASCAL_STRING "Add an Entry ..."
label_edit:
        PASCAL_STRING "Edit an Entry ..."
label_del:
        PASCAL_STRING "Delete an Entry ...      "
label_run:
        PASCAL_STRING "Run an Entry ..."

        ;; Apple Menu
apple_menu:
        DEFINE_MENU 1
        DEFINE_MENU_ITEM label_about
        DEFINE_MENU_SEPARATOR
        DEFINE_MENU_ITEM buf + 0 * $10
        DEFINE_MENU_ITEM buf + 1 * $10
        DEFINE_MENU_ITEM buf + 2 * $10
        DEFINE_MENU_ITEM buf + 3 * $10
        DEFINE_MENU_ITEM buf + 4 * $10
        DEFINE_MENU_ITEM buf + 5 * $10
        DEFINE_MENU_ITEM buf + 6 * $10
        DEFINE_MENU_ITEM buf + 7 * $10

label_about:
        PASCAL_STRING "About Apple II DeskTop ... "

buf:    .res    $80, 0

splash_menu:
        DEFINE_MENU_BAR 1
        DEFINE_MENU_BAR_ITEM 1, splash_menu_label, dummy_dd_menu

blank_menu:
        DEFINE_MENU_BAR 1
        DEFINE_MENU_BAR_ITEM 1, blank_dd_label, dummy_dd_menu

dummy_dd_menu:
        DEFINE_MENU 1
        DEFINE_MENU_ITEM dummy_dd_item

splash_menu_label:
        PASCAL_STRING "Apple II DeskTop Version 1.1"

blank_dd_label:
        PASCAL_STRING " "
dummy_dd_item:
        PASCAL_STRING "Rien"    ; ???

        ;; DT_UNHIGHLIGHT_ICON params
LE6BE:
        .byte   $00

        .byte   $00,$00

LE6C1:
        .addr   winfo1title_ptr
        .addr   winfo2title_ptr
        .addr   winfo3title_ptr
        .addr   winfo4title_ptr
        .addr   winfo5title_ptr
        .addr   winfo6title_ptr
        .addr   winfo7title_ptr
        .addr   winfo8title_ptr

win_buf_table:                  ; ???
        .res    8, 0

point9: DEFINE_POINT 0, 0, point9
pointA: DEFINE_POINT 112, 0, pointA
pointB: DEFINE_POINT 140, 0, pointB
pointC: DEFINE_POINT 231, 0, pointC

.proc text_buffer2
        .addr   data
length: .byte   0
data:   .res    55, 0
.endproc

.macro WINFO_DEFN id, label, buflabel
.proc label
window_id:      .byte   id
options:        .byte   MGTK::option_go_away_box | MGTK::option_grow_box
title:  .addr   buflabel
hscroll:        .byte   MGTK::scroll_option_normal
vscroll:        .byte   MGTK::scroll_option_normal
hthumbmax:      .byte   3
hthumbpos:      .byte   0
vthumbmax:      .byte   3
vthumbpos:      .byte   0
status: .byte   0
reserved:       .byte   0
mincontwidth:   .word   170
maxcontwidth:   .word   50
mincontlength:  .word   545
maxcontlength:  .word   175
port:
viewloc:        DEFINE_POINT 20, 27
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, 440, 120
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc: DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg: .byte   MGTK::textbg_white
fontptr:        .addr   DEFAULT_FONT
nextwinfo:      .addr   0
.endproc

buflabel:       .res    18, 0
.endmacro

        WINFO_DEFN 1, winfo1, winfo1title_ptr
        WINFO_DEFN 2, winfo2, winfo2title_ptr
        WINFO_DEFN 3, winfo3, winfo3title_ptr
        WINFO_DEFN 4, winfo4, winfo4title_ptr
        WINFO_DEFN 5, winfo5, winfo5title_ptr
        WINFO_DEFN 6, winfo6, winfo6title_ptr
        WINFO_DEFN 7, winfo7, winfo7title_ptr
        WINFO_DEFN 8, winfo8, winfo8title_ptr


        ;; 8 entries; each entry is 65 bytes long
        ;; * length-prefixed path string (no trailing /)
window_path_table:
        .res    (8*65), 0

        .res    40, 0

str_items:
        PASCAL_STRING " Items"

items_label_pos:
        DEFINE_POINT 8, 10

point1: DEFINE_POINT 0, 0, point1

point5: DEFINE_POINT 0, 0, point5

str_k_in_disk:
        PASCAL_STRING "K in disk"

str_k_available:
        PASCAL_STRING "K available"

str_6_spaces:
        PASCAL_STRING "      "

LEBE3:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
point2: DEFINE_POINT 0, 0, point2
point3: DEFINE_POINT 0, 0, point3

        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00

LEBFC:  .byte   0               ; flag of some sort ???

        .byte   $00,$00,$00,$00

        ;; Used by DESKTOP_COPY_*_BUF
table1: .addr   $1B00,$1B80,$1C00,$1C80,$1D00,$1D80,$1E00,$1E80,$1F00
table2: .addr   $1B01,$1B81,$1C01,$1C81,$1D01,$1D81,$1E01,$1E81,$1F01

active_window_id:
        .byte   $00

LEC26:
        .res    52, 0

date:  .word   0

        .res    10, 0

        .word   500, 160

        .assert * = $EC6A, error, "Segment length mismatch"
        PAD_TO $ED00

;;; ==================================================
;;;
;;; $ED00 - $FAFF is data buffers
;;;
;;; (there's enough room here for 127 files at 27 bytes each)
;;; ==================================================

        .org $FB00

type_table_addr:  .addr type_table
type_icons_addr:  .addr type_icons
LFB04:  .addr LFB11
type_names_addr:  .addr type_names

type_table:
        .byte   8
        .byte   FT_TYPELESS, FT_SRC, FT_TEXT, FT_BINARY
        .byte   FT_DIRECTORY, FT_SYSTEM, FT_BASIC, FT_BAD

        ;; Used as bitwise-or mask, stored in L7624
        ;; ???
LFB11:  .byte   $60,$50,$50,$50,$20,$00,$10,$30,$10

type_names:
        .byte   " ???"

        ;; Same order as icon list below
        .byte   " ???", " SRC", " TXT", " BIN"
        .byte   " DIR", " SYS", " BAS", " SYS"

        .byte   " BAD"

type_icons:
        .addr  gen, src, txt, bin, dir, sys, bas, app

.macro  DEFICON addr, stride, left, top, width, height
        .addr   addr
        .word   stride, left, top, width, height
.endmacro

gen:    DEFICON generic_icon, 4, 0, 0, 27, 17
src:
txt:    DEFICON text_icon, 4, 0, 0, 27, 17
bin:    DEFICON binary_icon, 4, 0, 0, 27, 17
dir:    DEFICON folder_icon, 4, 0, 0, 27, 17
sys:    DEFICON sys_icon, 4, 0, 0, 27, 17
bas:    DEFICON basic_icon, 4, 0, 0, 27, 17
app:    DEFICON app_icon, 5, 0, 0, 34, 17

;;; Generic

generic_icon:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1000000)
        .byte   px(%1000000),px(%0000000),PX(%0000001),px(%1100000)
        .byte   px(%1000000),px(%0000000),PX(%0000001),px(%0110000)
        .byte   px(%1000000),px(%0000000),PX(%0000001),px(%0011000)
        .byte   px(%1000000),px(%0000000),PX(%0000001),PX(%0001100)
        .byte   px(%1000000),px(%0000000),PX(%0000001),PX(%0000110)
        .byte   px(%1000000),px(%0000000),PX(%0000001),PX(%0000011)
        .byte   px(%1000000),px(%0000000),PX(%0000001),PX(%1111111)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)

generic_mask:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1000000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1100000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1110000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1111000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1111100)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1111110)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)

;;; Text File

text_icon:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1000000)
        .byte   px(%1000000),px(%0000000),PX(%0000001),px(%1100000)
        .byte   px(%1001100),px(%0111110),PX(%0111111),px(%0110000)
        .byte   px(%1000000),px(%0000000),PX(%0000001),px(%0011000)
        .byte   px(%1001111),px(%1100111),px(%1000001),PX(%0001100)
        .byte   px(%1000000),px(%0000000),px(%0000001),px(%0000110)
        .byte   px(%1001111),px(%0011110),px(%0110001),PX(%0000011)
        .byte   px(%1000000),px(%0000000),PX(%0000001),PX(%1111111)
        .byte   px(%1000000),px(%0000000),px(%0000000),px(%0000001)
        .byte   px(%1001111),px(%1100110),px(%0111100),px(%1111001)
        .byte   px(%1000000),px(%0000000),px(%0000000),px(%0000001)
        .byte   px(%1001111),px(%0011110),px(%1111111),px(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1001111),px(%0011111),px(%1001111),px(%1100001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)

text_mask:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1000000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1100000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1110000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1111000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1111100)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),px(%1111110)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)

;;; Binary

binary_icon:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000110),px(%0110000),px(%0000000)
        .byte   px(%0000000),px(%0011000),px(%0001100),px(%0000000)
        .byte   px(%0000000),px(%1100000),px(%0000011),px(%0000000)
        .byte   px(%0000011),px(%0000000),px(%0000000),px(%1100000)
        .byte   px(%0001100),px(%0011000),px(%0011000),px(%0011000)
        .byte   px(%0110000),px(%0100100),px(%0101000),px(%0000110)
        .byte   px(%1000000),px(%0100100),px(%0001000),px(%0000001)
        .byte   px(%0110000),px(%0100100),px(%0001000),px(%0000110)
        .byte   px(%0001100),px(%0011000),px(%0001000),px(%0011000)
        .byte   px(%0000011),px(%0000000),px(%0000000),px(%1100000)
        .byte   px(%0000000),px(%1100000),px(%0000011),px(%0000000)
        .byte   px(%0000000),px(%0011000),px(%0001100),px(%0000000)
        .byte   px(%0000000),px(%0000110),px(%0110000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)

binary_mask:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000111),px(%1110000),px(%0000000)
        .byte   px(%0000000),PX(%0011111),px(%1111100),px(%0000000)
        .byte   px(%0000000),PX(%1111111),PX(%1111111),px(%0000000)
        .byte   px(%0000011),PX(%1111111),PX(%1111111),px(%1100000)
        .byte   PX(%0001111),PX(%1111111),PX(%1111111),px(%1111000)
        .byte   PX(%0111111),PX(%1111111),PX(%1111111),px(%1111110)
        .byte   PX(%0001111),PX(%1111111),PX(%1111111),px(%1111000)
        .byte   px(%0000011),PX(%1111111),PX(%1111111),px(%1100000)
        .byte   px(%0000000),PX(%1111111),PX(%1111111),px(%0000000)
        .byte   px(%0000000),PX(%0011111),px(%1111100),px(%0000000)
        .byte   px(%0000000),px(%0000111),px(%1110000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)

;;; Folder
folder_icon:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0011111),px(%1111110),px(%0000000),px(%0000000)
        .byte   px(%0100000),px(%0000001),px(%0000000),px(%0000000)
        .byte   PX(%0111111),PX(%1111111),PX(%1111111),px(%1111110)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   px(%1000000),px(%0000000),px(%0000000),PX(%0000001)
        .byte   PX(%0111111),PX(%1111111),PX(%1111111),px(%1111110)

folder_mask:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   PX(%0011111),px(%1111110),px(%0000000),px(%0000000)
        .byte   PX(%0111111),PX(%1111111),px(%0000000),px(%0000000)
        .byte   PX(%0111111),PX(%1111111),PX(%1111111),px(%1111110)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%0111111),PX(%1111111),PX(%1111111),px(%1111110)

;;; System (no .SYSTEM suffix)

sys_icon:
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0110000),px(%0000000),px(%0000000),px(%0000110)
        .byte   px(%0110011),px(%1111111),px(%1111111),px(%1100110)
        .byte   px(%0110011),px(%0000000),px(%0010000),px(%1100110)
        .byte   px(%0110011),px(%0000000),px(%0100000),px(%1100110)
        .byte   px(%0110011),px(%0010000),px(%1000100),px(%1100110)
        .byte   px(%0110011),px(%0100000),px(%0001000),px(%1100110)
        .byte   px(%0110011),px(%1111111),px(%1111111),px(%1100110)
        .byte   px(%0110000),px(%0000000),px(%0000000),px(%0000110)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1111111)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000011)
        .byte   px(%1100110),px(%0000000),px(%0000000),px(%0000011)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000011)
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1111111)
        .byte   px(%1100000),px(%0000000),px(%0000000),px(%0000011)
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1111111)

sys_mask:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0001111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0011111),px(%1111111),px(%1111111),px(%1111100)
        .byte   px(%0011111),px(%1111111),px(%1111111),px(%1111100)
        .byte   px(%0011111),px(%1111111),px(%1111111),px(%1111100)
        .byte   px(%0011111),px(%1111111),px(%1111111),px(%1111100)
        .byte   px(%0011111),px(%1111111),px(%1111111),px(%1111100)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)

;;; Basic

basic_icon:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000110),px(%0110000),px(%0000000)
        .byte   px(%0000000),px(%0011000),px(%0001100),px(%0000000)
        .byte   px(%0000000),px(%1100000),px(%0000011),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0111110),px(%0111000),px(%1111010),px(%0111100)
        .byte   px(%0100010),px(%1000100),px(%1000010),px(%1000110)
        .byte   px(%0111100),px(%1111100),px(%1111010),px(%1000000)
        .byte   px(%0100010),px(%1000100),px(%0001010),px(%1000110)
        .byte   px(%0111110),px(%1000100),px(%1111010),px(%0111100)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%1100000),px(%0000011),px(%0000000)
        .byte   px(%0000000),px(%0011000),px(%0001100),px(%0000000)
        .byte   px(%0000000),px(%0000110),px(%0110000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)

basic_mask:
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000111),px(%1110000),px(%0000000)
        .byte   px(%0000000),PX(%0011111),px(%1111100),px(%0000000)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   PX(%1111111),PX(%1111111),PX(%1111111),PX(%1111111)
        .byte   px(%0000000),PX(%0011111),px(%1111100),px(%0000000)
        .byte   px(%0000000),px(%0000111),px(%1110000),px(%0000000)
        .byte   px(%0000000),PX(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000)

;;; System (with .SYSTEM suffix)

app_icon:
        .byte   px(%0000000),px(%0000000),px(%0011000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%1100110),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000011),px(%0000001),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0001100),px(%0000000),px(%0110000),px(%0000000)
        .byte   px(%0000000),px(%0110000),px(%0000000),px(%0001100),px(%0000000)
        .byte   px(%0000001),px(%1000000),px(%0000000),px(%0000011),px(%0000000)
        .byte   px(%0000110),px(%0000000),px(%0000000),px(%0000000),px(%1100000)
        .byte   px(%0011000),px(%0000000),px(%0000001),px(%1111100),px(%0011000)
        .byte   px(%1100000),px(%0000000),px(%0000110),px(%0000011),px(%0000110)
        .byte   px(%0011000),px(%0000000),px(%0011000),px(%1110000),px(%1111000)
        .byte   px(%0000110),px(%0000111),px(%1111111),px(%1111100),px(%0011110)
        .byte   px(%0000001),px(%1000000),px(%0110000),px(%1100000),px(%0011110)
        .byte   px(%0000000),px(%0110000),px(%0001110),px(%0000000),px(%0011110)
        .byte   px(%0000000),px(%0001100),px(%0000001),PX(%1111111),px(%1111110)
        .byte   px(%0000000),px(%0000011),px(%0000001),px(%1000000),px(%0011110)
        .byte   px(%0000000),px(%0000000),px(%1100110),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0011000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)

app_mask:
        .byte   px(%0000000),px(%0000000),px(%0011000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%1111110),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000011),px(%1111111),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0001111),px(%1111111),px(%1110000),px(%0000000)
        .byte   px(%0000000),px(%0111111),px(%1111111),px(%1111100),px(%0000000)
        .byte   px(%0000001),px(%1111111),px(%1111111),px(%1111111),px(%0000000)
        .byte   px(%0000111),px(%1111111),px(%1111111),px(%1111111),px(%1100000)
        .byte   px(%0011111),px(%1111111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%1111111),px(%1111111),px(%1111111),px(%1111111),px(%1111110)
        .byte   px(%0011111),px(%1111111),px(%1111111),px(%1111111),px(%1111100)
        .byte   px(%0000111),px(%1111111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0000001),px(%1111111),px(%1111111),px(%1111111),px(%1111000)
        .byte   px(%0000000),px(%0111111),px(%1111111),px(%1111100),px(%1111000)
        .byte   px(%0000000),px(%0001111),px(%1111111),px(%1111000),px(%0000000)
        .byte   px(%0000000),px(%0000011),px(%1111111),px(%1000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%1111110),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0011000),px(%0000000),px(%0000000)
        .byte   px(%0000000),px(%0000000),px(%0000000),px(%0000000),px(%0000000)

        .assert * = $FFBA, error, "Segment length mismatch"
        PAD_TO $10000

;;; ==================================================
;;; Segment loaded into MAIN $4000-$BEFF
;;; ==================================================

.proc desktop_main
L0020           := $0020
L0800           := $0800
L0CB8           := $0CB8
L0CD7           := $0CD7
L0CF9           := $0CF9
L0D14           := $0D14

        dynamic_routine_800  := $0800
        dynamic_routine_5000 := $5000
        dynamic_routine_7000 := $7000
        dynamic_routine_9000 := $9000

        dynamic_routine_disk_copy    := 0
        dynamic_routine_format_erase := 1
        dynamic_routine_selector1    := 2
        dynamic_routine_common       := 3
        dynamic_routine_file_copy    := 4
        dynamic_routine_file_delete  := 5
        dynamic_routine_selector2    := 6
        dynamic_routine_restore5000  := 7
        dynamic_routine_restore9000  := 8


        .org $4000

        ;; Jump table
        ;; Entries marked with * are used by DAs
        ;; "Exported" by desktop.inc

L4000:                  jmp     L4042 ; ???
JT_MGTK_RELAY:          jmp     MGTK_RELAY
L4006:                  jmp     L8259 ; ???
L4009:                  jmp     compose_date_string ; ???
L400C:                  jmp     L5E78 ; ???
L400F:                  jmp     DESKTOP_AUXLOAD
JT_EJECT:               jmp     cmd_eject
JT_REDRAW_ALL:          jmp     redraw_windows          ; *
JT_DESKTOP_RELAY:       jmp     DESKTOP_RELAY
JT_LOAD_SEG:            jmp     load_dynamic_routine
JT_CLEAR_SELECTION:     jmp     clear_selection         ; *
JT_MLI_RELAY:           jmp     MLI_RELAY               ; *
JT_COPY_TO_BUF:         jmp     DESKTOP_COPY_TO_BUF
JT_COPY_FROM_BUF:       jmp     DESKTOP_COPY_FROM_BUF
JT_NOOP:                jmp     cmd_noop
L402D:                  jmp     L8707 ; ???
JT_SHOW_ALERT0:         jmp     DESKTOP_SHOW_ALERT0
JT_SHOW_ALERT:          jmp     DESKTOP_SHOW_ALERT
JT_LAUNCH_FILE:         jmp     launch_file
JT_CUR_POINTER:         jmp     set_pointer_cursor      ; *
JT_CUR_WATCH:           jmp     set_watch_cursor
JT_RESTORE_SEF:         jmp     restore_dynamic_routine

        ;; API entry point
L4042:  cli
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        jsr     L4530
        ldx     #$00
L4051:  cpx     buf3len
        beq     L4069
        txa
        pha
        lda     buf3,x
        jsr     file_address_lookup
        ldy     #$01
        jsr     DESKTOP_RELAY
        pla
        tax
        inx
        jmp     L4051

L4069:  lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     LD2A9
        sta     double_click_flag
        sta     L40DF
        sta     $E26F
        lda     L599F
        beq     L4088
        tay
        jsr     DESKTOP_SHOW_ALERT0
L4088:  jsr     reset_grafport3
        inc     L40DF
        inc     L40DF
        lda     L40DF
        cmp     machine_type
        bcc     L40A6
        lda     #$00
        sta     L40DF
        jsr     L4563
        beq     L40A6
        jsr     L40E0
L40A6:  jsr     L464E
        jsr     get_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_down
        beq     L40B7
        cmp     #MGTK::event_kind_apple_key
        bne     L40BD
L40B7:  jsr     handle_click
        jmp     L4088

L40BD:  cmp     #$03
        bne     L40C7
        jsr     menu_dispatch
        jmp     L4088

L40C7:  cmp     #$06
        bne     L40DC
        jsr     reset_grafport3
        lda     active_window_id
        sta     L40F0
        lda     #$80
        sta     L40F1
        jsr     L410D
L40DC:  jmp     L4088

L40DF:  .byte   $00
L40E0:  tsx
        stx     $E256
        sta     $E25B
        jsr     L59A0
        lda     #$00
        sta     $E25B
        rts

L40F0:  .byte   $00
L40F1:  .byte   $00
redraw_windows:
        jsr     reset_grafport3
        lda     active_window_id
        sta     L40F0
        lda     #$00
        sta     L40F1
L4100:  jsr     peek_event
        lda     event_params_kind
        cmp     #$06            ; ???
        bne     L412B
        jsr     get_event
L410D:  jsr     L4113
        jmp     L4100

L4113:  MGTK_RELAY_CALL MGTK::BeginUpdate, event_params+1
        bne     L4151
        jsr     L4153
        MGTK_RELAY_CALL MGTK::EndUpdate
        rts

L412B:  lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     L40F0
        sta     active_window_id
        beq     L4143
        bit     running_da_flag
        bmi     L4143
        jsr     L4244
L4143:  bit     L40F1
        bpl     L4151
        DESKTOP_RELAY_CALL DT_REDRAW_ICONS
L4151:  rts

L4152:  .byte   0
L4153:  lda     event_params+1
        cmp     #$09
        bcc     L415B
        rts

L415B:  sta     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     #$80
        sta     L4152
        lda     bufnum
        sta     getwinport_params2::window_id
        jsr     L4505
        jsr     L78EF
        lda     active_window_id
        jsr     L8855
        jsr     DESKTOP_ASSIGN_STATE
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$16
        lda     ($06),y
        sec
        sbc     grafport2::viewloc::ycoord
        sta     L4242
        iny
        lda     ($06),y
        sbc     grafport2::viewloc::ycoord+1
        sta     L4243
        lda     L4242
        cmp     #$0F
        lda     L4243
        sbc     #$00
        bpl     L41CB
        jsr     L6E8A
        ldx     #$0B
        ldy     #$1F
        lda     grafport2,x
        sta     ($06),y
        dey
        dex
        lda     grafport2,x
        sta     ($06),y
        ldx     #$03
        ldy     #$17
        lda     grafport2,x
        sta     ($06),y
        dey
        dex
        lda     grafport2,x
        sta     ($06),y
L41CB:  ldx     bufnum
        dex
        lda     win_buf_table,x
        bpl     L41E2
        jsr     L6C19
        lda     #$00
        sta     L4152
        lda     active_window_id
        jmp     L8874

L41E2:  lda     bufnum
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L6E52
        ldx     #7
L41F0:  lda     grafport2::cliprect::x1,x
        sta     rect_E230,x
        dex
        bpl     L41F0
        lda     #$00
        sta     L4241
L41FE:  lda     L4241
        cmp     buf3len
        beq     L4227
        tax
        lda     buf3,x
        sta     LE22F
        DESKTOP_RELAY_CALL DT_ICON_IN_RECT, LE22F
        beq     L4221
        DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, LE22F
L4221:  inc     L4241
        jmp     L41FE

L4227:  lda     #$00
        sta     L4152
        lda     bufnum
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L6E6E
        lda     active_window_id
        jsr     L8874
        jmp     reset_grafport3

L4241:  .byte   0
L4242:  .byte   0
L4243:  .byte   0
L4244:  lda     is_file_selected
        bne     L424A
L4249:  rts

L424A:  lda     #$00
        sta     L42C3
        lda     selected_window_index
        beq     L42A5
        cmp     active_window_id
        bne     L4249
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L4505
        jsr     L6E8E
        ldx     #7
L4267:  lda     grafport2::cliprect::x1,x
        sta     rect_E230,x
        dex
        bpl     L4267
L4270:  lda     L42C3
        cmp     is_file_selected
        beq     L42A2
        tax
        lda     selected_file_index,x
        sta     LE22F
        jsr     L8915
        DESKTOP_RELAY_CALL DT_ICON_IN_RECT, LE22F
        beq     L4296
        DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, LE22F
L4296:  lda     LE22F
        jsr     L8893
        inc     L42C3
        jmp     L4270

L42A2:  jmp     reset_grafport3

L42A5:  lda     L42C3
        cmp     is_file_selected
        beq     L42A2
        tax
        lda     selected_file_index,x
        sta     LE22F
        DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, LE22F
        inc     L42C3
        jmp     L42A5

L42C3:  .byte   $00

;;; ==================================================
;;; Menu Dispatch

.proc menu_dispatch_impl

        ;; jump table for menu item handlers
dispatch_table:
        ;; Apple menu (1)
        .addr   cmd_about
        .addr   cmd_noop        ; --------
        .addr   cmd_deskacc
        .addr   cmd_deskacc
        .addr   cmd_deskacc
        .addr   cmd_deskacc
        .addr   cmd_deskacc
        .addr   cmd_deskacc
        .addr   cmd_deskacc
        .addr   cmd_deskacc

        ;; File menu (2)
        .addr   cmd_new_folder
        .addr   cmd_noop        ; --------
        .addr   cmd_open
        .addr   cmd_close
        .addr   cmd_close_all
        .addr   cmd_select_all
        .addr   cmd_noop        ; --------
        .addr   cmd_copy_file
        .addr   cmd_delete_file
        .addr   cmd_noop        ; --------
        .addr   cmd_eject
        .addr   cmd_quit

        ;; Selector menu (3)
        .addr   cmd_selector_action
        .addr   cmd_selector_action
        .addr   cmd_selector_action
        .addr   cmd_selector_action
        .addr   cmd_noop        ; --------
        .addr   cmd_selector_item
        .addr   cmd_selector_item
        .addr   cmd_selector_item
        .addr   cmd_selector_item
        .addr   cmd_selector_item
        .addr   cmd_selector_item
        .addr   cmd_selector_item
        .addr   cmd_selector_item

        ;; View menu (4)
        .addr   cmd_view_by_icon
        .addr   cmd_view_by_name
        .addr   cmd_view_by_date
        .addr   cmd_view_by_size
        .addr   cmd_view_by_type

        ;; Special menu (5)
        .addr   cmd_check_drives
        .addr   cmd_noop        ; --------
        .addr   cmd_format_disk
        .addr   cmd_erase_disk
        .addr   cmd_disk_copy
        .addr   cmd_noop        ; --------
        .addr   cmd_lock
        .addr   cmd_unlock
        .addr   cmd_noop        ; --------
        .addr   cmd_get_info
        .addr   cmd_get_size
        .addr   cmd_noop        ; --------
        .addr   cmd_rename_icon

        ;; (6 is duplicated to 5)

        ;; no menu 7 ??
        .addr   cmd_check_drives ; duplicate???
        .addr   cmd_noop        ; --------
        .addr   L59A0           ; ???
        .addr   L59A0
        .addr   L59A0
        .addr   L59A0
        .addr   L59A0
        .addr   L59A0
        .addr   L59A0
        .addr   L59A0

        ;; Startup menu (8)
        .addr   cmd_startup_item
        .addr   cmd_startup_item
        .addr   cmd_startup_item
        .addr   cmd_startup_item
        .addr   cmd_startup_item
        .addr   cmd_startup_item
        .addr   cmd_startup_item

        ;; indexed by menu id-1
offset_table:
        .byte   $00,$14,$2C,$46,$50,$50,$6A,$7E,$8C

flag:   .byte   $00

        ;; Handle accelerator keys
menu_dispatch:
        lda     event_params_modifiers
        bne     :+              ; either OA or CA ?
        jmp     menu_accelerators           ; nope
:       cmp     #3              ; both OA + CA ?
        bne     :+              ; nope
        rts

        ;; Non-menu keys
:       lda     event_params_key
        ora     #$20            ; force to lower-case
        cmp     #'h'            ; OA-H (Highlight Icon)
        bne     :+
        jmp     cmd_higlight
:       bit     flag
        bpl     menu_accelerators
        cmp     #'w'            ; OA-W (Activate Window)
        bne     :+
        jmp     cmd_activate
:       cmp     #'g'            ; OA-G (Resize)
        bne     :+
        jmp     cmd_resize
:       cmp     #'m'            ; OA-M (Move)
        bne     :+
        jmp     cmd_move
:       cmp     #'x'            ; OA-X (Scroll)
        bne     menu_accelerators
        jmp     cmd_scroll

menu_accelerators:
        lda     event_params+1
        sta     $E25C
        lda     event_params+2
        beq     L43A1
        lda     #$01
L43A1:  sta     $E25D
        MGTK_RELAY_CALL MGTK::MenuKey, menu_click_params

menu_dispatch2:
        ldx     menu_click_params::menu_id
        bne     L43B3
        rts

L43B3:  dex                     ; x has top level menu id
        lda     offset_table,x
        tax
        ldy     $E25B
        dey
        tya
        asl     a
        sta     L43E5
        txa
        clc
        adc     L43E5
        tax
        copy16  dispatch_table,x, L43E5
        jsr     L43E0
        MGTK_RELAY_CALL MGTK::HiliteMenu, menu_click_params
        rts

L43E0:  tsx
        stx     $E256
        L43E5 := *+1
        jmp     dummy1234           ; self-modified
.endproc

        menu_dispatch := menu_dispatch_impl::menu_dispatch
        menu_dispatch2 := menu_dispatch_impl::menu_dispatch2
        menu_dispatch_flag := menu_dispatch_impl::flag

;;; ==================================================
;;; Handle click

.proc handle_click
        tsx
        stx     $E256
        MGTK_RELAY_CALL MGTK::FindWindow, event_params_coords
        lda     findwindow_params_which_area
        bne     not_desktop

        ;; Click on desktop
        jsr     detect_double_click
        sta     double_click_flag
        lda     #0
        sta     findwindow_params_window_id
        DESKTOP_RELAY_CALL DT_FIND_ICON, event_params_coords
        lda     findicon_which_icon
        beq     L4415
        jmp     L67D7

L4415:  jmp     L68AA

not_desktop:
        cmp     #MGTK::area_menubar  ; menu?
        bne     not_menu
        MGTK_RELAY_CALL MGTK::MenuSelect, menu_click_params
        jmp     menu_dispatch2

not_menu:
        pha                     ; which window - active or not?
        lda     active_window_id
        cmp     findwindow_params_window_id
        beq     handle_active_window_click
        pla
        jmp     handle_inactive_window_click
.endproc

;;; ==================================================

.proc handle_active_window_click
        pla
        cmp     #MGTK::area_content
        bne     :+
        jsr     detect_double_click
        sta     double_click_flag
        jmp     handle_client_click
:       cmp     #MGTK::area_dragbar
        bne     :+
        jmp     handle_title_click
:       cmp     #MGTK::area_grow_box
        bne     :+
        jmp     handle_resize_click
:       cmp     #MGTK::area_close_box
        bne     :+
        jmp     handle_close_click
:       rts
.endproc

;;; ==================================================

.proc handle_inactive_window_click
        jmp     L445D

L445C:  .byte   0
L445D:  jsr     clear_selection
        ldx     $D20E
        dex
        lda     LEC26,x
        sta     LE22F
        lda     LE22F
        jsr     file_address_lookup
        stax    $06
        ldy     #$01
        lda     ($06),y
        beq     L44A6
        ora     #$80
        sta     ($06),y
        iny
        lda     ($06),y
        and     #$0F
        sta     L445C
        jsr     L8997
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        jsr     reset_grafport3
        lda     L445C
        sta     selected_window_index
        lda     #$01
        sta     is_file_selected
        lda     LE22F
        sta     selected_file_index
L44A6:  MGTK_RELAY_CALL MGTK::SelectWindow, findwindow_params_window_id
        lda     findwindow_params_window_id
        sta     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jsr     L6C19
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     #$00
        sta     checkitem_params::check
        MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params
        ldx     active_window_id
        dex
        lda     win_buf_table,x
        and     #$0F
        sta     checkitem_params::menu_item
        inc     checkitem_params::menu_item
        lda     #$01
        sta     checkitem_params::check
        MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params
        rts
.endproc

;;; ==================================================

L44F2:  MGTK_RELAY_CALL MGTK::GetWinPort, getwinport_params2
        MGTK_RELAY_CALL MGTK::SetPort, grafport2
        rts

L4505:  MGTK_RELAY_CALL MGTK::GetWinPort, getwinport_params2
        rts

        rts

reset_grafport3:
        MGTK_RELAY_CALL MGTK::InitPort, grafport3
        MGTK_RELAY_CALL MGTK::SetPort, grafport3
        rts

;;; ==================================================

.proc redraw_windows_and_desktop
        jsr     redraw_windows
        DESKTOP_RELAY_CALL DT_REDRAW_ICONS
        rts
.endproc

;;; ==================================================

L4530:  ldx     #$00
        ldy     DEVCNT
L4535:  lda     DEVLST,y
        and     #$0F
        cmp     #$0B
        beq     L4559
L453E:  dey
        bpl     L4535
        stx     L4597
        stx     L45A0
        jsr     L45B2
        ldx     L45A0
        beq     L4558
L454F:  lda     L45A0,x
        sta     L45A9,x
        dex
        bpl     L454F
L4558:  rts

L4559:  lda     DEVLST,y
        inx
        sta     L4597,x
        bne     L453E
        rts

L4563:  lda     L45A0
        beq     L4579
        jsr     L45B2
        ldx     L45A0
L456E:  lda     L45A0,x
        cmp     L45A9,x
        bne     L457C
        dex
        bne     L456E
L4579:  lda     #$00
        rts

L457C:  lda     L45A0,x
        sta     L45A9,x
        lda     L4597,x
        ldy     DEVCNT
L4588:  cmp     DEVLST,y
        beq     L4591
        dey
        bpl     L4588
        rts

L4591:  tya
        clc
        adc     #$03
        rts

        .byte   $00
L4597:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
L45A0:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
L45A9:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
L45B2:  ldx     L4597
        beq     L45C6
        stx     L45A0
L45BA:  lda     L4597,x
        jsr     L45C7
        sta     L45A0,x
        dex
        bne     L45BA
L45C6:  rts

L45C7:  sta     L4637
        txa
        pha
        tya
        pha
        ldx     #$11
        lda     L4637
        and     #$80
        beq     L45D9
        ldx     #$21
L45D9:  stx     L45EC
        lda     L4637
        and     #$70
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     L45EC
        sta     L45EC
        L45EC := *+1
        lda     $BF00           ; self-modified
        sta     $06+1
        lda     #0
        sta     $06
        ldy     #$07
        lda     ($06),y
        bne     L4627
        ldy     #$FF
        lda     ($06),y
        clc
        adc     #$03
        sta     $06
        lda     L4637
        pha
        rol     a
        pla
        php
        and     #$20
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        plp

        adc     #1
        sta     L463A

        jsr     L4634
        .byte   0               ; ???
        .addr   L4639

        lda     L463E
        and     #$10
        beq     L4627
        lda     #$FF
        bne     L4629
L4627:  lda     #$00
L4629:  sta     L4638
        pla
        tay
        pla
        tax
        lda     L4638
        rts

L4634:  jmp     ($06)

L4637:  .byte   $00
L4638:  .byte   $00
L4639:  .byte   $03
L463A:  .byte   $01
        .addr   L463E
        .byte   0
L463E:  .res    16, 0

L464E:  lda     LD343
        beq     L465E
        bit     LD343+1
        bmi     L4666
        jsr     L67AB
        jmp     L4666

L465E:  bit     LD343+1
        bmi     L4666
        jsr     L67A3
L4666:  lda     is_file_selected
        beq     L46A8
        lda     selected_window_index
        bne     L4691
        lda     is_file_selected
        cmp     #$02
        bcs     L4697
        lda     selected_file_index
        cmp     $EBFB
        bne     L468B
        jsr     L678A
        jsr     L670C
        lda     #$00
        sta     $E26F
        rts

L468B:  jsr     L6782
        jmp     L469A

L4691:  jsr     L678A
        jmp     L469A

L4697:  jsr     L6782
L469A:  bit     $E26F
        bmi     L46A7
        jsr     L6747
        lda     #$80
        sta     $E26F
L46A7:  rts

L46A8:  bit     $E26F
        bmi     L46AE
        rts

L46AE:  jsr     L678A
        jsr     L670C
        lda     #$00
        sta     $E26F
        rts

MLI_RELAY:
        sty     L46CE
        stax    L46CF
        php
        sei
        sta     ALTZPOFF
        sta     ROMIN2
        jsr     MLI
L46CE:  .byte   $00
L46CF:  .addr   dummy0000
        sta     ALTZPON
        tax
        lda     LCBANK1
        lda     LCBANK1
        plp
        txa
        rts

.macro MLI_RELAY_CALL call, addr
        ldy     #(call)
        ldax    #(addr)
        jsr     desktop_main::MLI_RELAY
.endmacro

;;; ==================================================
;;; Launch file (double-click) ???

.proc launch_file
        jmp     begin

.proc get_file_info_params
param_count:    .byte   $A
pathname:       .addr   $220
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

begin:
        jsr     set_watch_cursor
        ldx     #$FF
L46F8:  inx
        lda     LD355,x
        sta     $220,x
        cpx     LD355
        bne     L46F8
        inx
        lda     #'/'
        sta     $220,x
        ldy     #$00
L470C:  iny
        inx
        lda     $D345,y
        sta     $220,x
        cpy     $D345
        bne     L470C
        stx     $220
        MLI_RELAY_CALL GET_FILE_INFO, get_file_info_params
        beq     L472B
        jsr     DESKTOP_SHOW_ALERT0
        rts

L472B:  lda     get_file_info_params::file_type
        cmp     #FT_BASIC
        bne     L4738
        jsr     L47B8
        jmp     L4755

L4738:  cmp     #FT_BINARY
        bne     L4748
        lda     BUTN0           ; only launch if a button is down
        ora     BUTN1
        bmi     L4755
        jsr     set_pointer_cursor
        rts

L4748:  cmp     #FT_SYSTEM
        beq     L4755

        cmp     #FT_S16
        beq     L4755

        lda     #$FA
        jsr     L4802

L4755:  DESKTOP_RELAY_CALL $06
        MGTK_RELAY_CALL MGTK::CloseAll
        MGTK_RELAY_CALL MGTK::SetMenu, blank_menu
        ldx     LD355
L4773:  lda     LD355,x
        sta     $220,x
        dex
        bpl     L4773
        ldx     $D345
L477F:  lda     $D345,x
        sta     INVOKER_FILENAME,x
        dex
        bpl     L477F
        addr_call L4842, $280
        addr_call L4842, $220
        jsr     L48BE
        copy16  #INVOKER, reset_and_invoke_target
        jmp     reset_and_invoke
.endproc

;;; ==================================================

.proc get_file_info_params2
param_count:    .byte   $A
pathname:       .addr   $1800
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_ysed:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

L47B8:  ldx     LD355
        stx     L4816
L47BE:  lda     LD355,x
        sta     $1800,x
        dex
        bpl     L47BE
        inc     $1800
        ldx     $1800
        lda     #'/'
        sta     $1800,x
L47D2:  ldx     $1800
        ldy     #$00
L47D7:  inx
        iny
        lda     L4817,y
        sta     $1800,x
        cpy     L4817
        bne     L47D7
        stx     $1800
        MLI_RELAY_CALL GET_FILE_INFO, get_file_info_params2
        bne     L47F3
        rts

L47F3:  ldx     L4816
L47F6:  lda     $1800,x
        cmp     #$2F
        beq     L4808
        dex
        bne     L47F6
L4800:  lda     #$FE
L4802:  jsr     DESKTOP_SHOW_ALERT0
        pla
        pla
        rts

L4808:  cpx     #$01
        beq     L4800
        stx     $1800
        dex
        stx     L4816
        jmp     L47D2

L4816:  .byte   $00
L4817:  PASCAL_STRING "Basic.system"
        .res    30, 0

L4842:  stax    $06
        ldy     #$00
        lda     ($06),y
        tay
L484B:  lda     ($06),y
        cmp     #$61
        bcc     L4859
        cmp     #$7B
        bcs     L4859
        and     #$DF
        sta     ($06),y
L4859:  dey
        bne     L484B
        rts

L485D:  .addr   $E000

L485F:  .byte   $00
L4860:  .byte   $D0
L4861:  .byte   $00
L4862:  .byte   $00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00

;;; ==================================================

set_watch_cursor:
        jsr     hide_cursor
        MGTK_RELAY_CALL MGTK::SetCursor, watch_cursor
        jsr     show_cursor
        rts

set_pointer_cursor:
        jsr     hide_cursor
        MGTK_RELAY_CALL MGTK::SetCursor, pointer_cursor
        jsr     show_cursor
        rts

hide_cursor:
        MGTK_RELAY_CALL MGTK::HideCursor
        rts

show_cursor:
        MGTK_RELAY_CALL MGTK::ShowCursor
        rts

;;; ==================================================

L48BE:  ldx     $E196
        inx
L48C2:  lda     $E196,x
        sta     DEVCNT,x
        dex
        bpl     L48C2
        rts

.proc show_warning_dialog_num
        sta     warning_dialog_num
        yax_call launch_dialog, index_warning_dialog, warning_dialog_num
        rts
.endproc

        lda     #$88
        sta     L48E4
        lda     #$40
        sta     L48E4+1

        L48E4 := *+1
        jmp     dummy1234           ; self-modified

get_event:
        MGTK_RELAY_CALL MGTK::GetEvent, event_params
        rts

peek_event:
        MGTK_RELAY_CALL MGTK::PeekEvent, event_params
        rts

set_penmode_xor:
        MGTK_RELAY_CALL MGTK::SetPenMode, penXOR
        rts

set_penmode_copy:
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        rts

;;; ==================================================

.proc cmd_noop
        rts
.endproc

;;; ==================================================

.proc cmd_selector_action
        jsr     set_watch_cursor
        lda     #dynamic_routine_selector1
        jsr     load_dynamic_routine
        bmi     done
        lda     $E25B
        cmp     #$03
        bcs     L492E
        lda     #dynamic_routine_selector2
        jsr     load_dynamic_routine
        bmi     done
        lda     #dynamic_routine_common
        jsr     load_dynamic_routine
        bmi     done

L492E:  jsr     set_pointer_cursor
        lda     $E25B
        jsr     dynamic_routine_9000
        sta     L498F
        jsr     set_watch_cursor
        lda     #dynamic_routine_restore9000
        jsr     restore_dynamic_routine
        lda     $E25B
        cmp     #$04
        bne     done
        lda     L498F
        bpl     done
        jsr     L4AAD
        jsr     L4A77
        jsr     L4AFD
        bpl     L497A
        jsr     L8F24
        bmi     done
        jsr     L4968
done:   jsr     set_pointer_cursor
        jsr     redraw_windows_and_desktop
        rts

L4968:  jsr     L4AAD
        ldx     $840
L496E:  lda     $840,x
        sta     LD355,x
        dex
        bpl     L496E
        jmp     L4A17

L497A:  jsr     L4AAD
        ldx     L0800
L4980:  lda     L0800,x
        sta     LD355,x
        dex
        bpl     L4980
        jsr     L4A17
        jmp     done

L498F:  .byte   $00
.endproc


;;; ==================================================

.proc get_file_info_params3
param_count:    .byte   $A
pathname:       .addr   $220
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

cmd_selector_item:
        jmp     L49A6

L49A5:  .byte   0

L49A6:  lda     $E25B
        sec
        sbc     #$06
        sta     L49A5
        jsr     a_times_4
        clc
        adc     #$1E
        sta     $06
        txa
        adc     #$DB
        sta     $06+1
        ldy     #$0F
        lda     ($06),y
        asl     a
        bmi     L49FA
        bcc     L49E0
        jsr     L4AFD
        beq     L49FA
        lda     L49A5
        jsr     L4AEA
        beq     L49ED
        lda     L49A5
        jsr     L4A47
        jsr     L8F24
        bpl     L49ED
        jmp     redraw_windows_and_desktop

L49E0:  jsr     L4AFD
        beq     L49FA
        lda     L49A5
        jsr     L4AEA
        bne     L49FA
L49ED:  lda     L49A5
        jsr     L4B5F
        stax    $06
        jmp     L4A0A

L49FA:  lda     L49A5
        jsr     a_times_6
        clc
        adc     #$9E
        sta     $06
        txa
        adc     #$DB
        sta     $06+1
L4A0A:  ldy     #$00
        lda     ($06),y
        tay
L4A0F:  lda     ($06),y
        sta     LD355,y
        dey
        bpl     L4A0F
L4A17:  ldy     LD355
L4A1A:  lda     LD355,y
        cmp     #$2F
        beq     L4A24
        dey
        bpl     L4A1A
L4A24:  dey
        sty     L4A46
        ldx     #$00
        iny
L4A2B:  iny
        inx
        lda     LD355,y
        sta     $D345,x
        cpy     LD355
        bne     L4A2B
        stx     $D345
        lda     L4A46
        sta     LD355
        lda     #$00
        jmp     launch_file

L4A46:  .byte   0
L4A47:  pha
        jsr     a_times_6
        clc
        adc     #$9E
        sta     $06
        txa
        adc     #$DB
        sta     $06+1
        ldy     #$00
        lda     ($06),y
        tay
L4A5A:  lda     ($06),y
        sta     L0800,y
        dey
        bpl     L4A5A
        pla
        jsr     L4B5F
        stax    $08
        ldy     #$00
        lda     ($08),y
        tay
L4A6F:  lda     ($08),y
        sta     $840,y
        dey
        bpl     L4A6F
L4A77:  ldy     L0800
L4A7A:  lda     L0800,y
        cmp     #$2F
        beq     L4A84
        dey
        bne     L4A7A
L4A84:  dey
        sty     L0800
        ldy     $840
L4A8B:  lda     $840,y
        cmp     #$2F
        beq     L4A95
        dey
        bne     L4A8B
L4A95:  dey
        sty     $840
        copy16  #$800, $06
        copy16  #$840, $08
        jsr     L4D19
        rts

L4AAD:  ldy     LD355
L4AB0:  lda     LD355,y
        sta     L0800,y
        dey
        bpl     L4AB0
        addr_call L4B15, $840
        ldy     L0800
L4AC3:  lda     L0800,y
        cmp     #$2F
        beq     L4ACD
        dey
        bne     L4AC3
L4ACD:  dey
L4ACE:  lda     L0800,y
        cmp     #$2F
        beq     L4AD8
        dey
        bne     L4ACE
L4AD8:  dey
        ldx     $840
L4ADC:  iny
        inx
        lda     L0800,y
        sta     $840,x
        cpy     L0800
        bne     L4ADC
        rts

L4AEA:  jsr     L4B5F
        stax    get_file_info_params3::pathname
        MLI_RELAY_CALL GET_FILE_INFO, get_file_info_params3
        rts

L4AFD:  sta     ALTZPOFF
        lda     LCBANK2
        lda     LCBANK2
        lda     $D3FF
        tax
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        txa
        rts

L4B15:  stax    L4B2B
        sta     ALTZPOFF
        lda     LCBANK2
        lda     LCBANK2
        ldx     $D3EE
L4B27:  lda     $D3EE,x

        L4B2B := *+1
        sta     dummy1234,x

        dex
        bpl     L4B27
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        rts

L4B3A:  stax    L4B50
        sta     ALTZPOFF
        lda     LCBANK2
        lda     LCBANK2
        ldx     $D3AD
L4B4C:  lda     $D3AD,x
        L4B50 := *+1
        sta     dummy1234,x
        dex
        bpl     L4B4C
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        rts

L4B5F:  sta     L4BB0
        addr_call L4B15, path_buffer
        lda     L4BB0
        jsr     a_times_6
        clc
        adc     #$9E
        sta     $06
        txa
        adc     #$DB
        sta     $06+1
        ldy     #$00
        lda     ($06),y
        sta     L4BB1
        tay
L4B81:  lda     ($06),y
        and     #$7F
        cmp     #$2F
        beq     L4B8C
        dey
        bne     L4B81
L4B8C:  dey
L4B8D:  lda     ($06),y
        and     #$7F
        cmp     #$2F
        beq     L4B98
        dey
        bne     L4B8D
L4B98:  dey
        ldx     path_buffer
L4B9C:  inx
        iny
        lda     ($06),y
        sta     path_buffer,x
        cpy     L4BB1
        bne     L4B9C
        stx     path_buffer
        ldax    #$4F76
        rts

L4BB0:  .byte   0
L4BB1:  .byte   0

;;; ==================================================

.proc cmd_about
        yax_call launch_dialog, index_about_dialog, $0000
        jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

.proc cmd_deskacc_impl
        ptr := $6

zp_use_flag1:
        .byte   $80

start:  jsr     reset_grafport3
        jsr     set_watch_cursor

        ;; Find DA name
        lda     $E25B           ; menu item index (1-based)
        sec
        sbc     #3              ; About and separator before first item
        jsr     a_times_4
        clc
        adc     #<buf
        sta     ptr
        txa
        adc     #>buf
        sta     ptr+1

        ;; Compute total length
        ldy     #0
        lda     (ptr),y
        tay
        clc
        adc     prefix_length
        pha
        tax

        ;; Append name to path
:       lda     ($06),y
        sta     str_desk_acc,x
        dex
        dey
        bne     :-
        pla
        sta     str_desk_acc    ; update length

        ;; Convert spaces to periods
        ldx     str_desk_acc
:       lda     str_desk_acc,x
        cmp     #' '
        bne     nope
        lda     #'.'
        sta     str_desk_acc,x
nope:   dex
        bne     :-

        ;; Load the DA
        jsr     open
        bmi     done
        lda     open_params_ref_num
        sta     read_params_ref_num
        sta     close_params_ref_num
        jsr     read
        jsr     close
        lda     #$80
        sta     running_da_flag

        ;; Invoke it
        jsr     set_pointer_cursor
        jsr     reset_grafport3
        MGTK_RELAY_CALL MGTK::SetZP1, zp_use_flag0
        MGTK_RELAY_CALL MGTK::SetZP1, zp_use_flag1
        jsr     DA_LOAD_ADDRESS
        MGTK_RELAY_CALL MGTK::SetZP1, zp_use_flag0
        lda     #0
        sta     running_da_flag

        ;; Restore state
        jsr     reset_grafport3
        jsr     redraw_windows_and_desktop
done:   jsr     set_pointer_cursor
        rts

open:   yxa_call MLI_RELAY, OPEN, open_params
        bne     :+
        rts
:       lda     #warning_msg_insert_system_disk
        jsr     show_warning_dialog_num
        beq     open            ; ok, so try again
        lda     #$FF            ; cancel, so fail
        rts

read:   yxa_jump MLI_RELAY, READ, read_params

close:  yxa_jump MLI_RELAY, CLOSE, close_params

unused: .byte   0               ; ???

.proc open_params
param_count:    .byte   3
pathname:       .addr   str_desk_acc
io_buffer:      .addr   $1C00
ref_num:        .byte   0
.endproc
        open_params_ref_num := open_params::ref_num

.proc read_params
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   DA_LOAD_ADDRESS
request_count:  .word   DA_MAX_SIZE
trans_count:    .word   0
.endproc
        read_params_ref_num := read_params::ref_num

.proc close_params
param_count:    .byte   1
ref_num:        .byte   0
.endproc
        close_params_ref_num := close_params::ref_num

        .define prefix "Desk.acc/"

prefix_length:
        .byte   .strlen(prefix)

str_desk_acc:
        PASCAL_STRING prefix, .strlen(prefix) + 15

.endproc
        cmd_deskacc := cmd_deskacc_impl::start

;;; ==================================================

        ;; high bit set while a DA is running
running_da_flag:
        .byte   0

;;; ==================================================

.proc cmd_copy_file
        jsr     set_watch_cursor
        lda     #dynamic_routine_common
        jsr     load_dynamic_routine
        bmi     L4CD6
        lda     #dynamic_routine_file_copy
        jsr     load_dynamic_routine
        bmi     L4CD6
        jsr     set_pointer_cursor
        lda     #$00
        jsr     dynamic_routine_5000
        pha
        jsr     set_watch_cursor
        lda     #dynamic_routine_restore5000
        jsr     restore_dynamic_routine
        jsr     set_pointer_cursor
        pla
        bpl     L4CCD
        jmp     L4CD6

L4CCD:  jsr     L4D19
        jsr     redraw_windows_and_desktop
        jsr     L8F18
L4CD6:  pha
        jsr     set_pointer_cursor
        pla
        bpl     :+
        jmp     redraw_windows_and_desktop

:       addr_call L6FAF, LDFC9
        beq     :+
        pha
        jsr     L6F0D
        pla
        jmp     L5E78

:       ldy     #1
L4CF3:  iny
        lda     LDFC9,y
        cmp     #'/'
        beq     :+
        cpy     LDFC9
        bne     L4CF3
        iny
:       dey
        sty     LDFC9
        addr_call L6FB7, LDFC9
        ldax    #LDFC9
        ldy     LDFC9
        jsr     L6F4B
        jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

L4D19:  ldy     #$00
        lda     ($06),y
        tay
L4D1E:  lda     ($06),y
        sta     $E00A,y
        dey
        bpl     L4D1E
        ldy     #$00
        lda     ($08),y
        tay
L4D2B:  lda     ($08),y
        sta     LDFC9,y
        dey
        bpl     L4D2B
        addr_call L6F90, LDFC9
        ldx     #$01
        iny
        iny
L4D3E:  lda     LDFC9,y
        sta     $E04B,x
        cpy     LDFC9
        beq     L4D4E
        iny
        inx
        jmp     L4D3E

L4D4E:  stx     $E04B
        lda     LDFC9
        sec
        sbc     $E04B
        sta     LDFC9
        dec     LDFC9
        rts

;;; ==================================================

.proc cmd_delete_file
        jsr     set_watch_cursor
        lda     #dynamic_routine_common
        jsr     load_dynamic_routine
        bmi     L4D9D

        lda     #dynamic_routine_file_delete
        jsr     load_dynamic_routine
        bmi     L4D9D

        jsr     set_pointer_cursor
        lda     #$01
        jsr     dynamic_routine_5000
        pha
        jsr     set_watch_cursor
        lda     #dynamic_routine_restore5000
        jsr     restore_dynamic_routine
        jsr     set_pointer_cursor
        pla
        bpl     L4D8A
        jmp     L4D9D

L4D8A:  ldy     #$00
        lda     ($06),y
        tay
L4D8F:  lda     ($06),y
        sta     $E00A,y
        dey
        bpl     L4D8F
        jsr     redraw_windows_and_desktop
        jsr     L8F1B
L4D9D:  pha
        jsr     set_pointer_cursor
        pla
        bpl     L4DA7
        jmp     redraw_windows_and_desktop

L4DA7:  addr_call L6F90, $E00A
        sty     $E00A
        addr_call L6FAF, $E00A
        beq     L4DC2
        pha
        jsr     L6F0D
        pla
        jmp     L5E78

L4DC2:  ldy     #$01
L4DC4:  iny
        lda     $E00A,y
        cmp     #$2F
        beq     L4DD2
        cpy     $E00A
        bne     L4DC4
        iny
L4DD2:  dey
        sty     $E00A
        addr_call L6FB7, $E00A
        ldax    #$E00A
        ldy     $E00A
        jsr     L6F4B
        jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

.proc cmd_open
        ldx     #$00
L4DEC:  cpx     is_file_selected
        bne     L4DF2
        rts

L4DF2:  txa
        pha
        lda     selected_file_index,x
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$70
        bne     L4E10
        ldy     #$00
        lda     ($06),y
        jsr     L6A8A
        jmp     L4E14

L4E10:  cmp     #$40
        bcc     L4E1A
L4E14:  pla
        tax
        inx
        jmp     L4DEC

L4E1A:  sta     L4E71
        lda     is_file_selected
        cmp     #$02
        bcs     L4E14
        pla
        lda     active_window_id
        jsr     window_address_lookup
        stax    $06
        ldy     #$00
        lda     ($06),y
        tay
L4E34:  lda     ($06),y
        sta     LD355,y
        dey
        bpl     L4E34
        lda     selected_file_index
        jsr     file_address_lookup
        stax    $06
        ldy     #$09
        lda     ($06),y
        tax
        clc
        adc     #$09
        tay
        dex
        dey
L4E51:  lda     ($06),y
        sta     LD343+1,x
        dey
        dex
        bne     L4E51
        ldy     #$09
        lda     ($06),y
        tax
        dex
        dex
        stx     $D345
        lda     L4E71
        cmp     #$20
        bcc     L4E6E
        lda     L4E71
L4E6E:  jmp     launch_file

L4E71:  .byte   0
.endproc

;;; ==================================================

.proc cmd_close
        lda     active_window_id
        bne     L4E78
        rts

L4E78:  jsr     clear_selection
        dec     $EC2E
        lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        ldx     active_window_id
        dex
        lda     win_buf_table,x
        bmi     L4EB4
        DESKTOP_RELAY_CALL DT_CLOSE_WINDOW, active_window_id
        lda     LDD9E
        sec
        sbc     buf3len
        sta     LDD9E
        ldx     #$00
L4EA5:  cpx     buf3len
        beq     L4EB4
        lda     buf3,x
        jsr     DESKTOP_FREE_SPACE
        inx
        jmp     L4EA5

L4EB4:  ldx     #$00
        txa
L4EB7:  sta     buf3,x
        cpx     buf3len
        beq     L4EC3
        inx
        jmp     L4EB7

L4EC3:  sta     buf3len
        jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        MGTK_RELAY_CALL MGTK::CloseWindow, active_window_id
        ldx     active_window_id
        dex
        lda     LEC26,x
        sta     LE22F
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$7F
        sta     ($06),y
        and     #$0F
        sta     selected_window_index
        jsr     L8997
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        jsr     reset_grafport3
        lda     #$01
        sta     is_file_selected
        lda     LE22F
        sta     selected_file_index
        ldx     active_window_id
        dex
        lda     LEC26,x
        jsr     L7345
        ldx     active_window_id
        dex
        lda     #$00
        sta     LEC26,x
        MGTK_RELAY_CALL MGTK::FrontWindow, active_window_id
        lda     active_window_id
        bne     L4F3C
        DESKTOP_RELAY_CALL DT_REDRAW_ICONS
L4F3C:  lda     #$00
        sta     checkitem_params::check
        MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params
        jsr     L66A2
        jmp     reset_grafport3
.endproc

;;; ==================================================

.proc cmd_close_all
        lda     active_window_id   ; current window
        beq     done            ; nope, done!
        jsr     cmd_close       ; close it...
        jmp     cmd_close_all   ; and try again
done:   rts
.endproc

;;; ==================================================

.proc cmd_disk_copy
        lda     #dynamic_routine_disk_copy
        jsr     load_dynamic_routine
        bmi     fail
        jmp     dynamic_routine_800

fail:   rts
.endproc

;;; ==================================================

.proc cmd_new_folder_impl

L4F67:  .byte   $00
L4F68:  .byte   $00
L4F69:  .byte   $00

.proc create_params
param_count:    .byte   7
pathname:       .addr   path_buffer
access: .byte   %11000011       ; destroy/rename/write/read
file_type:      .byte   FT_DIRECTORY
aux_type:       .word   0
storage_type:   .byte   ST_LINKED_DIRECTORY
create_date:    .word   0
create_time:    .word   0
.endproc

path_buffer:
        .res    65, 0              ; buffer is used elsewhere too

start:  lda     active_window_id
        sta     L4F67
        yax_call launch_dialog, index_new_folder_dialog, L4F67
L4FC6:  lda     active_window_id
        beq     L4FD4
        jsr     window_address_lookup
        stax    L4F68
L4FD4:  lda     #$80
        sta     L4F67
        yax_call launch_dialog, index_new_folder_dialog, L4F67
        beq     L4FE7
        jmp     L504B

L4FE7:  stx     $06+1
        stx     L504F
        sty     $06
        sty     L504E
        ldy     #$00
        lda     ($06),y
        tay
L4FF6:  lda     ($06),y
        sta     path_buffer,y
        dey
        bpl     L4FF6
        ldx     #$03
:       lda     DATELO,x
        sta     create_params::create_date,x
        dex
        bpl     :-
        MLI_RELAY_CALL CREATE, create_params
        beq     L5027
        jsr     DESKTOP_SHOW_ALERT0
        lda     L504E
        sta     L4F68
        lda     L504F
        sta     L4F69
        jmp     L4FC6

        rts

L5027:  lda     #$40
        sta     L4F67
        yax_call launch_dialog, index_new_folder_dialog, L4F67
        addr_call L6F90, path_buffer
        sty     path_buffer
        addr_call L6FAF, path_buffer
        beq     L504B
        jsr     L5E78
L504B:  jmp     redraw_windows_and_desktop

L504E:  .byte   0
L504F:  .byte   0
.endproc
        cmd_new_folder := cmd_new_folder_impl::start
        path_buffer := cmd_new_folder_impl::path_buffer ; ???

;;; ==================================================

.proc cmd_eject
        lda     selected_window_index
        beq     L5056
L5055:  rts

L5056:  lda     is_file_selected
        beq     L5055
        cmp     #$01
        bne     L5067
        lda     selected_file_index
        cmp     $EBFB
        beq     L5055
L5067:  lda     #$00
        tax
        tay
L506B:  lda     selected_file_index,y
        cmp     $EBFB
        beq     L5077
        sta     $1800,x
        inx
L5077:  iny
        cpy     is_file_selected
        bne     L506B
        dex
        stx     L5098
        jsr     L8F15
L5084:  ldx     L5098
        lda     $1800,x
        sta     L533F
        jsr     L59A8
        dec     L5098
        bpl     L5084
        jmp     redraw_windows_and_desktop
L5098:  .byte   $00

.endproc

;;; ==================================================

.proc cmd_quit_impl

stack_data:
        .addr   $DEAF,$DEAD     ; ???

quit_code:
        .byte   $18,$FB,$5C,$04,$D0,$E0
        ;; 65816 code:
        ;; 18           clc             ; clear carry
        ;; FB           xce             ; exchange carry/emulation (i.e. turn on 16 bit)
        ;; 5C 04 D0 E0  jmp $E0D004     ; long jump

.proc quit_params
param_count: .byte   4
        .byte   0
        .word   0
        .byte   0
        .word   0
.endproc

start:
        ldx     #3
:       lda     stack_data,x
        sta     $0102,x         ; Populate stack ???
        dex
        bpl     :-

        ;; Install new quit routine
        sta     ALTZPOFF
        lda     LCBANK2
        lda     LCBANK2
        ldx     #5
:       lda     quit_code,x
        sta     SELECTOR,x
        dex
        bpl     :-

        ;; Restore machine to text state
        sta     ALTZPOFF
        lda     ROMIN2
        jsr     SETVID
        jsr     SETKBD
        jsr     INIT
        jsr     HOME
        sta     TXTSET
        sta     LOWSCR
        sta     LORES
        sta     MIXCLR
        sta     DHIRESOFF
        sta     CLRALTCHAR
        sta     CLR80VID
        sta     CLR80COL

        MLI_CALL QUIT, quit_params
.endproc
        cmd_quit := cmd_quit_impl::start

;;; ==================================================

.proc cmd_view_by_icon
        ldx     active_window_id
        bne     L50FF
        rts

L50FF:  dex
        lda     win_buf_table,x
        bne     L5106
        rts

L5106:  lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        ldx     #$00
        txa
L5112:  cpx     buf3len
        beq     L511E
        sta     buf3,x
        inx
        jmp     L5112

L511E:  sta     buf3len
        lda     #$00
        ldx     active_window_id
        dex
        sta     win_buf_table,x
        jsr     update_view_menu_check
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L4505
        jsr     L6E8E
        jsr     set_penmode_copy
        MGTK_RELAY_CALL MGTK::PaintRect, grafport2::cliprect::x1
        lda     active_window_id
        jsr     L7D5D
        stax    L51EB
        sty     L51ED
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$1F
        lda     #$00
L5162:  sta     ($06),y
        dey
        cpy     #$1B
        bne     L5162
        ldy     #$23
        ldx     #$03
L516D:  lda     L51EB,x
        sta     ($06),y
        dey
        dex
        bpl     L516D
        lda     active_window_id
        jsr     L763A
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L6E52
        lda     #$00
        sta     L51EF
L518D:  lda     L51EF
        cmp     buf3len
        beq     L51A7
        tax
        lda     buf3,x
        jsr     file_address_lookup
        ldy     #$01
        jsr     DESKTOP_RELAY
        inc     L51EF
        jmp     L518D

L51A7:  jsr     reset_grafport3
        jsr     L6E6E
        jsr     DESKTOP_COPY_FROM_BUF
        jsr     L6DB1
        lda     selected_window_index
        beq     L51E3
        lda     is_file_selected
        beq     L51E3
        sta     L51EF
L51C0:  ldx     L51EF
        lda     is_file_selected,x
        sta     LE22F
        jsr     L8915
        jsr     L6E8E
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        lda     LE22F
        jsr     L8893
        dec     L51EF
        bne     L51C0
L51E3:  lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF

L51EB:  .word   0
L51ED:  .byte   0
        .byte   0
L51EF:  .byte   0
.endproc

;;; ==================================================

L51F0:  ldx     active_window_id
        dex
        sta     win_buf_table,x
        lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jsr     L7D9C
        jsr     DESKTOP_COPY_FROM_BUF
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L4505
        jsr     L6E8E
        jsr     set_penmode_copy
        MGTK_RELAY_CALL MGTK::PaintRect, grafport2::cliprect::x1
        lda     active_window_id
        jsr     L7D5D
        stax    L5263
        sty     L5265
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$1F
        lda     #$00
L523B:  sta     ($06),y
        dey
        cpy     #$1B
        bne     L523B
        ldy     #$23
        ldx     #$03
L5246:  lda     L5263,x
        sta     ($06),y
        dey
        dex
        bpl     L5246
        lda     #$80
        sta     L4152
        jsr     reset_grafport3
        jsr     L6C19
        jsr     L6DB1
        lda     #$00
        sta     L4152
        rts

L5263:  .word   0

L5265:  .byte   0
        .byte   0

;;; ==================================================

.proc cmd_view_by_name
        ldx     active_window_id
        bne     L526D
        rts

L526D:  dex
        lda     win_buf_table,x
        cmp     #$81
        bne     L5276
        rts

L5276:  cmp     #$00
        bne     L527D
        jsr     L5302
L527D:  jsr     update_view_menu_check
        lda     #$81
        jmp     L51F0
.endproc

;;; ==================================================

.proc cmd_view_by_date
        ldx     active_window_id
        bne     L528B
        rts

L528B:  dex
        lda     win_buf_table,x
        cmp     #$82
        bne     L5294
        rts

L5294:  cmp     #$00
        bne     L529B
        jsr     L5302
L529B:  jsr     update_view_menu_check
        lda     #$82
        jmp     L51F0
.endproc

;;; ==================================================

.proc cmd_view_by_size
        ldx     active_window_id
        bne     L52A9
        rts

L52A9:  dex
        lda     win_buf_table,x
        cmp     #$83
        bne     L52B2
        rts

L52B2:  cmp     #$00
        bne     L52B9
        jsr     L5302
L52B9:  jsr     update_view_menu_check
        lda     #$83
        jmp     L51F0
.endproc

;;; ==================================================

.proc cmd_view_by_type
        ldx     active_window_id
        bne     L52C7
        rts

L52C7:  dex
        lda     win_buf_table,x
        cmp     #$84
        bne     L52D0
        rts

L52D0:  cmp     #$00
        bne     L52D7
        jsr     L5302
L52D7:  jsr     update_view_menu_check
        lda     #$84
        jmp     L51F0
.endproc

;;; ==================================================

.proc update_view_menu_check
        ;; Uncheck last checked
        lda     #0
        sta     checkitem_params::check
        MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params

        ;; Check the new one
        lda     $E25B           ; index of View menu item to check
        sta     checkitem_params::menu_item
        lda     #1
        sta     checkitem_params::check
        MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params
        rts
.endproc

;;; ==================================================

L5302:  DESKTOP_RELAY_CALL DT_CLOSE_WINDOW, active_window_id
        lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     LDD9E
        sec
        sbc     buf3len
        sta     LDD9E
        ldx     #$00
L5320:  cpx     buf3len
        beq     L5334
        lda     buf3,x
        jsr     DESKTOP_FREE_SPACE
        lda     #$00
        sta     buf3,x
        inx
        jmp     L5320

L5334:  jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF

;;; ==================================================

L533F:  .byte   0

;;; ==================================================

.proc cmd_format_disk
        lda     #dynamic_routine_format_erase
        jsr     load_dynamic_routine
        bmi     fail

        lda     #$04
        jsr     dynamic_routine_800
        bne     :+
        stx     L533F
        jsr     redraw_windows_and_desktop
        jsr     L59A4
:       jmp     redraw_windows_and_desktop

fail:   rts
.endproc

;;; ==================================================

.proc cmd_erase_disk
        lda     #dynamic_routine_format_erase
        jsr     load_dynamic_routine
        bmi     done

        lda     #$05
        jsr     dynamic_routine_800
        bne     done

        stx     L533F
        jsr     redraw_windows_and_desktop
        jsr     L59A4
done:   jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

.proc cmd_get_info
        jsr     L8F09
        jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

.proc cmd_get_size
        jsr     L8F27
        jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

.proc cmd_unlock
        jsr     L8F0F
        jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

.proc cmd_lock
        jsr     L8F0C
        jmp     redraw_windows_and_desktop
.endproc

;;; ==================================================

.proc cmd_rename_icon
        jsr     L8F12
        pha
        jsr     redraw_windows_and_desktop
        pla
        beq     L5398
        rts

L5398:  lda     selected_window_index
        bne     L53B5
        ldx     #$00
        ldy     #$00
L53A1:  lda     selected_file_index,x
        cmp     #$01
        beq     L53AC
        sta     L5428,y
        iny
L53AC:  inx
        cpx     selected_file_index
        bne     L53A1
        sty     L5427
L53B5:  lda     #$FF
        sta     L5426
L53BA:  inc     L5426
        lda     L5426
        cmp     is_file_selected
        bne     L53D0
        lda     selected_window_index
        bne     L53CD
        jmp     L540E
L53CD:  jmp     L5E78

L53D0:  tax
        lda     selected_file_index,x
        jsr     L5431
        bmi     L53BA
        jsr     window_address_lookup
        stax    $06
        ldy     #$00
        lda     ($06),y
        tay
        lda     $06
        jsr     L6FB7
        lda     L704B
        beq     L53BA
L53EF:  dec     L704B
        ldx     L704B
        lda     L704C,x
        cmp     active_window_id
        beq     L5403
        sta     findwindow_params_window_id
        jsr     handle_inactive_window_click
L5403:  jsr     L61DC
        lda     L704B
        bne     L53EF
        jmp     L53BA

L540E:  ldx     L5427
L5411:  lda     L5428,x
        sta     L533F
        jsr     L59A8
        ldx     L5427
        dec     L5427
        dex
        bpl     L5411
        jmp     redraw_windows_and_desktop

L5426:  .byte   0
L5427:  .byte   0
L5428:  .res    9, 0

L5431:  ldx     #7
L5433:  cmp     LEC26,x
        beq     L543E
        dex
        bpl     L5433
        lda     #$FF
        rts

L543E:  inx
        txa
        rts
.endproc

;;; ==================================================
;;; Handle keyboard-based icon selection ("highlighting")

.proc cmd_higlight
        jmp     L544D

L5444:  .byte   0
L5445:  .byte   0
L5446:  .byte   0
L5447:  .byte   0
L5448:  .byte   0
L5449:  .byte   0
L544A:  .byte   0
        .byte   0
        .byte   0

L544D:
        lda     #$00
        sta     $1800
        lda     $EC25
        bne     L545A
        jmp     L54C5

L545A:  tax
        dex
        lda     win_buf_table,x
        bpl     L5464
        jmp     L54C5

L5464:  lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$1C
L5479:  lda     ($06),y
        sta     $E214,y
        iny
        cpy     #$24
        bne     L5479
        ldx     #$00
L5485:  cpx     buf3len
        beq     L54BD
        txa
        pha
        lda     buf3,x
        sta     LE22F
        jsr     L8915
        DESKTOP_RELAY_CALL DT_ICON_IN_RECT, LE22F
        pha
        lda     LE22F
        jsr     L8893
        pla
        beq     L54B7
        pla
        pha
        tax
        lda     buf3,x
        ldx     $1800
        sta     $1801,x
        inc     $1800
L54B7:  pla
        tax
        inx
        jmp     L5485

L54BD:  lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
L54C5:  ldx     $1800
        ldy     #$00
L54CA:  lda     buf3,y
        sta     $1801,x
        iny
        inx
        cpy     buf3len
        bne     L54CA
        lda     $1800
        clc
        adc     buf3len
        sta     $1800
        lda     #$00
        sta     L544A
        lda     #$FF
        ldx     #$03
L54EA:  sta     L5444,x
        dex
        bpl     L54EA
L54F0:  ldx     L544A
L54F3:  lda     $1801,x
        asl     a
        tay
        copy16  file_address_table,y, $06
        ldy     #$06
        lda     ($06),y
        cmp     L5447
        beq     L5510
        bcc     L5532
        jmp     L5547

L5510:  dey
        lda     ($06),y
        cmp     L5446
        beq     L551D
        bcc     L5532
        jmp     L5547

L551D:  dey
        lda     ($06),y
        cmp     L5445
        beq     L552A
        bcc     L5532
        jmp     L5547

L552A:  dey
        lda     ($06),y
        cmp     L5444
        bcs     L5547
L5532:  lda     $1801,x
        stx     L5449
        sta     L5448
        ldy     #$03
L553D:  lda     ($06),y
        sta     L5444-3,y
        iny
        cpy     #$07
        bne     L553D
L5547:  inx
        cpx     $1800
        bne     L54F3
        ldx     L544A
        lda     $1801,x
        tay
        lda     L5448
        sta     $1801,x
        ldx     L5449
        tya
        sta     $1801,x
        lda     #$FF
        ldx     #$03
L5565:  sta     L5444,x
        dex
        bpl     L5565
        inc     L544A
        ldx     L544A
        cpx     $1800
        beq     L5579
        jmp     L54F0

L5579:  lda     #$00
        sta     L544A
        jsr     clear_selection
L5581:  jsr     L55F0
L5584:  jsr     get_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_key_down
        beq     L5595
        cmp     #MGTK::event_kind_button_down
        bne     L5584
        jmp     L55D1

L5595:  lda     event_params+1
        and     #$7F
        cmp     #KEY_RETURN
        beq     L55D1
        cmp     #KEY_ESCAPE
        beq     L55D1
        cmp     #KEY_LEFT
        beq     L55BE
        cmp     #KEY_RIGHT
        bne     L5584
        ldx     L544A
        inx
        cpx     $1800
        bne     L55B5
        ldx     #$00
L55B5:  stx     L544A
        jsr     L562C
        jmp     L5581

L55BE:  ldx     L544A
        dex
        bpl     L55C8
        ldx     $1800
        dex
L55C8:  stx     L544A
        jsr     L562C
        jmp     L5581

L55D1:  ldx     L544A
        lda     $1801,x
        sta     selected_file_index
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        sta     selected_window_index
        lda     #$01
        sta     is_file_selected
        rts

L55F0:  ldx     L544A
        lda     $1801,x
        sta     LE22F
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        sta     getwinport_params2::window_id
        beq     L5614
        jsr     L56F9
        lda     LE22F
        jsr     L8915
L5614:  DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        lda     getwinport_params2::window_id
        beq     L562B
        lda     LE22F
        jsr     L8893
        jsr     reset_grafport3
L562B:  rts

L562C:  lda     LE22F
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        sta     getwinport_params2::window_id
        beq     L564A
        jsr     L56F9
        lda     LE22F
        jsr     L8915
L564A:  DESKTOP_RELAY_CALL $0B, LE22F
        lda     getwinport_params2::window_id
        beq     L5661
        lda     LE22F
        jsr     L8893
        jsr     reset_grafport3
L5661:  rts
.endproc

;;; ==================================================

.proc cmd_select_all
        lda     is_file_selected
        beq     L566A
        jsr     clear_selection
L566A:  ldx     active_window_id
        beq     L5676
        dex
        lda     win_buf_table,x
        bpl     L5676
        rts

L5676:  lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     buf3len
        bne     L5687
        jmp     L56F0

L5687:  ldx     buf3len
        dex
L568B:  lda     buf3,x
        sta     selected_file_index,x
        dex
        bpl     L568B
        lda     buf3len
        sta     is_file_selected
        lda     active_window_id
        sta     selected_window_index
        lda     selected_window_index
        sta     $E22C
        beq     L56AB
        jsr     L56F9
L56AB:  lda     is_file_selected
        sta     L56F8
        dec     L56F8
L56B4:  ldx     L56F8
        lda     selected_file_index,x
        sta     LE22B
        jsr     file_address_lookup
        stax    $06
        lda     $E22C
        beq     L56CF
        lda     LE22B
        jsr     L8915
L56CF:  DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22B
        lda     $E22C
        beq     L56E3
        lda     LE22B
        jsr     L8893
L56E3:  dec     L56F8
        bpl     L56B4
        lda     selected_window_index
        beq     L56F0
        jsr     reset_grafport3
L56F0:  lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF

L56F8:  .byte   0
.endproc

;;; ==================================================

L56F9:  sta     getwinport_params2::window_id
        jsr     L4505
        jmp     L6E8E

;;; ==================================================
;;; Handle keyboard-based window activation

.proc cmd_activate
        lda     active_window_id
        bne     L5708
        rts

L5708:  sta     L0800
        ldy     #$01
        ldx     #$00
L570F:  lda     LEC26,x
        beq     L5720
        inx
        cpx     active_window_id
        beq     L5721
        txa
        dex
        sta     L0800,y
        iny
L5720:  inx
L5721:  cpx     #$08
        bne     L570F
        sty     L578D
        cpy     #$01
        bne     L572D
        rts

L572D:  lda     #$00
        sta     L578C
L5732:  jsr     get_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_key_down
        beq     L5743
        cmp     #MGTK::event_kind_button_down
        bne     L5732
        jmp     L578B

L5743:  lda     event_params_key
        and     #$7F
        cmp     #KEY_RETURN
        beq     L578B
        cmp     #KEY_ESCAPE
        beq     L578B
        cmp     #KEY_LEFT
        beq     L5772
        cmp     #KEY_RIGHT
        bne     L5732
        ldx     L578C
        inx
        cpx     L578D
        bne     L5763
        ldx     #$00
L5763:  stx     L578C
        lda     L0800,x
        sta     findwindow_params_window_id
        jsr     handle_inactive_window_click
        jmp     L5732

L5772:  ldx     L578C
        dex
        bpl     L577C
        ldx     L578D
        dex
L577C:  stx     L578C
        lda     L0800,x
        sta     findwindow_params_window_id
        jsr     handle_inactive_window_click
        jmp     L5732

L578B:  rts

L578C:  .byte   0
L578D:  .byte   0

.endproc

;;; ==================================================
;;; Initiate keyboard-based resizing

.proc cmd_resize
        MGTK_RELAY_CALL MGTK::KeyboardMouse
        jmp     handle_resize_click
.endproc

;;; ==================================================
;;; Initiate keyboard-based window moving

.proc cmd_move
        MGTK_RELAY_CALL MGTK::KeyboardMouse
        jmp     handle_title_click
.endproc

;;; ==================================================
;;; Keyboard-based scrolling of window contents

.proc cmd_scroll
        jsr     L5803
loop:   jsr     get_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_down
        beq     done
        cmp     #MGTK::event_kind_key_down
        bne     loop
        lda     event_params_key
        cmp     #KEY_RETURN
        beq     done
        cmp     #KEY_ESCAPE
        bne     :+

done:   lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        rts

        ;; Horizontal ok?
:       bit     L585D
        bmi     :+
        jmp     vertical

:       cmp     #KEY_RIGHT
        bne     :+
        jsr     scroll_right
        jmp     loop

:       cmp     #KEY_LEFT
        bne     vertical
        jsr     scroll_left
        jmp     loop

        ;; Vertical ok?
vertical:
        bit     L585E
        bmi     :+
        jmp     loop

:       cmp     #KEY_DOWN
        bne     :+
        jsr     scroll_down
        jmp     loop

:       cmp     #KEY_UP
        bne     loop
        jsr     scroll_up
        jmp     loop
.endproc

;;; ==================================================

L5803:  lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        ldx     active_window_id
        dex
        lda     win_buf_table,x
        sta     L5B1B
        jsr     L58C3
        stax    L585F
        sty     L585D
        jsr     L58E2
        stax    L5861
        sty     L585E
        rts

scroll_right:                   ; elevator right / contents left
        ldax    L585F
        jsr     L5863
        sta     L585F
        rts

scroll_left:                    ; elevator left / contents right
        lda     L585F
        jsr     L587E
        sta     L585F
        rts

scroll_down:                    ; elevator down / contents up
        ldax    L5861
        jsr     L5893
        sta     L5861
        rts

scroll_up:                      ; elevator up / contents down
        lda     L5861
        jsr     L58AE
        sta     L5861
        rts

L585D:  .byte   0               ; can scroll horiz?
L585E:  .byte   0               ; can scroll vert?
L585F:  .byte   0
L5860:  .byte   0
L5861:  .word   0

L5863:  stx     L587D
        cmp     L587D
        beq     L587C
        sta     $D20D
        inc     $D20D
        lda     #$02
        sta     event_params
        jsr     L5C54
        lda     $D20D
L587C:  rts

L587D:  .byte   0
L587E:  beq     L5891
        sta     $D20D
        dec     $D20D
        lda     #$02
        sta     event_params
        jsr     L5C54
        lda     $D20D
L5891:  rts

        .byte   0
L5893:  stx     L58AD
        cmp     L58AD
        beq     L58AC
        sta     $D20D
        inc     $D20D
        lda     #$01
        sta     event_params
        jsr     L5C54
        lda     $D20D
L58AC:  rts

L58AD:  .byte   0
L58AE:  beq     L58C1
        sta     $D20D
        dec     $D20D
        lda     #$01
        sta     event_params
        jsr     L5C54
        lda     $D20D
L58C1:  rts

        .byte   0
L58C3:  lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$06
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        pha
        ldy     #$04
        lda     ($06),y
        and     #$01
        clc
        ror     a
        ror     a
        tay
        pla
        rts

L58E2:  lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$08
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        pha
        ldy     #$05
        lda     ($06),y
        and     #$01
        clc
        ror     a
        ror     a
        tay
        pla
        rts

;;; ==================================================

.proc cmd_check_drives
        lda     #$00
        sta     L599F
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jsr     cmd_close_all
        jsr     clear_selection
        ldx     buf3len
        dex
L5916:  lda     buf3,x
        cmp     $EBFB
        beq     L5942
        txa
        pha
        lda     buf3,x
        sta     LE22F
        lda     #$00
        sta     buf3,x
        DESKTOP_RELAY_CALL $04, LE22F
        lda     LE22F
        jsr     DESKTOP_FREE_SPACE
        dec     buf3len
        dec     LDD9E
        pla
        tax
L5942:  dex
        bpl     L5916
        ldy     #$00
        sty     L599E
L594A:  ldy     L599E
        inc     buf3len
        inc     LDD9E
        lda     #$00
        sta     $E1A0,y
        lda     DEVLST,y
        jsr     get_device_info
        cmp     #$57
        bne     L5967
        lda     #$F9
        sta     L599F
L5967:  inc     L599E
        lda     L599E
        cmp     DEVCNT
        beq     L594A
        bcc     L594A
        ldx     #$00
L5976:  cpx     buf3len
        bne     L5986
        lda     L599F
        beq     L5983
        jsr     DESKTOP_SHOW_ALERT0
L5983:  jmp     DESKTOP_COPY_FROM_BUF

L5986:  txa
        pha
        lda     buf3,x
        cmp     $EBFB
        beq     L5998
        jsr     file_address_lookup
        ldy     #$01
        jsr     DESKTOP_RELAY
L5998:  pla
        tax
        inx
        jmp     L5976
.endproc

;;; ==================================================

L599E:  .byte   0
L599F:  .byte   0
L59A0:  lda     #$00
        beq     L59AA
L59A4:  lda     #$80
        bne     L59AA
L59A8:  lda     #$C0
L59AA:  sta     L5AD0
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        bit     L5AD0
        bpl     L59EA
        bvc     L59D2
        lda     L533F
        ldy     #$0F
L59C1:  cmp     $E1A0,y
        beq     L59C9
        dey
        bpl     L59C1
L59C9:  sty     L5AC6
        sty     $E25B
        jmp     L59F3

L59D2:  ldy     DEVCNT
        lda     L533F
L59D8:  cmp     DEVLST,y
        beq     L59E1
        dey
        bpl     L59D8
        iny
L59E1:  sty     L5AC6
        sty     $E25B
        jmp     L59F3

L59EA:  lda     $E25B
        sec
        sbc     #$03
        sta     $E25B
L59F3:  ldy     $E25B
        lda     $E1A0,y
        bne     L59FE
        jmp     L5A4C

L59FE:  jsr     file_address_lookup
        clc
        adc     #$09
        sta     $06
        txa
        adc     #$00
        sta     $06+1
        ldy     #$00
        lda     ($06),y
        tay
L5A10:  lda     ($06),y
        sta     $1F00,y
        dey
        bpl     L5A10
        dec     $1F00
        lda     #$2F
        sta     $1F01
        ldax    #$1F00
        ldy     $1F00
        jsr     L6FB7
        lda     L704B
        beq     L5A4C
L5A2F:  ldx     L704B
        beq     L5A4C
        dex
        lda     L704C,x
        cmp     active_window_id
        beq     L5A43
        sta     findwindow_params_window_id
        jsr     handle_inactive_window_click
L5A43:  jsr     L61DC
        dec     L704B
        jmp     L5A2F

L5A4C:  jsr     redraw_windows_and_desktop
        jsr     clear_selection
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     $E25B
        tay
        pha
        lda     $E1A0,y
        sta     LE22F
        beq     L5A7F
        jsr     L8AF4
        dec     LDD9E
        lda     LE22F
        jsr     DESKTOP_FREE_SPACE
        jsr     reset_grafport3
        DESKTOP_RELAY_CALL $04, LE22F
L5A7F:  lda     buf3len
        sta     L5AC6
        inc     buf3len
        inc     LDD9E
        pla
        tay
        lda     DEVLST,y
        jsr     get_device_info
        bit     L5AD0
        bmi     L5AA9
        and     #$FF
        beq     L5AA9
        cmp     #$2F
        beq     L5AA9
        pha
        jsr     DESKTOP_COPY_FROM_BUF
        pla
        jsr     DESKTOP_SHOW_ALERT0
        rts

L5AA9:  lda     buf3len
        cmp     L5AC6
        beq     L5AC0
        ldx     buf3len
        dex
        lda     buf3,x
        jsr     file_address_lookup
        ldy     #$01
        jsr     DESKTOP_RELAY
L5AC0:  jsr     DESKTOP_COPY_FROM_BUF
        jmp     redraw_windows_and_desktop

L5AC6:  .res    10, 0
L5AD0:  .byte   0

;;; ==================================================

.proc cmd_startup_item
        ldx     $E25B
        dex
        txa
        asl     a
        asl     a
        asl     a
        clc
        adc     #6
        tax
        lda     s00,x
        sec
        sbc     #$30
        clc
        adc     #>$C000         ; compute $Cn00
        sta     reset_and_invoke_target+1
        lda     #<$0000
        sta     reset_and_invoke_target
        ;; fall through
.endproc

        ;; also invoked by launcher code
.proc reset_and_invoke
        sta     ALTZPOFF
        lda     ROMIN2
        jsr     SETVID
        jsr     SETKBD
        jsr     INIT
        jsr     HOME
        sta     TXTSET
        sta     LOWSCR
        sta     LORES
        sta     MIXCLR
        sta     DHIRESOFF
        sta     CLRALTCHAR
        sta     CLR80VID
        sta     CLR80COL

        ;; also used by launcher code
        target := *+1
        jmp     dummy0000       ; self-modified
.endproc
        reset_and_invoke_target := reset_and_invoke::target


;;; ==================================================

L5B1B:  .byte   0

.proc handle_client_click
        lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        ldx     active_window_id
        dex
        lda     win_buf_table,x
        sta     L5B1B
        ldx     #$03
L5B31:  lda     $EBFD,x
        sta     event_params_coords,x
        dex
        bpl     L5B31
        MGTK_RELAY_CALL MGTK::FindControl, event_params_coords
        lda     findcontrol_which_ctl
        bne     :+
        jmp     handle_content_click ; 0 = ctl_not_a_control
:       bit     double_click_flag
        bmi     :+
        jmp     done_client_click ; ignore double click
:       cmp     #MGTK::ctl_dead_zone
        bne     :+
        rts
:       cmp     #MGTK::ctl_vertical_scroll_bar
        bne     horiz

        ;; Vertical scrollbar
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$05
        lda     ($06),y
        and     #$01
        bne     :+
        jmp     done_client_click
:       jsr     L5803
        lda     $D20E
        cmp     #MGTK::part_thumb
        bne     :+
        jsr     do_track_thumb
        jmp     done_client_click

:       cmp     #MGTK::part_up_arrow
        bne     :+
up:     jsr     scroll_up
        lda     #MGTK::part_up_arrow
        jsr     check_control_repeat
        bpl     up
        jmp     done_client_click

:       cmp     #MGTK::part_down_arrow
        bne     :+
down:   jsr     scroll_down
        lda     #MGTK::part_down_arrow
        jsr     check_control_repeat
        bpl     down
        jmp     done_client_click

:       cmp     #MGTK::part_page_down
        beq     pgdn
pgup:   jsr     L638C
        lda     #MGTK::part_page_up
        jsr     check_control_repeat
        bpl     pgup
        jmp     done_client_click

pgdn:   jsr     L63EC
        lda     #MGTK::part_page_down
        jsr     check_control_repeat
        bpl     pgdn
        jmp     done_client_click

        ;; Horizontal scrollbar
horiz:  lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$04
        lda     ($06),y
        and     #$01
        bne     :+
        jmp     done_client_click
:       jsr     L5803
        lda     $D20E
        cmp     #MGTK::part_thumb
        bne     :+
        jsr     do_track_thumb
        jmp     done_client_click

:       cmp     #MGTK::part_left_arrow
        bne     :+
left:   jsr     scroll_left
        lda     #MGTK::part_left_arrow
        jsr     check_control_repeat
        bpl     left
        jmp     done_client_click

:       cmp     #MGTK::part_right_arrow
        bne     :+
rght:   jsr     scroll_right
        lda     #MGTK::part_right_arrow
        jsr     check_control_repeat
        bpl     rght
        jmp     done_client_click

:       cmp     #MGTK::part_page_right
        beq     pgrt
pglt:   jsr     L6451
        lda     #MGTK::part_page_left
        jsr     check_control_repeat
        bpl     pglt
        jmp     done_client_click

pgrt:   jsr     L64B0
        lda     #MGTK::part_page_right
        jsr     check_control_repeat
        bpl     pgrt
        jmp     done_client_click

done_client_click:
        jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF
.endproc

;;; ==================================================

.proc do_track_thumb
        lda     $D20D
        sta     trackthumb_which_ctl
        MGTK_RELAY_CALL MGTK::TrackThumb, trackthumb_params
        lda     trackthumb_thumbmoved
        bne     :+
        rts
:       jsr     L5C54
        jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF
.endproc

;;; ==================================================

L5C54:  lda     $D20D
        sta     updatethumb_params_thumbpos
        MGTK_RELAY_CALL MGTK::UpdateThumb, updatethumb_params
        jsr     L6523
        jsr     L84D1
        bit     L5B1B
        bmi     L5C71
        jsr     L6E6E
L5C71:  lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        MGTK_RELAY_CALL MGTK::PaintRect, grafport2::cliprect::x1
        jsr     reset_grafport3
        jmp     L6C19

;;; ==================================================
;;; Handle mouse held down on scroll arrow/pager

.proc check_control_repeat
        sta     ctl
        jsr     peek_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_drag
        beq     :+
bail:   lda     #$FF            ; high bit set = not repeating
        rts

:       MGTK_RELAY_CALL MGTK::FindControl, event_params_coords
        lda     findcontrol_which_ctl
        beq     bail
        cmp     #MGTK::ctl_dead_zone
        beq     bail
        lda     findcontrol_which_part
        cmp     ctl
        bne     bail
        lda     #0              ; high bit set = repeating
        rts

ctl:    .byte   0
.endproc

;;; ==================================================

.proc handle_content_click
        bit     L5B1B
        bpl     :+
        jmp     clear_selection

:       lda     active_window_id
        sta     $D20E
        DESKTOP_RELAY_CALL DT_FIND_ICON, event_params_coords
        lda     findicon_which_icon
        bne     L5CDA
        jsr     L5F13
        jmp     L5DEC
.endproc

;;; ==================================================


L5CD9:  .byte   0
L5CDA:  sta     L5CD9
        ldx     is_file_selected
        beq     L5CFB
        dex
        lda     L5CD9
L5CE6:  cmp     selected_file_index,x
        beq     L5CF0
        dex
        bpl     L5CE6
        bmi     L5CFB
L5CF0:  bit     double_click_flag
        bmi     L5CF8
        jmp     L5DFC

L5CF8:  jmp     L5D55

L5CFB:  bit     BUTN0
        bpl     L5D08
        lda     selected_window_index
        cmp     active_window_id
        beq     L5D0B
L5D08:  jsr     clear_selection
L5D0B:  ldx     is_file_selected
        lda     L5CD9
        sta     selected_file_index,x
        inc     is_file_selected
        lda     active_window_id
        sta     selected_window_index
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        lda     L5CD9
        sta     LE22F
        jsr     L8915
        jsr     L6E8E
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        lda     L5CD9
        jsr     L8893
        jsr     reset_grafport3
        bit     double_click_flag
        bmi     L5D55
        jmp     L5DFC

L5D55:  lda     L5CD9
        sta     LEBFC
        DESKTOP_RELAY_CALL $0A, LEBFC
        tax
        lda     LEBFC
        beq     L5DA6
        jsr     L8F00
        cmp     #$FF
        bne     L5D77
        jsr     L5DEC
        jmp     redraw_windows_and_desktop

L5D77:  lda     LEBFC
        cmp     $EBFB
        bne     L5D8E
        lda     active_window_id
        jsr     L6F0D
        lda     active_window_id
        jsr     L5E78
        jmp     redraw_windows_and_desktop

L5D8E:  lda     LEBFC
        bmi     L5D99
        jsr     L6A3F
        jmp     redraw_windows_and_desktop

L5D99:  and     #$7F
        pha
        jsr     L6F0D
        pla
        jsr     L5E78
        jmp     redraw_windows_and_desktop

L5DA6:  cpx     #$02
        bne     L5DAD
        jmp     L5DEC

L5DAD:  cpx     #$FF
        beq     L5DF7
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L6E52
        jsr     L6E8E
        ldx     is_file_selected
        dex
L5DC4:  txa
        pha
        lda     selected_file_index,x
        sta     LE22E
        DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, LE22E
        pla
        tax
        dex
        bpl     L5DC4
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L6DB1
        jsr     L6E6E
        jsr     reset_grafport3
L5DEC:  jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF

L5DF7:  ldx     $E256
        txs
        rts

L5DFC:  lda     L5CD9           ; after a double-click (on file or folder)
        jsr     file_address_lookup
        stax    $06
        ldy     #2              ; byte type icon offset
        lda     ($06),y
        and     #$70            ; bits 4-6
        cmp     #$10            ; $10 = system
        beq     L5E28
        cmp     #$20            ; $20 = binary
        beq     L5E28
        cmp     #$30            ; $30 = basic
        beq     L5E28
        cmp     #$00            ; $00 = directory
        bne     L5E27

        lda     L5CD9           ; handle directory
        jsr     L6A8A
        bmi     L5E27
        jmp     L5DEC

L5E27:  rts

L5E28:  sta     L5E77
        lda     active_window_id
        jsr     window_address_lookup
        stax    $06
        ldy     #$00
        lda     ($06),y
        tay
L5E3A:  lda     ($06),y
        sta     LD355,y
        dey
        bpl     L5E3A
        lda     L5CD9
        jsr     file_address_lookup
        stax    $06
        ldy     #$09
        lda     ($06),y
        tax
        clc
        adc     #$09
        tay
        dex
        dey
L5E57:  lda     ($06),y
        sta     LD343+1,x
        dey
        dex
        bne     L5E57
        ldy     #$09
        lda     ($06),y
        tax
        dex
        dex
        stx     $D345
        lda     L5E77
        cmp     #$20
        bcc     L5E74
        lda     L5E77
L5E74:  jmp     launch_file     ; when double-clicked

L5E77:  .byte   0
L5E78:  sta     L5F0A
        jsr     redraw_windows_and_desktop
        jsr     clear_selection
        lda     L5F0A
        cmp     active_window_id
        beq     L5E8F
        sta     findwindow_params_window_id
        jsr     handle_inactive_window_click
L5E8F:  lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     set_penmode_copy
        MGTK_RELAY_CALL MGTK::PaintRect, grafport2::cliprect::x1
        ldx     active_window_id
        dex
        lda     LEC26,x
        pha
        jsr     L7345
        lda     L5F0A
        tax
        dex
        lda     win_buf_table,x
        bmi     L5EBC
        jsr     L5302
L5EBC:  lda     active_window_id
        jsr     window_address_lookup
        stax    $06
        ldy     #$00
        lda     ($06),y
        tay
L5ECB:  lda     ($06),y
        sta     $E1B0,y
        dey
        bpl     L5ECB
        pla
        jsr     L7054
        jsr     cmd_view_by_icon::L5106
        jsr     DESKTOP_COPY_FROM_BUF
        lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L4505
        jsr     L78EF
        lda     #$00
        ldx     active_window_id
        sta     win_buf_table-1,x
        lda     #$01
        sta     $E25B
        jsr     update_view_menu_check
        lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF

L5F0A:  .byte   0
L5F0B:  .byte   0
        .byte   0
        .byte   0
        .byte   0
L5F0F:  .byte   0
        .byte   0
        .byte   0
        .byte   0
L5F13:  copy16  #notpenXOR, $06
        jsr     L60D5
        ldx     #$03
L5F20:  lda     event_params_coords,x
        sta     L5F0B,x
        sta     L5F0F,x
        dex
        bpl     L5F20
        jsr     peek_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_drag
        beq     L5F3F
        bit     BUTN0
        bmi     L5F3E
        jsr     clear_selection
L5F3E:  rts

L5F3F:  jsr     clear_selection
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L4505
        jsr     L6E8E
        ldx     #$03
L5F50:  lda     L5F0B,x
        sta     rect_E230,x
        lda     L5F0F,x
        sta     $E234,x
        dex
        bpl     L5F50
        jsr     set_penmode_xor
        MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
L5F6B:  jsr     peek_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_drag
        beq     L5FC5
        MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
        ldx     #$00
L5F80:  cpx     buf3len
        bne     L5F88
        jmp     reset_grafport3

L5F88:  txa
        pha
        lda     buf3,x
        sta     LE22F
        jsr     L8915
        DESKTOP_RELAY_CALL DT_ICON_IN_RECT, LE22F
        beq     L5FB9
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        ldx     is_file_selected
        inc     is_file_selected
        lda     LE22F
        sta     selected_file_index,x
        lda     active_window_id
        sta     selected_window_index
L5FB9:  lda     LE22F
        jsr     L8893
        pla
        tax
        inx
        jmp     L5F80

L5FC5:  jsr     L60D5
        sub16  event_params_xcoord, L60CF, L60CB
        sub16  event_params_ycoord, L60D1, L60CD
        lda     L60CC
        bpl     L5FFE
        lda     L60CB
        eor     #$FF
        sta     L60CB
        inc     L60CB
L5FFE:  lda     L60CE
        bpl     L600E
        lda     L60CD
        eor     #$FF
        sta     L60CD
        inc     L60CD
L600E:  lda     L60CB
        cmp     #$05
        bcs     L601F
        lda     L60CD
        cmp     #$05
        bcs     L601F
        jmp     L5F6B

L601F:  MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
        ldx     #$03
L602A:  lda     event_params_coords,x
        sta     L60CF,x
        dex
        bpl     L602A
        lda     event_params_xcoord
        cmp     $E234
        lda     event_params_xcoord+1
        sbc     $E235
        bpl     L6068
        lda     event_params_xcoord
        cmp     rect_E230
        lda     event_params_xcoord+1
        sbc     $E231
        bmi     L6054
        bit     L60D3
        bpl     L6068
L6054:  copy16  event_params_xcoord, rect_E230
        lda     #$80
        sta     L60D3
        jmp     L6079

L6068:  copy16  event_params_xcoord, $E234
        lda     #$00
        sta     L60D3
L6079:  lda     event_params_ycoord
        cmp     $E236
        lda     event_params_ycoord+1
        sbc     $E237
        bpl     L60AE
        lda     event_params_ycoord
        cmp     $E232
        lda     event_params_ycoord+1
        sbc     $E233
        bmi     L609A
        bit     L60D4
        bpl     L60AE
L609A:  copy16  event_params_ycoord, $E232
        lda     #$80
        sta     L60D4
        jmp     L60BF

L60AE:  copy16  event_params_ycoord, $E236
        lda     #$00
        sta     L60D4
L60BF:  MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
        jmp     L5F6B

L60CB:  .byte   0
L60CC:  .byte   0
L60CD:  .byte   0
L60CE:  .byte   0
L60CF:  .word   0
L60D1:  .word   0
L60D3:  .byte   0
L60D4:  .byte   0
L60D5:  jsr     push_zp_addrs
        jmp     L8921

handle_title_click:
        jmp     L60DE

L60DE:  lda     active_window_id
        sta     event_params
        MGTK_RELAY_CALL MGTK::FrontWindow, active_window_id
        lda     active_window_id
        jsr     L8855
        MGTK_RELAY_CALL MGTK::DragWindow, event_params
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$16
        lda     ($06),y
        cmp     #$19
        bcs     L6112
        lda     #$19
        sta     ($06),y
L6112:  ldy     #$14
        lda     ($06),y
        sec
        sbc     L8830
        sta     L6197
        iny
        lda     ($06),y
        sbc     L8831
        sta     L6198
        iny
        lda     ($06),y
        sec
        sbc     L8832
        sta     L6199
        iny
        lda     ($06),y
        sbc     L8833
        sta     L619A
        ldx     active_window_id
        dex
        lda     win_buf_table,x
        beq     L6143
        rts

L6143:  lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        ldx     #$00
L614E:  cpx     buf3len
        bne     L6161
        jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jmp     L6196

L6161:  txa
        pha
        lda     buf3,x
        jsr     file_address_lookup
        stax    $06
        ldy     #$03
        lda     ($06),y
        clc
        adc     L6197
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L6198
        sta     ($06),y
        iny
        lda     ($06),y
        clc
        adc     L6199
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L619A
        sta     ($06),y
        pla
        tax
        inx
        jmp     L614E

L6196:  rts

L6197:  .byte   0
L6198:  .byte   0
L6199:  .byte   0
L619A:  .byte   0

handle_resize_click:
        lda     active_window_id
        sta     event_params
        MGTK_RELAY_CALL MGTK::GrowWindow, event_params
        jsr     redraw_windows_and_desktop
        lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jsr     L6E52
        jsr     L6DB1
        jsr     L6E6E
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jmp     reset_grafport3

handle_close_click:
        lda     active_window_id
        MGTK_RELAY_CALL MGTK::TrackGoAway, trackgoaway_params
        lda     trackgoaway_params::goaway
        bne     L61DC
        rts

L61DC:  lda     active_window_id
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jsr     clear_selection
        ldx     active_window_id
        dex
        lda     win_buf_table,x
        bmi     L6215
        lda     LDD9E
        sec
        sbc     buf3len
        sta     LDD9E
        DESKTOP_RELAY_CALL DT_CLOSE_WINDOW, active_window_id
        ldx     #$00
L6206:  cpx     buf3len
        beq     L6215
        lda     buf3,x
        jsr     DESKTOP_FREE_SPACE
        inx
        jmp     L6206

L6215:  dec     $EC2E
        ldx     #$00
        txa
L621B:  sta     buf3,x
        cpx     buf3len
        beq     L6227
        inx
        jmp     L621B

L6227:  sta     buf3len
        jsr     DESKTOP_COPY_FROM_BUF
        MGTK_RELAY_CALL MGTK::CloseWindow, active_window_id
        ldx     active_window_id
        dex
        lda     LEC26,x
        sta     LE22F
        jsr     file_address_lookup
        stax    $06
        ldy     #$01
        lda     ($06),y
        and     #$0F
        beq     L6276
        ldy     #$02
        lda     ($06),y
        and     #$7F
        sta     ($06),y
        and     #$0F
        sta     selected_window_index
        jsr     L8997
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        jsr     reset_grafport3
        lda     #$01
        sta     is_file_selected
        lda     LE22F
        sta     selected_file_index
L6276:  ldx     active_window_id
        dex
        lda     LEC26,x
        jsr     L7345
        ldx     active_window_id
        dex
        lda     LEC26,x
        inx
        jsr     L8B5C
        ldx     active_window_id
        dex
        lda     #$00
        sta     LEC26,x
        sta     win_buf_table,x
        MGTK_RELAY_CALL MGTK::FrontWindow, active_window_id
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     #$00
        sta     checkitem_params::check
        MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params
        jsr     L66A2
        jmp     redraw_windows_and_desktop

L62BC:  cmp     #$01
        bcc     L62C2
        bne     L62C5
L62C2:  lda     #$00
        rts

L62C5:  sta     L638B
        stx     L6386
        sty     L638A
        cmp     L6386
        bcc     L62D5
        tya
        rts

L62D5:  lda     #$00
        sta     L6385
        sta     L6389
        clc
        ror     L6386
        ror     L6385
        clc
        ror     L638A
        ror     L6389
        lda     #$00
        sta     L6383
        sta     L6387
        sta     L6384
        sta     L6388
L62F9:  lda     L6384
        cmp     L638B
        beq     L630F
        bcc     L6309
        jsr     L6319
        jmp     L62F9

L6309:  jsr     L634E
        jmp     L62F9

L630F:  lda     L6388
        cmp     #$01
        bcs     L6318
        lda     #$01
L6318:  rts

L6319:  sub16  L6383, L6385, L6383
        sub16  L6387, L6389, L6387
        clc
        ror     L6386
        ror     L6385
        clc
        ror     L638A
        ror     L6389
        rts

L634E:  add16 L6383, L6385, L6383
        add16 L6387, L6389, L6387
        clc
        ror     L6386
        ror     L6385
        clc
        ror     L638A
        ror     L6389
        rts

L6383:  .byte   0
L6384:  .byte   0
L6385:  .byte   0
L6386:  .byte   0
L6387:  .byte   0
L6388:  .byte   0
L6389:  .byte   0
L638A:  .byte   0
L638B:  .byte   0
L638C:  jsr     L650F
        sty     L63E9
        jsr     L644C
        sta     L63E8
        lda     grafport2::cliprect::y1
        sec
        sbc     L63E8
        sta     L63EA
        lda     grafport2::cliprect::y1+1
        sbc     #$00
        sta     L63EB
        lda     L63EA
        cmp     L7B61
        lda     L63EB
        sbc     L7B62
        bmi     L63C1
        ldax    L63EA
        jmp     L63C7

L63C1:  ldax    L7B61
L63C7:  stax    grafport2::cliprect::y1
        add16_8 grafport2::cliprect::y1, L63E9, grafport2::cliprect::y2
        jsr     L653E
        jsr     L6DB1
        jmp     L6556

L63E8:  .byte   0
L63E9:  .byte   0
L63EA:  .byte   0
L63EB:  .byte   0
L63EC:  jsr     L650F
        sty     L6449
        jsr     L644C
        sta     L6448
        add16_8 grafport2::cliprect::y2, L6448, L644A
        lda     L644A
        cmp     L7B65
        lda     L644B
        sbc     L7B66
        bpl     L6421
        ldax    L644A
        jmp     L6427

L6421:  ldax    L7B65
L6427:  stax    grafport2::cliprect::y2
        lda     grafport2::cliprect::y2
        sec
        sbc     L6449
        sta     grafport2::cliprect::y1
        lda     grafport2::cliprect::y2+1
        sbc     #$00
        sta     grafport2::cliprect::y1+1
        jsr     L653E
        jsr     L6DB1
        jmp     L6556

L6448:  .byte   0
L6449:  .byte   0
L644A:  .byte   0
L644B:  .byte   0
L644C:  tya
        sec
        sbc     #$0E
        rts

L6451:  jsr     L650F
        stax    L64AC
        sub16  grafport2::cliprect::x1, L64AC, L64AE
        lda     L64AE
        cmp     L7B5F
        lda     L64AF
        sbc     L7B60
        bmi     L6484
        ldax    L64AE
        jmp     L648A

L6484:  ldax    L7B5F
L648A:  stax    grafport2::cliprect::x1
        add16 grafport2::cliprect::x1, L64AC, grafport2::cliprect::x2
        jsr     L653E
        jsr     L6DB1
        jmp     L6556

L64AC:  .byte   0
L64AD:  .byte   0
L64AE:  .byte   0
L64AF:  .byte   0
L64B0:  jsr     L650F
        stax    L650B
        add16 grafport2::cliprect::x2, L650B, L650D
        lda     L650D
        cmp     L7B63
        lda     L650E
        sbc     L7B64
        bpl     L64E3
        ldax    L650D
        jmp     L64E9

L64E3:  ldax    L7B63
L64E9:  stax    grafport2::cliprect::x2
        sub16  grafport2::cliprect::x2, L650B, grafport2::cliprect::x1
        jsr     L653E
        jsr     L6DB1
        jmp     L6556

L650B:  .byte   0
L650C:  .byte   0
L650D:  .byte   0
L650E:  .byte   0
L650F:  bit     L5B1B
        bmi     L6517
        jsr     L6E52
L6517:  jsr     L6523
        jsr     L7B6B
        lda     active_window_id
        jmp     L7D5D

L6523:  lda     active_window_id
        jsr     window_lookup
        clc
        adc     #$14
        sta     $06
        txa
        adc     #$00
        sta     $06+1
        ldy     #$25
L6535:  lda     ($06),y
        sta     grafport2,y
        dey
        bpl     L6535
        rts

L653E:  lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$23
        ldx     #$07
L654C:  lda     grafport2::cliprect::x1,x
        sta     ($06),y
        dey
        dex
        bpl     L654C
        rts

L6556:  bit     L5B1B
        bmi     L655E
        jsr     L6E6E
L655E:  MGTK_RELAY_CALL MGTK::PaintRect, grafport2::cliprect::x1
        jsr     reset_grafport3
        jmp     L6C19

L656D:  lda     active_window_id
        jsr     L7D5D
        stax    L6600
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$06
        lda     ($06),y
        tay
        sub16  L7B63, L7B5F, L6602
        sub16  L6602, L6600, L6602
        lsr     L6603
        ror     L6602
        ldx     L6602
        sub16  grafport2::cliprect::x1, L7B5F, L6602
        bpl     L65D0
        lda     #$00
        beq     L65EB
L65D0:  lda     grafport2::cliprect::x2
        cmp     L7B63
        lda     grafport2::cliprect::x2+1
        sbc     L7B64
        bmi     L65E2
        tya
        jmp     L65EE

L65E2:  lsr     L6603
        ror     L6602
        lda     L6602
L65EB:  jsr     L62BC
L65EE:  sta     event_params+1
        lda     #$02
        sta     event_params
        MGTK_RELAY_CALL MGTK::UpdateThumb, event_params
        rts

L6600:  .word   0
L6602:  .byte   0
L6603:  .byte   0
L6604:  lda     active_window_id
        jsr     L7D5D
        sty     L669F
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$08
        lda     ($06),y
        tay
        sub16  L7B65, L7B61, L66A0
        lda     L66A0
        sec
        sbc     L669F
        sta     L66A0
        lda     L66A1
        sbc     #$00
        sta     L66A1
        lsr     L66A1
        ror     L66A0
        lsr     L66A1
        ror     L66A0
        ldx     L66A0
        sub16  grafport2::cliprect::y1, L7B61, L66A0
        bpl     L6669
        lda     #$00
        beq     L668A
L6669:  lda     grafport2::cliprect::y2
        cmp     L7B65
        lda     grafport2::cliprect::y2+1
        sbc     L7B66
        bmi     L667B
        tya
        jmp     L668D

L667B:  lsr     L66A1
        ror     L66A0
        lsr     L66A1
        ror     L66A0
        lda     L66A0
L668A:  jsr     L62BC
L668D:  sta     event_params+1
        lda     #$01
        sta     event_params
        MGTK_RELAY_CALL MGTK::UpdateThumb, event_params
        rts

L669F:  .byte   0
L66A0:  .byte   0
L66A1:  .byte   0
L66A2:  ldx     active_window_id
        beq     L66AA
        jmp     L66F2

L66AA:  lda     #$01
        sta     disablemenu_params::disable
        MGTK_RELAY_CALL MGTK::DisableMenu, disablemenu_params
        lda     #$01
        sta     disableitem_params::disable
        lda     #$02
        sta     disableitem_params::menu_id
        lda     #$01
        sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        lda     #$04
        sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        lda     #$05
        sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        lda     #$00
        sta     menu_dispatch_flag
        rts

L66F2:  dex
        lda     win_buf_table,x
        and     #$0F
        tax
        inx
        stx     checkitem_params::menu_item
        lda     #$01
        sta     checkitem_params::check
        MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params
        rts

L670C:  lda     #$01
        sta     disableitem_params::disable
        lda     #$02
        sta     disableitem_params::menu_id
        lda     #$03
        jsr     L673A
        lda     #$05
        sta     disableitem_params::menu_id
        lda     #$07
        jsr     L673A
        lda     #$08
        jsr     L673A
        lda     #$0A
        jsr     L673A
        lda     #$0B
        jsr     L673A
        lda     #$0D
        jsr     L673A
        rts

L673A:  sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        rts

L6747:  lda     #$00
        sta     disableitem_params::disable
        lda     #$02
        sta     disableitem_params::menu_id
        lda     #$03
        jsr     L6775
        lda     #$05
        sta     disableitem_params::menu_id
        lda     #$07
        jsr     L6775
        lda     #$08
        jsr     L6775
        lda     #$0A
        jsr     L6775
        lda     #$0B
        jsr     L6775
        lda     #$0D
        jsr     L6775
        rts

L6775:  sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        rts

L6782:  lda     #$00
        sta     disableitem_params::disable
        jmp     L678F

L678A:  lda     #$01
        sta     disableitem_params::disable
L678F:  lda     #$02
        sta     disableitem_params::menu_id
        lda     #$0B
        sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        rts

L67A3:  lda     #$01
        sta     disableitem_params::disable
        jmp     L67B0

L67AB:  lda     #$00
        sta     disableitem_params::disable
L67B0:  lda     #$03
        sta     disableitem_params::menu_id
        lda     #$02
        jsr     L67CA
        lda     #$03
        jsr     L67CA
        lda     #$04
        jsr     L67CA
        lda     #$80
        sta     LD343+1
        rts

L67CA:  sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        rts

L67D7:  lda     is_file_selected
        bne     L67DF
        jmp     L681B

L67DF:  tax
        dex
        lda     $D20D
L67E4:  cmp     selected_file_index,x
        beq     L67EE
        dex
        bpl     L67E4
        bmi     L67F6
L67EE:  bit     double_click_flag
        bmi     L6834
        jmp     L6880

L67F6:  bit     BUTN0
        bpl     L6818
        lda     selected_window_index
        bne     L6818
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, $D20D
        ldx     is_file_selected
        lda     $D20D
        sta     selected_file_index,x
        inc     is_file_selected
        jmp     L6834

L6818:  jsr     clear_selection
L681B:  DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, $D20D
        lda     #$01
        sta     is_file_selected
        lda     $D20D
        sta     selected_file_index
        lda     #$00
        sta     selected_window_index
L6834:  bit     double_click_flag
        bpl     L6880
        lda     $D20D
        sta     LEBFC
        DESKTOP_RELAY_CALL $0A, LEBFC
        tax
        lda     LEBFC
        beq     L6878
        jsr     L8F00
        cmp     #$FF
        bne     L6858
        jmp     redraw_windows_and_desktop

L6858:  lda     LEBFC
        cmp     $EBFB
        bne     L6863
        jmp     redraw_windows_and_desktop

L6863:  lda     LEBFC
        bpl     L6872
        and     #$7F
        pha
        jsr     L6F0D
        pla
        jmp     L5E78

L6872:  jsr     L6A3F
        jmp     redraw_windows_and_desktop

L6878:  txa
        cmp     #$02
        bne     L688F
        jmp     redraw_windows_and_desktop

L6880:  lda     $D20D
        cmp     $EBFB
        beq     L688E
        jsr     L6A8A
        jsr     DESKTOP_COPY_FROM_BUF
L688E:  rts

L688F:  ldx     is_file_selected
        dex
L6893:  txa
        pha
        lda     selected_file_index,x
        sta     $E22D
        DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, $E22D
        pla
        tax
        dex
        bpl     L6893
        rts

L68AA:  jsr     reset_grafport3
        bit     BUTN0
        bpl     L68B3
        rts

L68B3:  jsr     clear_selection
        ldx     #$03
L68B8:  lda     event_params_coords,x
        sta     rect_E230,x
        sta     $E234,x
        dex
        bpl     L68B8
        jsr     peek_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_drag
        beq     L68CF
        rts

L68CF:  MGTK_RELAY_CALL MGTK::SetPattern, checkerboard_pattern3
        jsr     set_penmode_xor
        MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
L68E4:  jsr     peek_event
        lda     event_params_kind
        cmp     #MGTK::event_kind_drag
        beq     L6932
        MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
        ldx     #$00
L68F9:  cpx     buf3len
        bne     L6904
        lda     #$00
        sta     selected_window_index
        rts

L6904:  txa
        pha
        lda     buf3,x
        sta     LE22F
        DESKTOP_RELAY_CALL DT_ICON_IN_RECT, LE22F
        beq     L692C
        DESKTOP_RELAY_CALL DT_HIGHLIGHT_ICON, LE22F
        ldx     is_file_selected
        inc     is_file_selected
        lda     LE22F
        sta     selected_file_index,x
L692C:  pla
        tax
        inx
        jmp     L68F9

L6932:  sub16  event_params_xcoord, L6A39, L6A35
        sub16  event_params_ycoord, L6A3B, L6A37
        lda     L6A36
        bpl     L6968
        lda     L6A35
        eor     #$FF
        sta     L6A35
        inc     L6A35
L6968:  lda     L6A38
        bpl     L6978
        lda     L6A37
        eor     #$FF
        sta     L6A37
        inc     L6A37
L6978:  lda     L6A35
        cmp     #$05
        bcs     L6989
        lda     L6A37
        cmp     #$05
        bcs     L6989
        jmp     L68E4

L6989:  MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
        ldx     #$03
L6994:  lda     event_params_coords,x
        sta     L6A39,x
        dex
        bpl     L6994
        lda     event_params_xcoord
        cmp     $E234
        lda     event_params_xcoord+1
        sbc     $E235
        bpl     L69D2
        lda     event_params_xcoord
        cmp     rect_E230
        lda     event_params_xcoord+1
        sbc     $E231
        bmi     L69BE
        bit     L6A3D
        bpl     L69D2
L69BE:  copy16  event_params_xcoord, rect_E230
        lda     #$80
        sta     L6A3D
        jmp     L69E3

L69D2:  copy16  event_params_xcoord, $E234
        lda     #$00
        sta     L6A3D
L69E3:  lda     event_params_ycoord
        cmp     $E236
        lda     event_params_ycoord+1
        sbc     $E237
        bpl     L6A18
        lda     event_params_ycoord
        cmp     $E232
        lda     event_params_ycoord+1
        sbc     $E233
        bmi     L6A04
        bit     L6A3E
        bpl     L6A18
L6A04:  copy16  event_params_ycoord, $E232
        lda     #$80
        sta     L6A3E
        jmp     L6A29

L6A18:  copy16  event_params_ycoord, $E236
        lda     #$00
        sta     L6A3E
L6A29:  MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
        jmp     L68E4

L6A35:  .byte   0
L6A36:  .byte   0
L6A37:  .byte   0
L6A38:  .byte   0
L6A39:  .word   0
L6A3B:  .word   0
L6A3D:  .byte   0
L6A3E:  .byte   0
L6A3F:  ldx     #$07
L6A41:  cmp     LEC26,x
        beq     L6A80
        dex
        bpl     L6A41
        jsr     file_address_lookup
        clc
        adc     #$09
        sta     $06
        txa
        adc     #$00
        sta     $06+1
        ldy     #$00
        lda     ($06),y
        tay
        dey
L6A5C:  lda     ($06),y
        sta     $220,y
        dey
        bpl     L6A5C
        dec     $220
        lda     #$2F
        sta     $0221

        ldax    #$220
        ldy     $220
        jsr     L6FB7
        ldax    #$220
        ldy     $220
        jmp     L6F4B

L6A80:  inx
        txa
        pha
        jsr     L6F0D
        pla
        jmp     L5E78

L6A8A:  sta     LE6BE
        jsr     DESKTOP_COPY_FROM_BUF
        lda     LE6BE
        ldx     #$07
L6A95:  cmp     LEC26,x
        beq     L6AA0
        dex
        bpl     L6A95
        jmp     L6B1E

L6AA0:  inx
        cpx     active_window_id
        bne     L6AA7
        rts

L6AA7:  stx     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        lda     LE6BE
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        ora     #$80
        sta     ($06),y
        ldy     #$02
        lda     ($06),y
        and     #$0F
        sta     getwinport_params2::window_id
        beq     L6AD8
        cmp     active_window_id
        bne     L6AEF
        jsr     L44F2
        lda     LE6BE
        jsr     L8915
L6AD8:  DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, LE6BE
        lda     getwinport_params2::window_id
        beq     L6AEF
        lda     LE6BE
        jsr     L8893
        jsr     reset_grafport3
L6AEF:  lda     LE6BE
        ldx     $E1F1
        dex
L6AF6:  cmp     $E1F2,x
        beq     L6B01
        dex
        bpl     L6AF6
        jsr     L7054
L6B01:  MGTK_RELAY_CALL MGTK::SelectWindow, bufnum
        lda     bufnum
        sta     active_window_id
        jsr     L6C19
        jsr     redraw_windows
        lda     #$00
        sta     bufnum
        jmp     DESKTOP_COPY_TO_BUF

L6B1E:  lda     $EC2E
        cmp     #$08
        bcc     L6B2F
        lda     #warning_msg_too_many_windows
        jsr     show_warning_dialog_num
        ldx     $E256
        txs
        rts

L6B2F:  ldx     #$00
L6B31:  lda     LEC26,x
        beq     L6B3A
        inx
        jmp     L6B31

L6B3A:  lda     LE6BE
        sta     LEC26,x
        inx
        stx     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        inc     $EC2E
        ldx     bufnum
        dex
        lda     #$00
        sta     win_buf_table,x
        lda     $EC2E
        cmp     #$02
        bcs     L6B60
        jsr     L6EC5
        jmp     L6B68

L6B60:  lda     #$00
        sta     checkitem_params::check
        jsr     L6C0F
L6B68:  lda     #$01
        sta     checkitem_params::menu_item
        sta     checkitem_params::check
        jsr     L6C0F
        lda     LE6BE
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        ora     #$80
        sta     ($06),y
        ldy     #$02
        lda     ($06),y
        and     #$0F
        sta     getwinport_params2::window_id
        beq     L6BA1
        cmp     active_window_id
        bne     L6BB8
        jsr     L44F2
        jsr     L6E8E
        lda     LE6BE
        jsr     L8915
L6BA1:  DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, LE6BE
        lda     getwinport_params2::window_id
        beq     L6BB8
        lda     LE6BE
        jsr     L8893
        jsr     reset_grafport3
L6BB8:  jsr     L744B
        lda     bufnum
        jsr     window_lookup
        ldy     #$38
        jsr     MGTK_RELAY
        lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L78EF
        jsr     L6E52
        lda     #$00
        sta     L6C0E
L6BDA:  lda     L6C0E
        cmp     buf3len
        beq     L6BF4
        tax
        lda     buf3,x
        jsr     file_address_lookup
        ldy     #$01
        jsr     DESKTOP_RELAY
        inc     L6C0E
        jmp     L6BDA

L6BF4:  lda     bufnum
        sta     active_window_id
        jsr     L6DB1
        jsr     L6E6E
        jsr     DESKTOP_COPY_FROM_BUF
        lda     #$00
        sta     bufnum
        jsr     DESKTOP_COPY_TO_BUF
        jmp     reset_grafport3

L6C0E:  .byte   0
L6C0F:  MGTK_RELAY_CALL MGTK::CheckItem, checkitem_params
        rts

L6C19:  ldx     bufnum
        dex
        lda     win_buf_table,x
        bmi     L6C25
        jmp     L6CCD

L6C25:  jsr     push_zp_addrs
        lda     bufnum
        sta     getwinport_params2::window_id
        jsr     L44F2
        bit     L4152
        bmi     L6C39
        jsr     L78EF
L6C39:  lda     bufnum
        sta     getwinport_params2::window_id
        jsr     L4505
        bit     L4152
        bmi     L6C4A
        jsr     L6E8E
L6C4A:  ldx     bufnum
        dex
        lda     LEC26,x
        ldx     #$00
L6C53:  cmp     $E1F2,x
        beq     L6C5F
        inx
        cpx     $E1F1
        bne     L6C53
        rts

L6C5F:  txa
        asl     a
        tax
        lda     $E202,x
        sta     $E71D
        sta     $06
        lda     $E203,x
        sta     $E71E
        sta     $06+1
        lda     LCBANK2
        lda     LCBANK2
        ldy     #$00
        lda     ($06),y
        tay
        lda     LCBANK1
        lda     LCBANK1
        tya
        sta     $E71F
        inc     $E71D
        bne     L6C8F
        inc     $E71E
L6C8F:  lda     #$10
        sta     point9::ycoord
        sta     pointA::ycoord
        sta     pointB::ycoord
        sta     pointC::ycoord
        lda     #$00
        sta     point9::ycoord+1
        sta     pointA::ycoord+1
        sta     pointB::ycoord+1
        sta     pointC::ycoord+1
        lda     #$00
        sta     L6CCC
L6CB0:  lda     L6CCC
        cmp     buf3len
        beq     L6CC5
        tax
        lda     buf3,x
        jsr     L813F
        inc     L6CCC
        jmp     L6CB0

L6CC5:  jsr     reset_grafport3
        jsr     pop_zp_addrs
        rts

L6CCC:  .byte   0
L6CCD:  lda     bufnum
        sta     getwinport_params2::window_id
        jsr     L44F2
        bit     L4152
        bmi     L6CDE
        jsr     L78EF
L6CDE:  jsr     L6E52
        jsr     L6E8E
        ldx     #$07
L6CE6:  lda     grafport2::cliprect::x1,x
        sta     rect_E230,x
        dex
        bpl     L6CE6
        ldx     #$00
        txa
        pha
L6CF3:  cpx     buf3len
        bne     L6D09
        pla
        jsr     reset_grafport3
        lda     bufnum
        sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L6E6E
        rts

L6D09:  txa
        pha
        lda     buf3,x
        sta     LE22F
        DESKTOP_RELAY_CALL DT_ICON_IN_RECT, LE22F
        beq     L6D25
        DESKTOP_RELAY_CALL DT_UNHIGHLIGHT_ICON, LE22F
L6D25:  pla
        tax
        inx
        jmp     L6CF3

clear_selection:
        lda     is_file_selected
        bne     L6D31
        rts

L6D31:  lda     #$00
        sta     L6DB0
        lda     selected_window_index
        sta     rect_E230
        beq     L6D7D
        cmp     active_window_id
        beq     L6D4D
        jsr     L8997
        lda     #$00
        sta     rect_E230
        beq     L6D56
L6D4D:  sta     getwinport_params2::window_id
        jsr     L44F2
        jsr     L6E8E
L6D56:  lda     L6DB0
        cmp     is_file_selected
        beq     L6D9B
        tax
        lda     selected_file_index,x
        sta     LE22F
        jsr     L8915
        DESKTOP_RELAY_CALL $0B, LE22F
        lda     LE22F
        jsr     L8893
        inc     L6DB0
        jmp     L6D56

L6D7D:  lda     L6DB0
        cmp     is_file_selected
        beq     L6D9B
        tax
        lda     selected_file_index,x
        sta     LE22F
        DESKTOP_RELAY_CALL $0B, LE22F
        inc     L6DB0
        jmp     L6D7D

L6D9B:  lda     #$00
        ldx     is_file_selected
        dex
L6DA1:  sta     selected_file_index,x
        dex
        bpl     L6DA1
        sta     is_file_selected
        sta     selected_window_index
        jmp     reset_grafport3

L6DB0:  .byte   0
L6DB1:  ldx     active_window_id
        dex
        lda     win_buf_table,x
        bmi     L6DC0
        jsr     L7B6B
        jmp     L6DC9

L6DC0:  jsr     L6E52
        jsr     L7B6B
        jsr     L6E6E
L6DC9:  lda     active_window_id
        sta     getwinport_params2::window_id
        jsr     L44F2
        lda     L7B5F
        cmp     grafport2::cliprect::x1
        lda     L7B60
        sbc     grafport2::cliprect::x1+1
        bmi     L6DFE
        lda     grafport2::cliprect::x2
        cmp     L7B63
        lda     grafport2::cliprect::x2+1
        sbc     L7B64
        bmi     L6DFE
        lda     #$02
        sta     event_params
        lda     #$00
        sta     event_params+1
        jsr     L6E48
        jmp     L6E0E

L6DFE:  lda     #$02
        sta     event_params
        lda     #$01
        sta     event_params+1
        jsr     L6E48
        jsr     L656D
L6E0E:  lda     L7B61
        cmp     grafport2::cliprect::y1
        lda     L7B62
        sbc     grafport2::cliprect::y1+1
        bmi     L6E38
        lda     grafport2::cliprect::y2
        cmp     L7B65
        lda     grafport2::cliprect::y2+1
        sbc     L7B66
        bmi     L6E38
        lda     #$01
        sta     event_params
        lda     #$00
        sta     event_params+1
        jsr     L6E48
        rts

L6E38:  lda     #$01
        sta     event_params
        lda     #$01
        sta     event_params+1
        jsr     L6E48
        jmp     L6604

L6E48:  MGTK_RELAY_CALL MGTK::ActivateCtl, event_params ; ???
        rts

L6E52:  lda     #$00
        sta     L6E6D
L6E57:  lda     L6E6D
        cmp     buf3len
        beq     L6E6C
        tax
        lda     buf3,x
        jsr     L8915
        inc     L6E6D
        jmp     L6E57

L6E6C:  rts

L6E6D:  .byte   0
L6E6E:  lda     #$00
        sta     L6E89
L6E73:  lda     L6E89
        cmp     buf3len
        beq     L6E88
        tax
        lda     buf3,x
        jsr     L8893
        inc     L6E89
        jmp     L6E73

L6E88:  rts

L6E89:  .byte   0
L6E8A:  lda     #$80
        beq     L6E90
L6E8E:  lda     #$00
L6E90:  sta     L6EC4
        add16 grafport2::viewloc::ycoord, #$0F, grafport2::viewloc::ycoord
        add16 grafport2::cliprect::y1, #$0F, grafport2::cliprect::y1
        bit     L6EC4
        bmi     L6EC3
        MGTK_RELAY_CALL MGTK::SetPort, grafport2
L6EC3:  rts

L6EC4:  .byte   0
L6EC5:  lda     #$00
        sta     disablemenu_params::disable
        MGTK_RELAY_CALL MGTK::DisableMenu, disablemenu_params
        lda     #$00
        sta     disableitem_params::disable
        lda     #$02
        sta     disableitem_params::menu_id
        lda     #$01
        sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        lda     #$04
        sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        lda     #$05
        sta     disableitem_params::menu_item
        MGTK_RELAY_CALL MGTK::DisableItem, disableitem_params
        lda     #$80
        sta     menu_dispatch_flag
        rts

L6F0D:  jsr     window_address_lookup
        sta     $06
        sta     L6F48
        stx     $06+1
        stx     L6F49
        ldy     #$00
        lda     ($06),y
        sta     L6F4A
        iny
L6F22:  iny
        lda     ($06),y
        cmp     #$2F
        beq     L6F31
        cpy     L6F4A
        beq     L6F32
        jmp     L6F22

L6F31:  dey
L6F32:  sty     L6F4A
        ldax    $06
        jsr     L6FB7
        ldax    L6F48
        ldy     L6F4A
        jmp     L6F4B

L6F48:  .byte   0
L6F49:  .byte   0
L6F4A:  .byte   0
L6F4B:  stax    $06
        sty     L705D
L6F52:  lda     ($06),y
        sta     L705D,y
        dey
        bne     L6F52
        jsr     L72EC
        bne     L6F8F
        lda     L704B
        beq     L6F8F
L6F64:  dec     L704B
        bmi     L6F8F
        ldx     L704B
        lda     L704C,x
        sec
        sbc     #$01
        asl     a
        tax
        lda     L70BD
        sta     $EB8B,x
        lda     L70BE
        sta     $EB8C,x
        lda     L70BB
        sta     $EB9B,x
        lda     L70BC
        sta     $EB9C,x
        jmp     L6F64

L6F8F:  rts

L6F90:  stax    $0A
        ldy     #$00
        lda     ($0A),y
        tay
L6F99:  lda     ($0A),y
        cmp     #$2F
        beq     L6FA9
        dey
        bpl     L6F99
        ldy     #$01
L6FA4:  dey
        lda     ($0A),y
        tay
        rts

L6FA9:  cpy     #$01
        beq     L6FA4
        dey
        rts

L6FAF:  stax    $06
        lda     #$80
        bne     L6FBD
L6FB7:  stax    $06
        lda     #$00
L6FBD:  sta     L704A
        bit     L704A
        bpl     L6FCA
        ldy     #$00
        lda     ($06),y
        tay
L6FCA:  sty     path_buffer
L6FCD:  lda     ($06),y
        sta     path_buffer,y
        dey
        bne     L6FCD
        addr_call L87BA, path_buffer
        lda     #$00
        sta     L704B
        sta     L7049
L6FE4:  inc     L7049
        lda     L7049
        cmp     #$09
        bcc     L6FF6
        bit     L704A
        bpl     L6FF5
        lda     #$00
L6FF5:  rts

L6FF6:  jsr     window_lookup
        stax    $06
        ldy     #$0A
        lda     ($06),y
        beq     L6FE4
        lda     L7049
        jsr     window_address_lookup
        stax    $06
        ldy     #$00
        lda     ($06),y
        tay
        cmp     path_buffer
        beq     L7027
        bit     L704A
        bmi     L6FE4
        ldy     path_buffer
        iny
        lda     ($06),y
        cmp     #$2F
        bne     L6FE4
        dey
L7027:  lda     ($06),y
        cmp     path_buffer,y
        bne     L6FE4
        dey
        bne     L7027
        bit     L704A
        bmi     L7045
        ldx     L704B
        lda     L7049
        sta     L704C,x
        inc     L704B
        jmp     L6FE4

L7045:  lda     L7049
        rts

L7049:  .byte   0
L704A:  .byte   0
L704B:  .byte   0
L704C:  .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
L7054:  jmp     L70C5

.proc open_params
param_count:    .byte   3
pathname:       .addr   L705D
io_buffer:      .addr   $800
ref_num:        .byte   0
.endproc

L705D:  .res    64, 0
        .byte   $00

.proc read_params
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   $0C00
request_count:  .word   $200
trans_count:    .word   0
.endproc

.proc close_params
param_count:    .byte   1
ref_num:        .byte   0
.endproc

.proc get_file_info_params4
param_count:    .byte   $A
pathname:       .addr   L705D
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

        .byte   0
L70BB:  .byte   $00
L70BC:  .byte   $00
L70BD:  .byte   $00
L70BE:  .byte   $00
L70BF:  .byte   $00
L70C0:  .byte   $00
L70C1:  .byte   $00
L70C2:  .byte   $00
L70C3:  .byte   $00
L70C4:  .byte   $00
L70C5:  sta     L72A7
        jsr     push_zp_addrs
        ldx     #$40
L70CD:  lda     $E1B0,x
        sta     L705D,x
        dex
        bpl     L70CD
        jsr     L72AA
        lda     open_params::ref_num
        sta     read_params::ref_num
        sta     close_params::ref_num
        jsr     L72CE
        jsr     L72E2
        ldx     #$00
L70EA:  lda     $0C23,x
        sta     L70BF,x
        inx
        cpx     #$04
        bne     L70EA
        sub16  L485D, L485F, L72A8
        ldx     #$05
L710A:  lsr     L72A9
        ror     L72A8
        dex
        cpx     #$00
        bne     L710A
        lda     L70C2
        bne     L7147
        lda     LDD9E
        clc
        adc     L70C1
        bcs     L7147
        cmp     #$7C
        bcs     L7147
        lda     L72A8
        sec
        sbc     DEVCNT
        sta     L72A8
        lda     L72A9
        sbc     #$00
        sta     L72A9
        lda     L72A8
        cmp     L70C1
        lda     L72A9
        sbc     L70C2
        bcs     L7169
L7147:  lda     $EC2E
        jsr     L8B19
        dec     $EC2E
        jsr     redraw_windows_and_desktop
        jsr     L72D8
        lda     active_window_id
        beq     L715F
        lda     #$03
        bne     L7161
L715F:  lda     #warning_msg_window_must_be_closed2
L7161:  jsr     show_warning_dialog_num
        ldx     $E256
        txs
        rts

L7169:  copy16  L485F, $06
        lda     $E1F1
        asl     a
        tax
        copy16  $06, $E202,x
        ldx     $E1F1
        lda     L72A7
        sta     $E1F2,x
        inc     $E1F1
        lda     L70C1
        pha
        lda     LCBANK2
        lda     LCBANK2
        ldy     #$00
        pla
        sta     ($06),y
        lda     LCBANK1
        lda     LCBANK1
        lda     #$FF
        sta     L70C4
        lda     #$00
        sta     L70C3
        copy16  #$0C04, $08
        inc     $06
        lda     $06
        bne     L71BD
        inc     $06+1
L71BD:  inc     L70C4
        lda     L70C4
        cmp     L70C1
        bne     L71CB
        jmp     L7296

L71CB:  inc     L70C3
        lda     L70C3
        cmp     L70C0
        beq     L71E7
        add16_8 $08, L70BF, $08
        jmp     L71F7

L71E7:  lda     #$00
        sta     L70C3
        copy16  #$0C04, $08
        jsr     L72CE
L71F7:  ldx     #$00
        ldy     #$00
        lda     ($08),y
        and     #$0F
        sta     $1F00,x
        bne     L7223
        inc     L70C3
        lda     L70C3
        cmp     L70C0
        bne     L7212
        jmp     L71E7

L7212:  add16_8 $08, L70BF, $08
        jmp     L71F7

L7223:  iny
        inx
L7225:  lda     ($08),y
        sta     $1F00,x
        iny
        inx
        cpx     #$11
        bne     L7225
        ldy     #$13
        lda     ($08),y
        sta     $1F00,x
        inx
        iny
        lda     ($08),y
        sta     $1F00,x
        ldy     #$18
        inx
L7241:  lda     ($08),y
        sta     $1F00,x
        inx
        iny
        cpy     #$1C
        bne     L7241
        ldy     #$21
L724E:  lda     ($08),y
        sta     $1F00,x
        inx
        iny
        cpy     #$25
        bne     L724E
        ldy     #$1E
        lda     ($08),y
        sta     $1F00,x
        inx
        ldy     #$25
        lda     ($08),y
        sta     $1F00,x
        inx
        iny
        lda     ($08),y
        sta     $1F00,x
        lda     LCBANK2
        lda     LCBANK2
        ldx     #$1F
        ldy     #$1F
L7279:  lda     $1F00,x
        sta     ($06),y
        dex
        dey
        bpl     L7279
        lda     LCBANK1
        lda     LCBANK1
        lda     #$20
        clc
        adc     $06
        sta     $06
        bcc     L7293
        inc     $06+1
L7293:  jmp     L71BD

L7296:  copy16  $06, L485F
        jsr     L72D8
        jsr     pop_zp_addrs
        rts
L72A7:  .byte   0
L72A8:  .byte   0
L72A9:  .byte   0

L72AA:  MLI_RELAY_CALL OPEN, open_params
        beq     L72CD
        jsr     DESKTOP_SHOW_ALERT0
        jsr     L8B1F
        lda     selected_window_index
        bne     L72C9
        lda     LE6BE
        sta     L533F
        jsr     L59A8
L72C9:  ldx     $E256
        txs
L72CD:  rts

L72CE:  MLI_RELAY_CALL READ, read_params
        rts

L72D8:  MLI_RELAY_CALL CLOSE, close_params
        rts

L72E2:  lda     $0C04
        and     #$F0
        cmp     #$F0
        beq     L72EC
        rts

L72EC:  MLI_RELAY_CALL GET_FILE_INFO, get_file_info_params4
        beq     L72F8
        rts

L72F8:  copy16  get_file_info_params4::aux_type, L70BD
        sub16  get_file_info_params4::aux_type, get_file_info_params4::blocks_used, L70BB
        sub16  L70BD, L70BB, L70BD
        lsr     L70BC
        ror     L70BB
        php
        lsr     L70BE
        ror     L70BD
        plp
        bcc     L7342
        inc     L70BD
        bne     L7342
        inc     L70BE
L7342:  lda     #$00
        rts

L7345:  sta     L7445
        ldx     #$00
L734A:  lda     $E1F2,x
        cmp     L7445
        beq     L7358
        inx
        cpx     #$08
        bne     L734A
        rts

L7358:  stx     L7446
        dex
L735C:  inx
        lda     $E1F3,x
        sta     $E1F2,x
        cpx     $E1F1
        bne     L735C
        dec     $E1F1
        lda     L7446
        cmp     $E1F1
        bne     L7385
        ldx     L7446
        asl     a
        tax
        lda     $E202,x
        sta     L485F
        lda     $E203,x
        sta     L4860
        rts

L7385:  lda     L7446
        asl     a
        tax
        copy16  $E202,x, $06
        inx
        inx
        copy16  $E202,x, $08
        ldy     #$00
        jsr     push_zp_addrs
L73A5:  lda     LCBANK2
        lda     LCBANK2
        lda     ($08),y
        sta     ($06),y
        lda     LCBANK1
        lda     LCBANK1
        inc     $06
        bne     L73BB
        inc     $06+1
L73BB:  inc     $08
        bne     L73C1
        inc     $08+1
L73C1:  lda     $08+1
        cmp     L4860
        bne     L73A5
        lda     $08
        cmp     L485F
        bne     L73A5
        jsr     pop_zp_addrs
        lda     $E1F1
        asl     a
        tax
        lda     L485F
        sec
        sbc     $E202,x
        sta     L7447
        lda     L4860
        sbc     $E203,x
        sta     L7448
        inc     L7446
L73ED:  lda     L7446
        cmp     $E1F1
        bne     L73F8
        jmp     L7429

L73F8:  lda     L7446
        asl     a
        tax
        lda     $E204,x
        sec
        sbc     $E202,x
        sta     L7449
        lda     $E205,x
        sbc     $E203,x
        sta     L744A
        lda     $E200,x
        clc
        adc     L7449
        sta     $E202,x
        lda     $E201,x
        adc     L744A
        sta     $E203,x
        inc     L7446
        jmp     L73ED

L7429:  lda     $E1F1
        sec
        sbc     #$01
        asl     a
        tax
        lda     $E202,x
        clc
        adc     L7447
        sta     L485F
        lda     $E203,x
        adc     L7448
        sta     L4860
        rts
L7445:  .byte   0
L7446:  .byte   0
L7447:  .byte   0
L7448:  .byte   0
L7449:  .byte   0
L744A:  .byte   0

L744B:  lda     bufnum
        asl     a
        tax
        copy16  $E6BF,x, $08
        ldy     #$09
        lda     ($06),y
        tay
        jsr     push_zp_addrs
        lda     $06
        clc
        adc     #$09
        sta     $06
        bcc     L746D
        inc     $06+1
L746D:  tya
        tax
        ldy     #$00
L7471:  lda     ($06),y
        sta     ($08),y
        iny
        dex
        bne     L7471
        lda     #$20
        sta     ($08),y
        ldy     #$02
        lda     ($08),y
        and     #$DF
        sta     ($08),y
        jsr     pop_zp_addrs
        ldy     #$02
        lda     ($06),y
        and     #$0F
        bne     L74D3
        jsr     push_zp_addrs
        lda     bufnum
        jsr     window_address_lookup
        stax    $08
        lda     $06
        clc
        adc     #$09
        sta     $06
        bcc     L74A8
        inc     $06+1
L74A8:  ldy     #$00
        lda     ($06),y
        tay
L74AD:  lda     ($06),y
        sta     ($08),y
        dey
        bpl     L74AD
        ldy     #$00
        lda     ($08),y
        sec
        sbc     #$01
        sta     ($08),y
        ldy     #$01
        lda     #$2F
        sta     ($08),y
        ldy     #$00
        lda     ($08),y
        tay
L74C8:  lda     ($08),y
        sta     $E1B0,y
        dey
        bpl     L74C8
        jmp     L7569

L74D3:  tay
        lda     #$00
        sta     L7620
        jsr     push_zp_addrs
        tya
        pha
        jsr     window_address_lookup
        stax    $06
        pla
        asl     a
        tax
        copy16  $E6BF,x, $08
        ldy     #$00
        lda     ($06),y
        clc
        adc     ($08),y
        cmp     #$43
        bcc     L750D
        lda     #$40
        jsr     DESKTOP_SHOW_ALERT0
        jsr     L8B1F
        dec     $EC2E
        ldx     $E256
        txs
        rts

L750D:  ldy     #$00
        lda     ($06),y
        tay
L7512:  lda     ($06),y
        sta     $E1B0,y
        dey
        bpl     L7512
        lda     #$2F
        sta     $E1B1
        inc     $E1B0
        ldx     $E1B0
        sta     $E1B0,x
        lda     LE6BE
        jsr     file_address_lookup
        stax    $08
        ldx     $E1B0
        ldy     #$09
        lda     ($08),y
        clc
        adc     $E1B0
        sta     $E1B0
        dec     $E1B0
        dec     $E1B0
        ldy     #$0A
L7548:  iny
        inx
        lda     ($08),y
        sta     $E1B0,x
        cpx     $E1B0
        bne     L7548
        lda     bufnum
        jsr     window_address_lookup
        stax    $08
        ldy     $E1B0
L7561:  lda     $E1B0,y
        sta     ($08),y
        dey
        bpl     L7561
L7569:  ldax    $08
        jsr     L87BA
        lda     bufnum
        jsr     window_lookup
        stax    $06
        ldy     #$14
        lda     bufnum
        sec
        sbc     #$01
        asl     a
        asl     a
        asl     a
        asl     a
        pha
        adc     #$05
        sta     ($06),y
        iny
        lda     #$00
        sta     ($06),y
        iny
        pla
        lsr     a
        clc
        adc     #$1B
        sta     ($06),y
        iny
        lda     #$00
        sta     ($06),y
        lda     #$00
        ldy     #$1F
        ldx     #$03
L75A3:  sta     ($06),y
        dey
        dex
        bpl     L75A3
        ldy     #$04
        lda     ($06),y
        and     #$FE
        sta     ($06),y
        iny
        lda     ($06),y
        and     #$FE
        sta     ($06),y
        lda     #$00
        ldy     #$07
        sta     ($06),y
        ldy     #$09
        sta     ($06),y
        jsr     pop_zp_addrs
        lda     LE6BE
        jsr     L7054
        lda     LE6BE
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        beq     L75FA
        tax
        dex
        txa
        asl     a
        tax
        lda     $EB8B,x
        sta     L70BD
        lda     $EB8C,x
        sta     L70BE
        lda     $EB9B,x
        sta     L70BB
        lda     $EB9C,x
        sta     L70BC
L75FA:  ldx     bufnum
        dex
        txa
        asl     a
        tax
        lda     L70BD
        sta     $EB8B,x
        lda     L70BE
        sta     $EB8C,x
        lda     L70BB
        sta     $EB9B,x
        lda     L70BC
        sta     $EB9C,x
        lda     bufnum
        jsr     L7635
        rts
L7620:  .byte   $00

L7621:  .byte   $00
L7622:  .byte   $00
L7623:  .byte   $00
L7624:  .byte   $00
L7625:  .byte   $00
L7626:  .byte   $34
L7627:  .byte   $00,$10,$00
L762A:  .byte   $00
L762B:  .byte   $00
L762C:  .byte   $00
L762D:  .byte   $00
L762E:  .byte   $05
L762F:  .byte   $00
L7630:  .byte   $00
L7631:  .byte   $00
L7632:  .byte   $00
L7633:  .byte   $00
L7634:  .byte   $00
L7635:  pha
        lda     #$00
        beq     L7647
L763A:  pha
        ldx     bufnum
        dex
        lda     LEC26,x
        sta     LE6BE
        lda     #$80
L7647:  sta     L7634
        pla
        sta     L7621
        jsr     push_zp_addrs
        ldx     #$03
L7653:  lda     L7626,x
        sta     L762A,x
        dex
        bpl     L7653
        lda     #$00
        sta     L762F
        sta     L7625
        ldx     #$03
L7666:  sta     L7630,x
        dex
        bpl     L7666
        lda     LE6BE
        ldx     $E1F1
        dex
L7673:  cmp     $E1F2,x
        beq     L767C
        dex
        bpl     L7673
        rts

L767C:  txa
        asl     a
        tax
        copy16  $E202,x, $06
        lda     LCBANK2
        lda     LCBANK2
        ldy     #$00
        lda     ($06),y
        sta     L7764
        lda     LCBANK1
        lda     LCBANK1
        inc     $06
        lda     $06
        bne     L76A4
        inc     $06+1
L76A4:  lda     bufnum
        sta     active_window_id
L76AA:  lda     L7625
        cmp     L7764
        beq     L76BB
        jsr     L7768
        inc     L7625
        jmp     L76AA

L76BB:  bit     L7634
        bpl     L76C4
        jsr     pop_zp_addrs
        rts

L76C4:  jsr     L7B6B
        lda     L7621
        jsr     window_lookup
        stax    $06
        ldy     #$16
        lda     L7B65
        sec
        sbc     ($06),y
        sta     L7B65
        lda     L7B66
        sbc     #$00
        sta     L7B66
        lda     L7B63
        cmp     #$AA
        lda     L7B64
        sbc     #$00
        bmi     L7705
        lda     L7B63
        cmp     #$C2
        lda     L7B64
        sbc     #$01
        bpl     L770C
        ldax    L7B63
        jmp     L7710

L7705:  lda     #$AA
        ldx     #$00
        jmp     L7710

L770C:  lda     #$C2
        ldx     #$01
L7710:  ldy     #$20
        sta     ($06),y
        txa
        iny
        sta     ($06),y
        lda     L7B65
        cmp     #$32
        lda     L7B66
        sbc     #$00
        bmi     L7739
        lda     L7B65
        cmp     #$6C
        lda     L7B66
        sbc     #$00
        bpl     L7740
        ldax    L7B65
        jmp     L7744

L7739:  lda     #$32
        ldx     #$00
        jmp     L7744

L7740:  lda     #$6C
        ldx     #$00
L7744:  ldy     #$22
        sta     ($06),y
        txa
        iny
        sta     ($06),y
        lda     L7767
        ldy     #$06
        sta     ($06),y
        ldy     #$08
        sta     ($06),y
        lda     LE6BE
        ldx     L7621
        jsr     L8B60
        jsr     pop_zp_addrs
        rts
L7764:  .byte   $00,$00,$00
L7767:  .byte   $14

L7768:  inc     LDD9E
        jsr     DESKTOP_FIND_SPACE
        ldx     buf3len
        inc     buf3len
        sta     buf3,x
        jsr     file_address_lookup
        stax    $08
        lda     LCBANK2
        lda     LCBANK2
        ldy     #$00
        lda     ($06),y
        sta     $1800
        iny
        ldx     #$00
L778E:  lda     ($06),y
        sta     $1802,x
        inx
        iny
        cpx     $1800
        bne     L778E
        inc     $1800
        inc     $1800
        lda     #$20
        sta     $1801
        ldx     $1800
        sta     $1800,x
        ldy     #$10
        lda     ($06),y
        cmp     #$B3
        beq     L77CC
        cmp     #$FF
        bne     L77DA
        ldy     #$00
        lda     ($06),y
        tay
        ldx     L77D0
L77BF:  lda     ($06),y
        cmp     L77D0,x
        bne     L77D8
        dey
        beq     L77D8
        dex
        bne     L77BF
L77CC:  lda     #$01
        bne     L77DA
L77D0:  PASCAL_STRING ".SYSTEM"

L77D8:  lda     #$FF
L77DA:  tay
        lda     LCBANK1
        lda     LCBANK1
        tya
        jsr     L78A1
        addr_call L87BA, $1800
        ldy     #$09
        ldx     #$00
L77F0:  lda     $1800,x
        sta     ($08),y
        iny
        inx
        cpx     $1800
        bne     L77F0
        lda     $1800,x
        sta     ($08),y
        ldx     #$00
        ldy     #$03
L7805:  lda     L762A,x
        sta     ($08),y
        inx
        iny
        cpx     #$04
        bne     L7805
        lda     buf3len
        cmp     L762E
        beq     L781A
        bcs     L7826
L781A:  lda     L762A
        sta     L7630
        lda     L762B
        sta     L7631
L7826:  lda     L762C
        sta     L7632
        lda     L762D
        sta     L7633
        inc     L762F
        lda     L762F
        cmp     L762E
        bne     L7862
        add16 L762C, #$20, L762C
        lda     L7626
        sta     L762A
        lda     L7627
        sta     L762B
        lda     #$00
        sta     L762F
        jmp     L7870

L7862:  lda     L762A
        clc
        adc     #$50
        sta     L762A
        bcc     L7870
        inc     L762B
L7870:  lda     bufnum
        ora     L7624
        ldy     #$02
        sta     ($08),y
        ldy     #$07
        lda     L7622
        sta     ($08),y
        iny
        lda     L7623
        sta     ($08),y
        ldx     buf3len
        dex
        lda     buf3,x
        jsr     L8893
        add16 $06, #$20, $06
        rts

        .byte   0
        .byte   0

L78A1:  sta     L78EE
        jsr     push_zp_addrs
        copy16  type_table_addr, $06
        ldy     #$00
        lda     ($06),y
        tay
L78B6:  lda     ($06),y
        cmp     L78EE
        beq     L78C2
        dey
        bpl     L78B6
        ldy     #$01
L78C2:  copy16  LFB04, $06
        lda     ($06),y
        sta     L7624
        dey
        tya
        asl     a
        tay
        copy16  type_icons_addr, $06
        lda     ($06),y
        sta     L7622
        iny
        lda     ($06),y
        sta     L7623
        jsr     pop_zp_addrs
        rts

L78EE:  .byte   0
L78EF:  lda     grafport2::cliprect::x1
        sta     point1::xcoord           ; Directory header line (items / k in disk)
        clc
        adc     #$05
        sta     items_label_pos
        lda     grafport2::cliprect::x1+1
        sta     point1::xcoord+1
        adc     #$00
        sta     $EBBB
        lda     grafport2::cliprect::y1
        clc
        adc     #$0C
        sta     point1::ycoord
        sta     $EBC4
        lda     grafport2::cliprect::y1+1
        adc     #$00
        sta     point1::ycoord+1
        sta     $EBC5
        MGTK_RELAY_CALL MGTK::MoveTo, point1
        copy16  grafport2::cliprect::x2, point5::xcoord
        jsr     set_penmode_xor
        MGTK_RELAY_CALL MGTK::LineTo, point5
        lda     point1::ycoord
        clc
        adc     #2
        sta     point1::ycoord
        sta     point5::ycoord
        lda     point1::ycoord+1
        adc     #0
        sta     point1::ycoord+1
        sta     point5::ycoord+1
        MGTK_RELAY_CALL MGTK::MoveTo, point1
        MGTK_RELAY_CALL MGTK::LineTo, point5
        add16 grafport2::cliprect::y1, #$0A, items_label_pos+2
        lda     buf3len
        ldx     #$00
        jsr     L7AE0
        lda     buf3len
        cmp     #$02
        bcs     L798A
        dec     str_items       ; remove trailing s
L798A:  MGTK_RELAY_CALL MGTK::MoveTo, items_label_pos
        jsr     L7AD7
        addr_call draw_text2, str_items
        lda     buf3len
        cmp     #$02
        bcs     L79A7
        inc     str_items       ; restore trailing s
L79A7:  jsr     L79F7
        ldx     active_window_id
        dex
        txa
        asl     a
        tax
        lda     $EB8B,x
        tay
        lda     $EB8C,x
        tax
        tya
        jsr     L7AE0
        MGTK_RELAY_CALL MGTK::MoveTo, point2
        jsr     L7AD7
        addr_call draw_text2, str_k_in_disk
        ldx     active_window_id
        dex
        txa
        asl     a
        tax
        lda     $EB9B,x
        tay
        lda     $EB9C,x
        tax
        tya
        jsr     L7AE0
        MGTK_RELAY_CALL MGTK::MoveTo, point3
        jsr     L7AD7
        addr_call draw_text2, str_k_available
        rts

L79F7:  sub16  grafport2::cliprect::x2, grafport2::cliprect::x1, L7ADE
        sub16  L7ADE, $EBF3, L7ADE
        bpl     L7A22
        jmp     L7A86

L7A22:  sub16  L7ADE, $EBF9, L7ADE
        bpl     L7A3A
        jmp     L7A86

L7A3A:  add16 $EBE7, L7ADE, point3::xcoord
        lda     L7ADF
        beq     L7A59
        lda     L7ADE
        cmp     #$18
        bcc     L7A6A
L7A59:  sub16  point3::xcoord, #$0C, point3::xcoord
L7A6A:  lsr     L7ADF
        ror     L7ADE
        add16 LEBE3, L7ADE, point2::xcoord
        jmp     L7A9E

L7A86:  copy16  LEBE3, point2::xcoord
        copy16  $EBE7, point3::xcoord
L7A9E:  lda     point2::xcoord
        clc
        adc     grafport2::cliprect::x1
        sta     point2::xcoord
        lda     point2::xcoord+1
        adc     grafport2::cliprect::x1+1
        sta     point2::xcoord+1
        lda     point3::xcoord
        clc
        adc     grafport2::cliprect::x1
        sta     point3::xcoord
        lda     point3::xcoord+1
        adc     grafport2::cliprect::x1+1
        sta     point3::xcoord+1
        lda     items_label_pos+2
        sta     point2::ycoord
        sta     point3::ycoord
        lda     items_label_pos+3
        sta     point2::ycoord+1
        sta     point3::ycoord+1
        rts

L7AD7:  addr_jump draw_text2, str_6_spaces

L7ADE:  .byte   0
L7ADF:  .byte   0
L7AE0:  stax    L7B5B
        ldx     #$06
        lda     #$20
L7AEA:  sta     str_6_spaces,x
        dex
        bne     L7AEA
        lda     #$00
        sta     L7B5E
        ldy     #$00
        ldx     #$00
L7AF9:  lda     #$00
        sta     L7B5D
L7AFE:  lda     L7B5B
        cmp     L7B53,x
        lda     L7B5C
        sbc     L7B54,x
        bpl     L7B31
        lda     L7B5D
        bne     L7B1A
        bit     L7B5E
        bmi     L7B1A
        lda     #$20
        bne     L7B24
L7B1A:  clc
        adc     #$30
        pha
        lda     #$80
        sta     L7B5E
        pla
L7B24:  sta     str_6_spaces+2,y
        iny
        inx
        inx
        cpx     #$08
        beq     L7B4A
        jmp     L7AF9

L7B31:  inc     L7B5D
        lda     L7B5B
        sec
        sbc     L7B53,x
        sta     L7B5B
        lda     L7B5C
        sbc     L7B54,x
        sta     L7B5C
        jmp     L7AFE

L7B4A:  lda     L7B5B
        ora     #'0'
        sta     str_6_spaces+2,y
        rts

L7B53:  .byte   $10
L7B54:  .byte   $27,$E8,$03,$64,$00,$0A,$00
L7B5B:  .byte   0
L7B5C:  .byte   0
L7B5D:  .byte   0
L7B5E:  .byte   0
L7B5F:  .byte   0
L7B60:  .byte   0
L7B61:  .byte   0
L7B62:  .byte   0
L7B63:  .byte   0
L7B64:  .byte   0
L7B65:  .byte   0
L7B66:  .byte   0
L7B67:  .byte   0
L7B68:  .byte   0
L7B69:  .byte   0
L7B6A:  .byte   0
L7B6B:  ldx     #$03
        lda     #$00
L7B6F:  sta     L7B63,x
        dex
        bpl     L7B6F
        sta     L7D5B
        lda     #$FF
        sta     L7B5F
        sta     L7B61
        lda     #$7F
        sta     L7B60
        sta     L7B62
        ldx     bufnum
        dex
        lda     win_buf_table,x
        bpl     L7BCB
        lda     buf3len
        bne     L7BA1
L7B96:  lda     #$00
        ldx     #$03
L7B9A:  sta     L7B5F,x
        dex
        bpl     L7B9A
        rts

L7BA1:  clc
        adc     #$02
        ldx     #$00
        stx     L7D5C
        asl     a
        rol     L7D5C
        asl     a
        rol     L7D5C
        asl     a
        rol     L7D5C
        sta     L7B65
        lda     L7D5C
        sta     L7B66
        copy16  #$168, L7B63
        jmp     L7B96

L7BCB:  lda     buf3len
        cmp     #$01
        bne     L7BEF
        lda     buf3
        jsr     file_address_lookup
        stax    $06
        ldy     #$06
        ldx     #$03
L7BE0:  lda     ($06),y
        sta     L7B5F,x
        sta     L7B63,x
        dey
        dex
        bpl     L7BE0
        jmp     L7BF7

L7BEF:  lda     L7D5B
        cmp     buf3len
        bne     L7C36
L7BF7:  lda     L7B63
        clc
        adc     #$32
        sta     L7B63
        bcc     L7C05
        inc     L7B64
L7C05:  lda     L7B65
        clc
        adc     #$20
        sta     L7B65
        bcc     L7C13
        inc     L7B66
L7C13:  sub16  L7B5F, #$32, L7B5F
        sub16  L7B61, #$0F, L7B61
        rts

L7C36:  tax
        lda     buf3,x
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$0F
        cmp     L7D5C
        bne     L7C52
        inc     L7D5B
        jmp     L7BEF

L7C52:  ldy     #$06
        ldx     #$03
L7C56:  lda     ($06),y
        sta     L7B67,x
        dey
        dex
        bpl     L7C56
        bit     L7B60
        bmi     L7C88
        bit     L7B68
        bmi     L7CCE
        lda     L7B67
        cmp     L7B5F
        lda     L7B68
        sbc     L7B60
        bmi     L7CCE
        lda     L7B67
        cmp     L7B63
        lda     L7B68
        sbc     L7B64
        bpl     L7CBF
        jmp     L7CDA

L7C88:  bit     L7B68
        bmi     L7CA3
        bit     L7B64
        bmi     L7CDA
        lda     L7B67
        cmp     L7B63
        lda     L7B68
        sbc     L7B64
        bmi     L7CDA
        jmp     L7CBF

L7CA3:  lda     L7B67
        cmp     L7B5F
        lda     L7B68
        sbc     L7B60
        bmi     L7CCE
        lda     L7B67
        cmp     L7B63
        lda     L7B68
        sbc     L7B64
        bmi     L7CDA
L7CBF:  lda     L7B67
        sta     L7B63
        lda     L7B68
        sta     L7B64
        jmp     L7CDA

L7CCE:  lda     L7B67
        sta     L7B5F
        lda     L7B68
        sta     L7B60
L7CDA:  bit     L7B62
        bmi     L7D03
        bit     L7B6A
        bmi     L7D49
        lda     L7B69
        cmp     L7B61
        lda     L7B6A
        sbc     L7B62
        bmi     L7D49
        lda     L7B69
        cmp     L7B65
        lda     L7B6A
        sbc     L7B66
        bpl     L7D3A
        jmp     L7D55

L7D03:  bit     L7B6A
        bmi     L7D1E
        bit     L7B66
        bmi     L7D55
        lda     L7B69
        cmp     L7B65
        lda     L7B6A
        sbc     L7B66
        bmi     L7D55
        jmp     L7D3A

L7D1E:  lda     L7B69
        cmp     L7B61
        lda     L7B6A
        sbc     L7B62
        bmi     L7D49
        lda     L7B69
        cmp     L7B65
        lda     L7B6A
        sbc     L7B66
        bmi     L7D55
L7D3A:  lda     L7B69
        sta     L7B65
        lda     L7B6A
        sta     L7B66
        jmp     L7D55

L7D49:  lda     L7B69
        sta     L7B61
        lda     L7B6A
        sta     L7B62
L7D55:  inc     L7D5B
        jmp     L7BEF

L7D5B:  .byte   0
L7D5C:  .byte   0
L7D5D:  jsr     window_lookup
        stax    $06
        ldy     #$23
        ldx     #$07
L7D68:  lda     ($06),y
        sta     L7D94,x
        dey
        dex
        bpl     L7D68
        lda     L7D98
        sec
        sbc     L7D94
        pha
        lda     L7D99
        sbc     L7D95
        pha
        lda     L7D9A
        sec
        sbc     L7D96
        pha
        lda     L7D9B
        sbc     L7D97
        pla
        tay
        pla
        tax
        pla
        rts

L7D94:  .byte   0
L7D95:  .byte   0
L7D96:  .byte   0
L7D97:  .byte   0
L7D98:  .byte   0
L7D99:  .byte   0
L7D9A:  .byte   0
L7D9B:  .byte   0
L7D9C:  jmp     L7D9F

L7D9F:  ldx     bufnum
        dex
        lda     LEC26,x
        ldx     #$00
L7DA8:  cmp     $E1F2,x
        beq     L7DB4
        inx
        cpx     $E1F1
        bne     L7DA8
        rts

L7DB4:  txa
        asl     a
        tax
        lda     $E202,x
        sta     $06
        sta     $0801
        lda     $E203,x
        sta     $06+1
        sta     $0802
        lda     LCBANK2
        lda     LCBANK2
        lda     #$00
        sta     L0800
        tay
        lda     ($06),y
        sta     $0803
        inc     $06
        inc     $0801
        bne     L7DE4
        inc     $06+1
        inc     $0802
L7DE4:  lda     L0800
        cmp     $0803
        beq     L7E0C
        jsr     L80CA
        ldy     #$00
        lda     ($06),y
        and     #$7F
        sta     ($06),y
        ldy     #$17
        lda     ($06),y
        bne     L7E06
        iny
        lda     ($06),y
        bne     L7E06
        lda     #$01
        sta     ($06),y
L7E06:  inc     L0800
        jmp     L7DE4

L7E0C:  lda     LCBANK1
        lda     LCBANK1
        ldx     bufnum
        dex
        lda     win_buf_table,x
        cmp     #$81
        beq     L7E20
        jmp     L7EC1

L7E20:  lda     LCBANK2
        lda     LCBANK2
        lda     #$5A
        ldx     #$0F
L7E2A:  sta     $0808,x
        dex
        bpl     L7E2A
        lda     #$00
        sta     $0805
        sta     L0800
L7E38:  lda     $0805
        cmp     $0803
        bne     L7E43
        jmp     L80F5

L7E43:  jsr     L80CA
        ldy     #$00
        lda     ($06),y
        bmi     L7E82
        and     #$0F
        sta     $0804
        ldy     #$01
L7E53:  lda     ($06),y
        cmp     $0807,y
        beq     L7E5F
        bcs     L7E82
        jmp     L7E67

L7E5F:  iny
        cpy     #$10
        bne     L7E53
        jmp     L7E82

L7E67:  lda     L0800
        sta     $0806
        ldx     #$0F
        lda     #$20
L7E71:  sta     $0808,x
        dex
        bpl     L7E71
        ldy     $0804
L7E7A:  lda     ($06),y
        sta     $0807,y
        dey
        bne     L7E7A
L7E82:  inc     L0800
        lda     L0800
        cmp     $0803
        beq     L7E90
        jmp     L7E43

L7E90:  inc     $0805
        lda     $0806
        sta     L0800
        jsr     L80CA
        ldy     #$00
        lda     ($06),y
        ora     #$80
        sta     ($06),y
        lda     #$5A
        ldx     #$0F
L7EA8:  sta     $0808,x
        dex
        bpl     L7EA8
        ldx     $0805
        dex
        ldy     $0806
        iny
        jsr     L812B
        lda     #$00
        sta     L0800
        jmp     L7E38

L7EC1:  cmp     #$82
        beq     L7EC8
        jmp     L7F58

L7EC8:  lda     LCBANK2
        lda     LCBANK2
        lda     #$00
        sta     $0808
        sta     $0809
        sta     $0805
        sta     L0800
L7EDC:  lda     $0805
        cmp     $0803
        bne     L7EE7
        jmp     L80F5

L7EE7:  jsr     L80CA
        ldy     #$00
        lda     ($06),y
        bmi     L7F1B
        ldy     #$18
        lda     ($06),y
        cmp     $0809
        beq     L7EFE
        bcs     L7F08
        jmp     L7F1B

L7EFE:  dey
        lda     ($06),y
        cmp     $0808
        beq     L7F1B
        bcc     L7F1B
L7F08:  ldy     #$18
        lda     ($06),y
        sta     $0809
        dey
        lda     ($06),y
        sta     $0808
        lda     L0800
        sta     $0806
L7F1B:  inc     L0800
        lda     L0800
        cmp     $0803
        beq     L7F29
        jmp     L7EE7

L7F29:  inc     $0805
        lda     $0806
        sta     L0800
        jsr     L80CA
        ldy     #$00
        lda     ($06),y
        ora     #$80
        sta     ($06),y
        lda     #$00
        sta     $0808
        sta     $0809
        ldx     $0805
        dex
        ldy     $0806
        iny
        jsr     L812B
        lda     #$00
        sta     L0800
        jmp     L7EDC

L7F58:  cmp     #$83
        beq     L7F5F
        jmp     L801F

L7F5F:  lda     LCBANK2
        lda     LCBANK2
        lda     #$00
        sta     $0808
        sta     $0809
        sta     $0805
        sta     L0800
L7F73:  lda     $0805
        cmp     $0803
        bne     L7F7E
        jmp     L80F5

L7F7E:  jsr     L80CA
        ldy     #$00
        lda     ($06),y
        bmi     L7FAD
        ldy     #$12
        lda     ($06),y
        cmp     $0809
        beq     L7F92
        bcs     L7F9C
L7F92:  dey
        lda     ($06),y
        cmp     $0808
        beq     L7F9C
        bcc     L7FAD
L7F9C:  lda     ($06),y
        sta     $0808
        iny
        lda     ($06),y
        sta     $0809
        lda     L0800
        sta     $0806
L7FAD:  inc     L0800
        lda     L0800
        cmp     $0803
        beq     L7FBB
        jmp     L7F7E

L7FBB:  inc     $0805
        lda     $0806
        sta     L0800
        jsr     L80CA
        ldy     #$00
        lda     ($06),y
        ora     #$80
        sta     ($06),y
        lda     #$00
        sta     $0808
        sta     $0809
        ldx     $0805
        dex
        ldy     $0806
        iny
        jsr     L812B
        lda     #$00
        sta     L0800
        jmp     L7F73

        lda     LCBANK1
        lda     LCBANK1
        copy16  #$54, point9::xcoord
        copy16  #$CB, pointA::xcoord
        lda     #$00
        sta     pointB::xcoord
        sta     pointB::xcoord+1
        copy16  #$E7, pointC::xcoord
        lda     LCBANK2
        lda     LCBANK2
        jmp     L80F5

L801F:  cmp     #$84
        beq     L8024
        rts

L8024:  copy16  type_table_addr, $08
        ldy     #$00
        lda     ($08),y
        sta     $0807
        tay
L8036:  lda     ($08),y
        sta     $0807,y
        dey
        bne     L8036
        lda     LCBANK2
        lda     LCBANK2
        lda     #$00
        sta     $0805
        sta     L0800
        lda     #$FF
        sta     $0806
L8051:  lda     $0805
        cmp     $0803
        bne     L805C
        jmp     L80F5

L805C:  jsr     L80CA
        ldy     #$00
        lda     ($06),y
        bmi     L807E
        ldy     #$10
        lda     ($06),y
        ldx     $0807
        cpx     #$00
        beq     L8075
        cmp     $0808,x
        bne     L807E
L8075:  lda     L0800
        sta     $0806
        jmp     L809E

L807E:  inc     L0800
        lda     L0800
        cmp     $0803
        beq     L808C
        jmp     L805C

L808C:  lda     $0806
        cmp     #$FF
        bne     L809E
        dec     $0807
        lda     #$00
        sta     L0800
        jmp     L805C

L809E:  inc     $0805
        lda     $0806
        sta     L0800
        jsr     L80CA
        ldy     #$00
        lda     ($06),y
        ora     #$80
        sta     ($06),y
        ldx     $0805
        dex
        ldy     $0806
        iny
        jsr     L812B
        lda     #$00
        sta     L0800
        lda     #$FF
        sta     $0806
        jmp     L8051

L80CA:  lda     #$00
        sta     $0804
        lda     L0800
        asl     a
        rol     $0804
        asl     a
        rol     $0804
        asl     a
        rol     $0804
        asl     a
        rol     $0804
        asl     a
        rol     $0804
        clc
        adc     $0801
        sta     $06
        lda     $0802
        adc     $0804
        sta     $06+1
        rts

L80F5:  lda     #$00
        sta     L0800
L80FA:  lda     L0800
        cmp     $0803
        beq     L8124
        jsr     L80CA
        ldy     #$00
        lda     ($06),y
        and     #$7F
        sta     ($06),y
        ldy     #$17
        lda     ($06),y
        bne     L811E
        iny
        lda     ($06),y
        cmp     #$01
        bne     L811E
        lda     #$00
        sta     ($06),y
L811E:  inc     L0800
        jmp     L80FA

L8124:  lda     LCBANK1
        lda     LCBANK1
        rts

L812B:  lda     LCBANK1
        lda     LCBANK1
        tya
        sta     buf3,x
        lda     LCBANK2
        lda     LCBANK2
        rts

L813C:  .byte   0
        .byte   0
L813E:  php
L813F:  ldy     #$00
        tax
        dex
        txa
        sty     L813C
        asl     a
        rol     L813C
        asl     a
        rol     L813C
        asl     a
        rol     L813C
        asl     a
        rol     L813C
        asl     a
        rol     L813C
        clc
        adc     $E71D
        sta     $06
        lda     $E71E
        adc     L813C
        sta     $06+1
        lda     LCBANK2
        lda     LCBANK2
        ldy     #$1F
L8171:  lda     ($06),y
        sta     $EC43,y
        dey
        bpl     L8171
        lda     LCBANK1
        lda     LCBANK1
        ldx     #$31
        lda     #$20
L8183:  sta     text_buffer2::data-1,x
        dex
        bpl     L8183
        lda     #$00
        sta     text_buffer2::length
        lda     pointA::ycoord
        clc
        adc     L813E
        sta     pointA::ycoord
        bcc     L819D
        inc     pointA::ycoord+1
L819D:  lda     pointB::ycoord
        clc
        adc     L813E
        sta     pointB::ycoord
        bcc     L81AC
        inc     pointB::ycoord+1
L81AC:  lda     pointC::ycoord
        clc
        adc     L813E
        sta     pointC::ycoord
        bcc     L81BB
        inc     pointC::ycoord+1
L81BB:  lda     point9::ycoord
        cmp     grafport2::cliprect::y2
        lda     point9::ycoord+1
        sbc     grafport2::cliprect::y2+1
        bmi     L81D9
        lda     point9::ycoord
        clc
        adc     L813E
        sta     point9::ycoord
        bcc     L81D8
        inc     point9::ycoord+1
L81D8:  rts

L81D9:  lda     point9::ycoord
        clc
        adc     L813E
        sta     point9::ycoord
        bcc     L81E8
        inc     point9::ycoord+1
L81E8:  lda     point9::ycoord
        cmp     grafport2::cliprect::y1
        lda     point9::ycoord+1
        sbc     grafport2::cliprect::y1+1
        bpl     L81F7
        rts

L81F7:  jsr     L821F
        addr_call SETPOS_RELAY, point9
        jsr     L8241
        addr_call SETPOS_RELAY, pointA
        jsr     L8253
        addr_call SETPOS_RELAY, pointB
        jsr     compose_date_string
        addr_jump SETPOS_RELAY, pointC

L821F:  lda     $EC43
        and     #$0F
        sta     text_buffer2::length
        tax
L8228:  lda     $EC43,x
        sta     $E6EC,x
        dex
        bne     L8228
        lda     #$20
        sta     $E6EC
        inc     text_buffer2::length
        addr_call L87BA, $E6EB
        rts

L8241:  lda     $EC53
        jsr     L8707
        ldx     #$04
L8249:  lda     LDFC5,x
        sta     text_buffer2::data-1,x
        dex
        bpl     L8249
        rts

L8253:  ldax    $EC54
L8259:  stax    L8272
        jmp     L8276

L8262:  .byte   $20
        .byte   "Blocks "
L826A:  .byte   $10             ; ???
L826B:  .byte   $27,$E8
        .byte   $03,$64,$00,$0A,$00
L8272:  .byte   0
L8273:  .byte   0
L8274:  .byte   0
L8275:  .byte   0

L8276:  ldx     #$11
        lda     #' '
L827A:  sta     text_buffer2::data-1,x
        dex
        bpl     L827A
        lda     #$00
        sta     text_buffer2::length
        sta     L8275
        ldy     #$00
        ldx     #$00
L828C:  lda     #$00
        sta     L8274
L8291:  lda     L8272
        cmp     L826A,x
        lda     L8273
        sbc     L826B,x
        bpl     L82C3
        lda     L8274
        bne     L82AD
        bit     L8275
        bmi     L82AD
        lda     #$20
        bne     L82B6
L82AD:  ora     #$30
        pha
        lda     #$80
        sta     L8275
        pla
L82B6:  sta     $E6ED,y
        iny
        inx
        inx
        cpx     #$08
        beq     L82DC
        jmp     L828C

L82C3:  inc     L8274
        lda     L8272
        sec
        sbc     L826A,x
        sta     L8272
        lda     L8273
        sbc     L826B,x
        sta     L8273
        jmp     L8291

L82DC:  lda     L8272
        ora     #$30
        sta     $E6ED,y
        iny
        ldx     #$00
L82E7:  lda     L8262,x
        sta     $E6ED,y
        iny
        inx
        cpx     L8262
        bne     L82E7
        lda     L8274
        bne     L8305
        bit     L8275
        bmi     L8305
        lda     L8272
        cmp     #$02
        bcc     L8309
L8305:  lda     #$0D
        bne     L830B
L8309:  lda     #$0C
L830B:  sta     text_buffer2::length
        rts

;;; ==================================================

compose_date_string:
        ldx     #21
        lda     #' '
:       sta     text_buffer2::data-1,x
        dex
        bpl     :-
        lda     #1
        sta     text_buffer2::length
        copy16  #text_buffer2::length, $8
        lda     date            ; any bits set?
        ora     date+1
        bne     prep_date_strings
        sta     month           ; 0 is "no date" string
        jmp     prep_month_string

prep_date_strings:
        lda     date+1
        and     #$FE            ; extract year
        lsr     a
        sta     year
        lda     date+1          ; extract month
        ror     a
        lda     date
        ror     a
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        sta     month
        lda     date            ; extract day
        and     #$1F
        sta     day

        jsr     prep_month_string
        jsr     prep_day_string
        jmp     prep_year_string

.proc prep_day_string
        ;; String will have trailing space.
        lda     #' '
        sta     str_day+1
        sta     str_day+2
        sta     str_day+3

        ;; Assume 1 digit (plus trailing space)
        ldx     #2

        ;; Determine first digit.
        lda     day
        ora     #'0'            ; if < 10, will just be value itself
        tay

        lda     day
        cmp     #10
        bcc     :+
        inx                     ; will be 2 digits
        ldy     #'1'
        cmp     #20
        bcc     :+
        ldy     #'2'
        cmp     #30
        bcc     :+
        ldy     #'3'
:       stx     str_day    ; length (including trailing space)
        sty     str_day+1  ; first digit

        ;; Determine second digit.
        cpx     #2              ; only 1 digit (plus trailing space?)
        beq     done

        tya
        and     #$03            ; ascii -> tens digit
        tay

        lda     day             ; subtract 10 as needed
:       sec
        sbc     #10
        dey
        bne     :-

        ora     #'0'
        sta     str_day+2
done:   addr_jump concatenate_date_part, str_day
.endproc

.proc prep_month_string
        lda     month
        asl     a
        tay
        lda     month_table+1,y
        tax
        lda     month_table,y
        jmp     concatenate_date_part
.endproc

.proc prep_year_string
        ldx     tens_table_length
:       lda     year
        sec
        sbc     tens_table-1,x
        bpl     :+
        dex
        bne     :-
:       tay
        lda     ascii_digits,x
        sta     year_string_10s
        lda     ascii_digits,y
        sta     year_string_1s
        addr_jump concatenate_date_part, str_year
.endproc

year:   .byte   0
month:  .byte   0
day:    .byte   0

str_day:                        ; Filled in with day of the month plus space (e.g. "10 ")
        PASCAL_STRING "   "

month_table:
        .addr   str_no_date
        .addr   str_jan,str_feb,str_mar,str_apr,str_may,str_jun
        .addr   str_jul,str_aug,str_sep,str_oct,str_nov,str_dec

str_no_date:
        PASCAL_STRING "no date  "

str_jan:PASCAL_STRING "January   "
str_feb:PASCAL_STRING "February  "
str_mar:PASCAL_STRING "March     "
str_apr:PASCAL_STRING "April     "
str_may:PASCAL_STRING "May       "
str_jun:PASCAL_STRING "June      "
str_jul:PASCAL_STRING "July      "
str_aug:PASCAL_STRING "August    "
str_sep:PASCAL_STRING "September "
str_oct:PASCAL_STRING "October   "
str_nov:PASCAL_STRING "November  "
str_dec:PASCAL_STRING "December  "

str_year:
        PASCAL_STRING " 1985"

year_string_10s := *-2          ; 10s digit
year_string_1s  := *-1          ; 1s digit

tens_table_length:
        .byte   9
tens_table:
        .byte   10,20,30,40,50,60,70,80,90

ascii_digits:
        .byte   "0123456789"

.proc concatenate_date_part
        stax    $06
        ldy     #$00
        lda     ($08),y
        sta     L84D0
        clc
        adc     ($06),y
        sta     ($08),y
        lda     ($06),y
        sta     compare_y
:       inc     L84D0
        iny
        lda     ($06),y
        sty     L84CF
        ldy     L84D0
        sta     ($08),y
        ldy     L84CF
        compare_y := *+1
        cpy     #0              ; self-modified
        bcc     :-
        rts

L84CF:  .byte   0
L84D0:  .byte   0
.endproc

;;; ==================================================


L84D1:  jsr     push_zp_addrs
        bit     L5B1B
        bmi     L84DC
        jsr     L6E52
L84DC:  sub16  grafport2::cliprect::x2, grafport2::cliprect::x1, L85F8
        sub16  grafport2::cliprect::y2, grafport2::cliprect::y1, L85FA
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_down
        bne     L850C
        asl     a
        bne     L850E
L850C:  lda     #$00
L850E:  sta     L85F1
        lda     active_window_id
        jsr     window_lookup
        stax    $06
        lda     #$06
        clc
        adc     L85F1
        tay
        lda     ($06),y
        pha
        jsr     L7B6B
        ldx     L85F1
        lda     L7B63,x
        sec
        sbc     L7B5F,x
        sta     L85F2
        lda     L7B64,x
        sbc     L7B60,x
        sta     L85F3
        ldx     L85F1
        lda     L85F2
        sec
        sbc     L85F8,x
        sta     L85F2
        lda     L85F3
        sbc     L85F9,x
        sta     L85F3
        bpl     L8562
        lda     L85F8,x
        sta     L85F2
        lda     L85F9,x
        sta     L85F3
L8562:  lsr     L85F3
        ror     L85F2
        lsr     L85F3
        ror     L85F2
        lda     L85F2
        tay
        pla
        tax
        lda     event_params+1
        jsr     L62BC
        ldx     #$00
        stx     L85F2
        asl     a
        rol     L85F2
        asl     a
        rol     L85F2
        ldx     L85F1
        clc
        adc     L7B5F,x
        sta     grafport2::cliprect::x1,x
        lda     L85F2
        adc     L7B60,x
        sta     grafport2::cliprect::x1+1,x
        lda     active_window_id
        jsr     L7D5D
        stax    L85F4
        sty     L85F6
        lda     L85F1
        beq     L85C3
        add16_8 grafport2::cliprect::y1, L85F6, grafport2::cliprect::y2
        jmp     L85D6

L85C3:  add16 grafport2::cliprect::x1, L85F4, grafport2::cliprect::x2
L85D6:  lda     active_window_id
        jsr     window_lookup
        stax    $06
        ldy     #$23
        ldx     #$07
L85E4:  lda     grafport2::cliprect::x1,x
        sta     ($06),y
        dey
        dex
        bpl     L85E4
        jsr     pop_zp_addrs
        rts

L85F1:  .byte   0
L85F2:  .byte   0
L85F3:  .byte   0
L85F4:  .word   0
L85F6:  .byte   0
        .byte   0
L85F8:  .byte   0
L85F9:  .byte   0
L85FA:  .word   0

;;; ==================================================
;;; Double Click Detection
;;; Returns with A=0 if double click, A=$FF otherwise.

.proc detect_double_click

        double_click_deltax := 8
        double_click_deltay := 7

        ;; Stash initial coords
        ldx     #3
:       lda     event_params_coords,x
        sta     coords,x
        sta     $EBFD,x
        dex
        bpl     :-

        lda     #0
        sta     counter+1
        lda     machine_type ; Speed of mouse driver? ($96=IIe,$FA=IIc,$FD=IIgs)
        asl     a            ; * 2
        rol     counter+1    ; So IIe = $12C, IIc = $1F4, IIgs = $1FA
        sta     counter

        ;; Decrement counter, bail if time delta exceeded
loop:   dec     counter
        bne     :+
        dec     counter+1
        lda     counter+1
        bne     exit
:       jsr     peek_event

        ;; Check coords, bail if pixel delta exceeded
        jsr     check_delta
        bmi     exit            ; moved past delta; no double-click

        lda     #$FF            ; ???
        sta     unused

        lda     event_params_kind
        sta     state           ; unused ???

        cmp     #MGTK::event_kind_no_event
        beq     loop
        cmp     #MGTK::event_kind_drag
        beq     loop
        cmp     #MGTK::event_kind_button_up
        bne     :+
        jsr     get_event
        jmp     loop
:       cmp     #MGTK::event_kind_button_down
        bne     exit

        jsr     get_event
        lda     #$00            ; double-click
        rts

exit:   lda     #$FF            ; not double-click
        rts

        ;; Is the new coord within range of the old coord?
.proc check_delta
        ;; compute x delta
        lda     event_params_xcoord
        sec
        sbc     xcoord
        sta     delta
        lda     event_params_xcoord+1
        sbc     xcoord+1
        bpl     :+

        ;; is -delta < x < 0 ?
        lda     delta
        cmp     #($100 - double_click_deltax)
        bcs     check_y
fail:   lda     #$FF
        rts

        ;; is 0 < x < delta ?
:       lda     delta
        cmp     #double_click_deltax
        bcs     fail

        ;; compute y delta
check_y:lda     event_params_ycoord
        sec
        sbc     ycoord
        sta     delta
        lda     event_params_ycoord+1
        sbc     ycoord+1
        bpl     :+

        ;; is -delta < y < 0 ?
        lda     delta
        cmp     #($100 - double_click_deltay)
        bcs     ok

        ;; is 0 < y < delta ?
:       lda     delta
        cmp     #double_click_deltay
        bcs     fail
ok:     lda     #$00
        rts
.endproc

counter:.word   0

coords:
xcoord: .word   0
ycoord: .word   0

delta:  .byte   0
state:  .byte   0               ; unused?
unused: .byte   0               ; ???

.endproc

;;; ==================================================
;;; A = A * 4, high bits into X

.proc a_times_4
        ldx     #0
        stx     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        ldx     tmp
        rts

tmp:    .byte   0
.endproc

;;; ==================================================
;;; A = A * 6, high bits into X

.proc a_times_6
        ldx     #$00
        stx     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        asl     a
        rol     tmp
        ldx     tmp
        rts

tmp:    .byte   0
.endproc

;;; ==================================================
;;; Look up file address. Index in A, address in A,X.

file_address_lookup:
        asl     a
        tax
        lda     file_address_table,x
        pha
        lda     file_address_table+1,x
        tax
        pla
        rts

;;; ==================================================
;;; Look up window. Index in A, address in A,X.

window_lookup:
        asl     a
        tax
        lda     win_table,x
        pha
        lda     win_table+1,x
        tax
        pla
        rts

;;; ==================================================
;;; Look up window address. Index in A, address in A,X.

window_address_lookup:
        asl     a
        tax
        lda     window_address_table,x
        pha
        lda     window_address_table+1,x
        tax
        pla
        rts

;;; ==================================================

L8707:  sta     L877F
        copy16  type_table_addr, $06
        ldy     #$00
        lda     ($06),y
        tay
L8719:  lda     ($06),y
        cmp     L877F
        beq     L8726
        dey
        bne     L8719
        jmp     L8745

L8726:  tya
        asl     a
        asl     a
        tay
        copy16  type_names_addr, $06
        ldx     #$00
L8736:  lda     ($06),y
        sta     LDFC6,x
        iny
        inx
        cpx     #$04
        bne     L8736
        stx     LDFC5
        rts

L8745:  lda     #$04
        sta     LDFC5
        lda     #$20
        sta     LDFC6
        lda     #$24
        sta     LDFC7
        lda     L877F
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        cmp     #$0A
        bcs     L8764
        clc
        adc     #$30
        bne     L8767
L8764:  clc
        adc     #$37
L8767:  sta     LDFC8
        lda     L877F
        and     #$0F
        cmp     #$0A
        bcs     L8778
        clc
        adc     #$30
        bne     L877B
L8778:  clc
        adc     #$37
L877B:  sta     LDFC9
        rts
L877F:  .byte   0

;;; ==================================================
;;; Draw text, pascal string address in A,X
.proc draw_text2
        params := $6
        textptr := $6
        textlen := $8

        stax    textptr
        ldy     #0
        lda     (textptr),y
        beq     exit
        sta     textlen
        inc     textptr
        bne     :+
        inc     textptr+1
:       MGTK_RELAY_CALL MGTK::DrawText, params
exit:   rts
.endproc

;;; ==================================================
;;; Measure text, pascal string address in A,X; result in A,X

.proc measure_text1
        ptr := $6
        len := $8
        result := $9

        stax    ptr
        ldy     #0
        lda     (ptr),y
        sta     len
        inc     ptr
        bne     :+
        inc     ptr+1
:       MGTK_RELAY_CALL MGTK::TextWidth, ptr
        ldax    result
        rts
.endproc

;;; ==================================================

L87BA:  stx     $0B
        sta     $0A
        ldy     #$00
        lda     ($0A),y
        tay
        bne     L87C6
        rts

L87C6:  dey
        beq     L87CB
        bpl     L87CC
L87CB:  rts

L87CC:  lda     ($0A),y
        and     #$7F
        cmp     #$2F
        beq     L87DC
        cmp     #$20
        beq     L87DC
        cmp     #$2E
        bne     L87E0
L87DC:  dey
        jmp     L87C6

L87E0:  iny
        lda     ($0A),y
        and     #$7F
        cmp     #$41
        bcc     L87F2
        cmp     #$5B
        bcs     L87F2
        clc
        adc     #$20
        sta     ($0A),y
L87F2:  dey
        jmp     L87C6

;;; ==================================================
;;; Pushes two words from $6/$8 to stack

.proc push_zp_addrs
        ptr := $6

        pla                     ; stash return address
        sta     addr
        pla
        sta     addr+1

        ldx     #0              ; copy 4 bytes from $8 to stack
loop:   lda     ptr,x
        pha
        inx
        cpx     #4
        bne     loop

        lda     addr+1           ; restore return address
        pha
        lda     addr
        pha
        rts

addr:   .addr   0
.endproc

;;; ==================================================
;;; Pops two words from stack to $6/$8

.proc pop_zp_addrs
        ptr := $6

        pla                     ; stash return address
        sta     addr
        pla
        sta     addr+1

        ldx     #3              ; copy 4 bytes from stack to $6
loop:   pla
        sta     ptr,x
        dex
        cpx     #$FF            ; why not bpl ???
        bne     loop

        lda     addr+1          ; restore return address to stack
        pha
        lda     addr
        pha
        rts

addr:   .addr   0
.endproc

;;; ==================================================

L8830:  .byte   0
L8831:  .byte   0
L8832:  .byte   0
L8833:  .res    34, 0

L8855:  tay
        jsr     push_zp_addrs
        tya
        jsr     window_lookup
        stax    $06
        ldx     #$00
        ldy     #$14
L8865:  lda     ($06),y
        sta     L8830,x
        iny
        inx
        cpx     #$24
        bne     L8865
        jsr     pop_zp_addrs
        rts

L8874:  tay
        jsr     push_zp_addrs
        tya
        jsr     window_lookup
        stax    $06
        ldx     #$00
        ldy     #$14
L8884:  lda     L8830,x
        sta     ($06),y
        iny
        inx
        cpx     #$24
        bne     L8884
        jsr     pop_zp_addrs
        rts

L8893:  tay
        jsr     push_zp_addrs
        tya
        jsr     file_address_lookup
        stax    $06
        lda     active_window_id
        jsr     window_lookup
        stax    $08
        ldy     #$17
        ldx     #$03
L88AD:  lda     ($08),y
        sta     L890D,x
        dey
        dex
        bpl     L88AD
        ldy     #$1F
        ldx     #$03
L88BA:  lda     ($08),y
        sta     L8911,x
        dey
        dex
        bpl     L88BA
        ldy     #$03
        lda     ($06),y
        clc
        adc     L890D
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L890E
        sta     ($06),y
        iny
        lda     ($06),y
        clc
        adc     L890F
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L8910
        sta     ($06),y
        ldy     #$03
        lda     ($06),y
        sec
        sbc     L8911
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     L8912
        sta     ($06),y
        iny
        lda     ($06),y
        sec
        sbc     L8913
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     L8914
        sta     ($06),y
        jsr     pop_zp_addrs
        rts

L890D:  .byte   0
L890E:  .byte   0
L890F:  .byte   0
L8910:  .byte   0
L8911:  .byte   0
L8912:  .byte   0
L8913:  .byte   0
L8914:  .byte   0

;;; ==================================================

L8915:  tay
        jsr     push_zp_addrs
        tya
        jsr     file_address_lookup
        stax    $06
L8921:  lda     active_window_id
        jsr     window_lookup
        stax    $08
        ldy     #$17
        ldx     #$03
L892F:  lda     ($08),y
        sta     L898F,x
        dey
        dex
        bpl     L892F
        ldy     #$1F
        ldx     #$03
L893C:  lda     ($08),y
        sta     L8993,x
        dey
        dex
        bpl     L893C
        ldy     #$03
        lda     ($06),y
        sec
        sbc     L898F
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     L8990
        sta     ($06),y
        iny
        lda     ($06),y
        sec
        sbc     L8991
        sta     ($06),y
        iny
        lda     ($06),y
        sbc     L8992
        sta     ($06),y
        ldy     #$03
        lda     ($06),y
        clc
        adc     L8993
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L8994
        sta     ($06),y
        iny
        lda     ($06),y
        clc
        adc     L8995
        sta     ($06),y
        iny
        lda     ($06),y
        adc     L8996
        sta     ($06),y
        jsr     pop_zp_addrs
        rts

L898F:  .byte   0
L8990:  .byte   0
L8991:  .byte   0
L8992:  .byte   0
L8993:  .byte   0
L8994:  .byte   0
L8995:  .byte   0
L8996:  .byte   0

;;; ==================================================

L8997:  lda     #$00
        tax
L899A:  sta     grafport5::cliprect::x1,x
        sta     grafport5::viewloc::xcoord,x
        sta     grafport5::cliprect::x2,x
        inx
        cpx     #$04
        bne     L899A
        MGTK_RELAY_CALL MGTK::SetPort, grafport5
        rts

;;; ==================================================

.proc on_line_params
param_count:    .byte   2
unit_num:       .byte   0
data_buffer:    .addr   $800
.endproc

.proc get_device_info
        sta     unit_number
        sty     device_num
        and     #$F0
        sta     on_line_params::unit_num
        MLI_RELAY_CALL ON_LINE, on_line_params
        beq     L89DD
L89CC:  pha
        ldy     device_num
        lda     #$00
        sta     $E1A0,y
        dec     buf3len
        dec     LDD9E
        pla
        rts

L89DD:  lda     L0800
        and     #$0F
        bne     L89EA
        lda     $0801
        jmp     L89CC

L89EA:  jsr     push_zp_addrs
        jsr     DESKTOP_FIND_SPACE
        ldy     device_num
        sta     $E1A0,y
        jsr     file_address_lookup
        stax    $06
        ldx     #$00
        ldy     #$09
        lda     #$20
L8A03:  sta     ($06),y
        iny
        inx
        cpx     #$12
        bne     L8A03
        ldy     #$09
        lda     L0800
        and     #$0F
        sta     L0800
        sta     ($06),y
        addr_call L87BA, $800
        ldx     #$00
        ldy     #$0B
L8A22:  lda     $0801,x
        sta     ($06),y
        iny
        inx
        cpx     L0800
        bne     L8A22
        ldy     #$09
        lda     ($06),y
        clc
        adc     #$02
        sta     ($06),y

        lda     unit_number
        cmp     #$3E            ; ??? Special case? Maybe RamWorks?
        beq     use_ramdisk_icon

        and     #$0F            ; lower nibble
        cmp     #DT_PROFILE     ; ProFile or Slinky-style RAM ?
        bne     use_floppy_icon

        ;; BUG: This defaults SmartPort hard drives to use floppy icons.
        ;; See https://github.com/inexorabletash/a2d/issues/6 for more
        ;; context; this code is basically unsalvageable per ProDOS
        ;; Tech Note #21.

        ;; Either ProFile or a "Slinky"/RamFactor-style Disk
        lda     unit_number       ; bit 7 = drive (0=1, 1=2); 5-7 = slot
        and     #%01110000      ; mask off slot
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        ora     #$C0
        sta     load_CxFB
        load_CxFB := *+2
        lda     $C7FB           ; self-modified $Cx7B
        and     #$01            ; $Cx7B bit 1 = ProFile, apparently???
        beq     use_profile_icon
        ;; fall through...

use_ramdisk_icon:
        ldy     #7
        lda     #<desktop_aux::ramdisk_icon
        sta     ($06),y
        iny
        lda     #>desktop_aux::ramdisk_icon
        sta     ($06),y
        jmp     selected_device_icon

use_profile_icon:
        ldy     #7
        lda     #<desktop_aux::profile_icon
        sta     ($06),y
        iny
        lda     #>desktop_aux::profile_icon
        sta     ($06),y
        jmp     selected_device_icon

use_floppy_icon:
        cmp     #$B             ; removable / 4 volumes
        bne     use_floppy140_icon
        ldy     #7
        lda     #<desktop_aux::floppy800_icon
        sta     ($06),y
        iny
        lda     #>desktop_aux::floppy800_icon
        sta     ($06),y
        jmp     selected_device_icon

use_floppy140_icon:
        cmp     #DT_DISKII       ; 0 = Disk II
        bne     use_profile_icon ; last chance
        ldy     #7
        lda     #<desktop_aux::floppy140_icon
        sta     ($06),y
        iny
        lda     #>desktop_aux::floppy140_icon
        sta     ($06),y

selected_device_icon:
        ldy     #$02
        lda     #$00
        sta     ($06),y
        inc     device_num
        lda     device_num
        asl     a
        asl     a
        tax
        ldy     #$03
L8AA7:  lda     L8AC5,x
        sta     ($06),y
        inx
        iny
        cpy     #$07
        bne     L8AA7
        ldx     buf3len
        dex
        ldy     #$00
        lda     ($06),y
        sta     buf3,x
        jsr     pop_zp_addrs
        lda     #$00
        rts
.endproc

;;; ==================================================

unit_number:    .byte   0
device_num:     .byte   0

L8AC5:  .byte   $00,$00,$00,$00,$EA,$01,$10,$00
        .byte   $EA,$01,$2D,$00,$EA,$01,$4B,$00
        .byte   $EA,$01,$67,$00,$EA,$01,$83,$00
        .byte   $90,$01,$A0,$00,$36,$01,$A0,$00
        .byte   $DC,$00,$A0,$00,$82,$00,$A0,$00
        .byte   $28,$00,$A0,$00

.proc get_prefix_params
param_count:    .byte   1
data_buffer:    .addr   $4824
.endproc

L8AF4:  ldx     buf3len
        dex
L8AF8:  cmp     buf3,x
        beq     L8B01
        dex
        bpl     L8AF8
        rts

L8B01:  lda     buf3+1,x
        sta     buf3,x
        inx
        cpx     buf3len
        bne     L8B01
        dec     buf3len
        ldx     buf3len
        lda     #$00
        sta     buf3,x
        rts

L8B19:  jsr     push_zp_addrs
        jmp     L8B2E

L8B1F:  lda     LE6BE
        bne     L8B25
        rts

L8B25:  jsr     push_zp_addrs
        lda     LE6BE
        jsr     L7345
L8B2E:  lda     LE6BE
        ldx     #$07
L8B33:  cmp     LEC26,x
        beq     L8B3E
        dex
        bpl     L8B33
        jmp     L8B43

L8B3E:  lda     #$00
        sta     LEC26,x
L8B43:  lda     LE6BE
        jsr     file_address_lookup
        stax    $06
        ldy     #$02
        lda     ($06),y
        and     #$7F
        sta     ($06),y
        jsr     L4244
        jsr     pop_zp_addrs
        rts

L8B5C:  ldy     #$80
        bne     L8B62
L8B60:  ldy     #$00
L8B62:  sty     L8D4A
        stax    L8D4B
        txa
        jsr     window_lookup
        stax    $06
        lda     #$14
        clc
        adc     #$23
        tay
        ldx     #$23
L8B7B:  lda     ($06),y
        sta     grafport2,x
        dey
        dex
        bpl     L8B7B
        lda     L8D4B
        jsr     file_address_lookup
        stax    $06
        ldy     #$03
        lda     ($06),y
        clc
        adc     #$07
        sta     L0800
        sta     $0804
        iny
        lda     ($06),y
        adc     #$00
        sta     $0801
        sta     $0805
        iny
        lda     ($06),y
        clc
        adc     #$07
        sta     $0802
        sta     $0806
        iny
        lda     ($06),y
        adc     #$00
        sta     $0803
        sta     $0807
        ldy     #$5B
        ldx     #$03
L8BC1:  lda     grafport2,x
        sta     L0800,y
        dey
        dex
        bpl     L8BC1
        sub16  grafport2::cliprect::x2, grafport2::cliprect::x1, L8D54
        sub16  grafport2::cliprect::y2, grafport2::cliprect::y1, L8D56
        add16 $0858, L8D54, $085C
        add16 $085A, L8D56, $085E
        lda     #$00
        sta     L8D4E
        sta     L8D4F
        sta     L8D4D
        sub16  $0858, L0800, L8D50
        sub16  $085A, $0802, L8D52
        bit     L8D51
        bpl     L8C6A
        lda     #$80
        sta     L8D4E
        lda     L8D50
        eor     #$FF
        sta     L8D50
        lda     L8D51
        eor     #$FF
        sta     L8D51
        inc     L8D50
        bne     L8C6A
        inc     L8D51
L8C6A:  bit     L8D53
        bpl     L8C8C
        lda     #$80
        sta     L8D4F
        lda     L8D52
        eor     #$FF
        sta     L8D52
        lda     L8D53
        eor     #$FF
        sta     L8D53
        inc     L8D52
        bne     L8C8C
        inc     L8D53
L8C8C:  lsr     L8D51
        ror     L8D50
        lsr     L8D53
        ror     L8D52
        lsr     L8D55
        ror     L8D54
        lsr     L8D57
        ror     L8D56
        lda     #$0A
        sec
        sbc     L8D4D
        asl     a
        asl     a
        asl     a
        tax
        bit     L8D4E
        bpl     L8CC9
        lda     L0800
        sec
        sbc     L8D50
        sta     L0800,x
        lda     $0801
        sbc     L8D51
        sta     $0801,x
        jmp     L8CDC

L8CC9:  lda     L0800
        clc
        adc     L8D50
        sta     L0800,x
        lda     $0801
        adc     L8D51
        sta     $0801,x
L8CDC:  bit     L8D4F
        bpl     L8CF7
        lda     $0802
        sec
        sbc     L8D52
        sta     $0802,x
        lda     $0803
        sbc     L8D53
        sta     $0803,x
        jmp     L8D0A

L8CF7:  lda     $0802
        clc
        adc     L8D52
        sta     $0802,x
        lda     $0803
        adc     L8D53
        sta     $0803,x
L8D0A:  lda     L0800,x
        clc
        adc     L8D54
        sta     $0804,x
        lda     $0801,x
        adc     L8D55
        sta     $0805,x
        lda     $0802,x
        clc
        adc     L8D56
        sta     $0806,x
        lda     $0803,x
        adc     L8D57
        sta     $0807,x
        inc     L8D4D
        lda     L8D4D
        cmp     #$0A
        beq     L8D3D
        jmp     L8C8C

L8D3D:  bit     L8D4A
        bmi     L8D46
        jsr     L8D58
        rts

L8D46:  jsr     L8DB3
        rts

L8D4A:  .byte   0
L8D4B:  .word   0
L8D4D:  .byte   0
L8D4E:  .byte   0
L8D4F:  .byte   0
L8D50:  .byte   0
L8D51:  .byte   0
L8D52:  .byte   0
L8D53:  .byte   0
L8D54:  .byte   0
L8D55:  .byte   0
L8D56:  .byte   0
L8D57:  .byte   0

;;; ==================================================

L8D58:  lda     #$00
        sta     L8DB2
        jsr     reset_grafport3
        MGTK_RELAY_CALL MGTK::SetPattern, checkerboard_pattern3
        jsr     set_penmode_xor
L8D6C:  lda     L8DB2
        cmp     #$0C
        bcs     L8D89
        asl     a
        asl     a
        asl     a
        clc
        adc     #$07
        tax
        ldy     #$07
L8D7C:  lda     L0800,x
        sta     rect_E230,y
        dex
        dey
        bpl     L8D7C
        jsr     draw_rect_E230
L8D89:  lda     L8DB2
        sec
        sbc     #$02
        bmi     L8DA7
        asl     a
        asl     a
        asl     a
        clc
        adc     #$07
        tax
        ldy     #$07
L8D9A:  lda     L0800,x
        sta     rect_E230,y
        dex
        dey
        bpl     L8D9A
        jsr     draw_rect_E230
L8DA7:  inc     L8DB2
        lda     L8DB2
        cmp     #$0E
        bne     L8D6C
        rts

L8DB2:  .byte   0

;;; ==================================================

L8DB3:  lda     #$0B
        sta     L8E0F
        jsr     reset_grafport3
        MGTK_RELAY_CALL MGTK::SetPattern, checkerboard_pattern3
        jsr     set_penmode_xor
L8DC7:  lda     L8E0F
        bmi     L8DE4
        beq     L8DE4
        asl     a
        asl     a
        asl     a
        clc
        adc     #$07
        tax
        ldy     #$07
L8DD7:  lda     L0800,x
        sta     rect_E230,y
        dex
        dey
        bpl     L8DD7
        jsr     draw_rect_E230
L8DE4:  lda     L8E0F
        clc
        adc     #$02
        cmp     #$0E
        bcs     L8E04
        asl     a
        asl     a
        asl     a
        clc
        adc     #$07
        tax
        ldy     #$07
L8DF7:  lda     L0800,x
        sta     rect_E230,y
        dex
        dey
        bpl     L8DF7
        jsr     draw_rect_E230
L8E04:  dec     L8E0F
        lda     L8E0F
        cmp     #$FD
        bne     L8DC7
        rts

L8E0F:  .byte   0

;;; ==================================================

.proc draw_rect_E230
        MGTK_RELAY_CALL MGTK::FrameRect, rect_E230
        rts
.endproc

;;; ==================================================
;;; Dynamically load parts of Desktop2

;;; Call load_dynamic_routine or restore_dynamic_routine
;;; with A set to routine number (0-8); routine is loaded
;;; from DeskTop2 file to target address. Returns with
;;; minus flag set on failure.

;;; Routines are:
;;;  0 = disk copy                - A$ 800,L$ 200
;;;  1 = format/erase disk        - A$ 800,L$1400 call w/ A = 4 = format, A = 5 = erase
;;;  2 = part of selector actions - A$9000,L$1000
;;;  3 = common routines          - A$5000,L$2000
;;;  4 = part of copy file        - A$7000,L$ 800
;;;  5 = part of delete file      - A$7000,L$ 800
;;;  6 = part of selector actions - L$7000,L$ 800
;;;  7 = restore 1                - A$5000,L$2800 (restore $5000...$77FF)
;;;  8 = restore 2                - A$9000,L$1000 (restore $9000...$9FFF)
;;;
;;; Routines 2-6 need appropriate "restore routines" applied when complete.

.proc load_dynamic_routine_impl

pos_table:
        .dword  $00012FE0,$000160E0,$000174E0,$000184E0,$0001A4E0
        .dword  $0001ACE0,$0001B4E0,$0000B780,$0000F780
len_table:
        .word   $0200,$1400,$1000,$2000,$0800,$0800,$0800,$2800,$1000
addr_table:
        .addr   $0800,$0800,$9000,$5000,$7000,$7000,$7000,$5000,$9000

.proc open_params
param_count:    .byte   3
pathname:       .addr   str_desktop2
io_buffer:      .addr   $1C00
ref_num:        .byte   0
.endproc

str_desktop2:
        PASCAL_STRING "DeskTop2"

.proc set_mark_params
param_count:    .byte   2
ref_num:        .byte   0
position:       .faraddr 0
.endproc

.proc read_params
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   0
request_count:  .word   0
trans_count:    .word   0
.endproc

.proc close_params
param_count:    .byte   1
ref_num:        .byte   0
.endproc

restore_flag:
        .byte   0

        ;; Called with routine # in A

load:   pha                     ; entry point with bit clear
        lda     #$00
        sta     restore_flag
        beq     :+

restore:
        pha
        lda     #$80            ; entry point with bit set
        sta     restore_flag

:       pla
        asl     a               ; y = A * 2 (to index into word table)
        tay
        asl     a               ; x = A * 4 (to index into dword table)
        tax

        lda     pos_table,x
        sta     set_mark_params::position
        lda     pos_table+1,x
        sta     set_mark_params::position+1
        lda     pos_table+2,x
        sta     set_mark_params::position+2

        copy16  len_table,y, read_params::request_count
        copy16  addr_table,y, read_params::data_buffer

open:   MLI_RELAY_CALL OPEN, open_params
        beq     :+

        lda     #warning_msg_insert_system_disk
        ora     restore_flag    ; high bit set = no cancel
        jsr     show_warning_dialog_num
        beq     open
        lda     #$FF            ; failed
        rts

:       lda     open_params::ref_num
        sta     read_params::ref_num
        sta     set_mark_params::ref_num
        MLI_RELAY_CALL SET_MARK, set_mark_params
        MLI_RELAY_CALL READ, read_params
        MLI_RELAY_CALL CLOSE, close_params
        rts

        .assert * = $8EFB, error, "Segment length mismatch"
        PAD_TO $8F00

.endproc
        load_dynamic_routine := load_dynamic_routine_impl::load
        restore_dynamic_routine := load_dynamic_routine_impl::restore

;;; ==================================================

L8F00:  jmp     L8FC5
        jmp     rts2            ; rts
        jmp     rts2            ; rts
L8F09:  jmp     L92E7
L8F0C:  jmp     L8F9B
L8F0F:  jmp     L8FA1
L8F12:  jmp     L9571
L8F15:  jmp     L9213
L8F18:  jmp     L8F2A
L8F1B:  jmp     L8F5B
        jmp     rts2            ; rts
        jmp     rts2            ; rts
L8F24:  jmp     L8F7E
L8F27:  jmp     L8FB8

L8F2A:  lda     #$00
        sta     L9189
        tsx
        stx     L9188
        jsr     LA248
        jsr     L993E
        jsr     LA271
        jsr     L9968
L8F3F:  lda     #$FF
        sta     $E05B
        lda     #$00
        sta     $E05C
        jsr     L9A0D
        jsr     L917F
L8F4F:  jsr     L91E8
        lda     #$00
        rts

        jsr     L91D5
        jmp     L8F4F

L8F5B:  lda     #$00
        sta     L9189
        tsx
        stx     L9188
        jsr     LA248
        lda     #$00
        jsr     L9E7E
        jsr     LA271
        jsr     L9182
        jsr     L9EBF
        jsr     L9EDB
        jsr     L917F
        jmp     L8F4F

L8F7E:  lda     #$80
        sta     L918C
        lda     #$C0
        sta     L9189
        tsx
        stx     L9188
        jsr     LA248
        jsr     L9984
        jsr     LA271
        jsr     L99BC
        jmp     L8F3F

L8F9B:  jsr     L8FDD
        jmp     L8F4F

L8FA1:  jsr     L8FE1
        jmp     L8F4F

L8FA7:  asl     a
        tay
        copy16  file_address_table,y, $06
        ldy     #$02
        lda     ($06),y
        rts

L8FB8:  lda     #$00
        sta     L918C
        lda     #$C0
        sta     L9189
        jmp     L8FEB

L8FC5:  lda     LEBFC
        cmp     #$01
        bne     L8FD0
        lda     #$80
        bne     L8FD2
L8FD0:  lda     #$00
L8FD2:  sta     L918A
        lda     #$00
        sta     L9189
        jmp     L8FEB

L8FDD:  lda     #$00
        beq     L8FE3
L8FE1:  lda     #$80
L8FE3:  sta     L918B
        lda     #$80
        sta     L9189
L8FEB:  tsx
        stx     L9188
        lda     #$00
        sta     $E05C
        jsr     L91D5
        lda     L9189
        beq     L8FFF
        jmp     L908C

L8FFF:  bit     L918A
        bpl     L9011
        lda     selected_window_index
        beq     L900C
        jmp     L908C

L900C:  pla
        pla
        jmp     JT_EJECT

L9011:  lda     LEBFC
        bpl     L9032
        and     #$7F
        asl     a
        tax
        copy16  window_address_table,x, $08
        copy16  #L917B, $06
        jsr     L91A0
        jmp     L9076

L9032:  jsr     L8FA7
        and     #$0F
        beq     L9051
        asl     a
        tax
        copy16  window_address_table,x, $08
        lda     LEBFC
        jsr     L918E
        jsr     L91A0
        jmp     L9076

L9051:  lda     LEBFC
        jsr     L918E
        ldy     #$01
        lda     #$2F
        sta     ($06),y
        dey
        lda     ($06),y
        sta     L906D
        sta     $E00A,y
L9066:  iny
        lda     ($06),y
        sta     $E00A,y
        L906D := *+1
        cpy     #$00            ; self-modified
        bne     L9066
        ldy     #$01
        lda     #$20
        sta     ($06),y
L9076:  ldy     #$FF
L9078:  iny
        lda     $E00A,y
        sta     LDFC9,y
        cpy     $E00A
        bne     L9078
        lda     LDFC9
        beq     L908C
        dec     LDFC9
L908C:  lda     #$00
        sta     L97E4
        jsr     LA248
        bit     L9189
        bvs     L90B4
        bmi     L90AE
        bit     L918A
        bmi     L90A6
        jsr     L993E
        jmp     L90DE

L90A6:  lda     #$06
        jsr     L9E7E
        jmp     L90DE

L90AE:  jsr     LA059
        jmp     L90DE

L90B4:  jsr     LA1E4
        jmp     L90DE

L90BA:  bit     L9189
        bvs     L90D8
        bmi     L90D2
        bit     L918A
        bmi     L90CC
        jsr     L9968
        jmp     L90DE

L90CC:  jsr     L9EBF
        jmp     L90DE

L90D2:  jsr     LA0DF
        jmp     L90DE

L90D8:  jsr     LA241
        jmp     L90DE

L90DE:  jsr     L91F5
        lda     is_file_selected
        bne     L90E9
        jmp     L9168

L90E9:  ldx     #$00
        stx     L917A
L90EE:  jsr     L91F5
        ldx     L917A
        lda     selected_file_index,x
        cmp     #$01
        beq     L9140
        jsr     L918E
        jsr     L91A0
        copy16  #$E00A, $06
        ldy     #$00
        lda     ($06),y
        beq     L9114
        sec
        sbc     #$01
        sta     ($06),y
L9114:  lda     L97E4
        beq     L913D
        bit     L9189
        bmi     L912F
        bit     L918A
        bmi     L9129
        jsr     L9A01
        jmp     L9140

L9129:  jsr     L9EDB
        jmp     L9140

L912F:  bvs     L9137
        jsr     LA114
        jmp     L9140

L9137:  jsr     LA271
        jmp     L9140

L913D:  jsr     LA271
L9140:  inc     L917A
        ldx     L917A
        cpx     is_file_selected
        bne     L90EE
        lda     L97E4
        bne     L9168
        inc     L97E4
        bit     L9189
        bmi     L915D
        bit     L918A
        bpl     L9165
L915D:  jsr     L9182
        bit     L9189
        bvs     L9168
L9165:  jmp     L90BA

L9168:  jsr     L917F
        lda     LEBFC
        jsr     L918E
        ldy     #$01
        lda     #$20
        sta     ($06),y
        lda     #$00
        rts

L917A:  .byte   0
L917B:  .byte   0

        ;; Dynamically constructed jump table???
        L917D := *+1
L917C:  jmp     dummy0000
        L9180 := *+1
L917F:  jmp     dummy0000
        L9183 := *+1
L9182:  jmp     dummy0000
        L9186 := *+1
L9185:  jmp     dummy0000

L9188:  .byte   0
L9189:  .byte   0
L918A:  .byte   0
L918B:  .byte   0
L918C:  .byte   0
L918D:  .byte   0
L918E:  asl     a
        tay
        lda     file_address_table,y
        clc
        adc     #$09
        sta     $06
        lda     file_address_table+1,y
        adc     #$00
        sta     $06+1
        rts

L91A0:  ldx     #$00
        ldy     #$00
        lda     ($08),y
        beq     L91B6
        sta     L91B3
L91AB:  iny
        inx
        lda     ($08),y
        sta     $E00A,x
        L91B3 := *+1
        cpy     #0              ; self-modified
        bne     L91AB
L91B6:  inx
        lda     #'/'
        sta     $E00A,x
        ldy     #$00
        lda     ($06),y
        beq     L91D1
        sta     L91CE
        iny
L91C6:  iny
        inx
        lda     ($06),y
        sta     $E00A,x
        .byte   $C0
L91CE:  .byte   0
        bne     L91C6
L91D1:  stx     $E00A
        rts

L91D5:  yax_call JT_MGTK_RELAY, MGTK::InitPort, grafport3
        yax_call JT_MGTK_RELAY, MGTK::SetPort, grafport3
        rts

L91E8:  jsr     JT_REDRAW_ALL
        yax_call JT_DESKTOP_RELAY, $C, 0
        rts

L91F5:  copy16  #L9211, $08
        lda     selected_window_index
        beq     L9210
        asl     a
        tax
        copy16  window_address_table,x, $08
        lda     #$00
L9210:  rts

L9211:  .addr   0

L9213:  lda     is_file_selected
        bne     L9219
        rts

L9219:  ldx     is_file_selected
        stx     L0800
        dex
L9220:  lda     selected_file_index,x
        sta     $0801,x
        dex
        bpl     L9220
        jsr     JT_CLEAR_SELECTION
        ldx     #$00
        stx     L924A
L9231:  ldx     L924A
        lda     $0801,x
        cmp     #$01
        beq     L923E
        jsr     L924B
L923E:  inc     L924A
        ldx     L924A
        cpx     L0800
        bne     L9231
        rts

L924A:  .byte   0
L924B:  sta     L9254
        ldy     #$00
L9250:  lda     $E1A0,y
        .byte   $C9
L9254:  .byte   0
        beq     L9260
        cpy     DEVCNT
        beq     L925F
        iny
        bne     L9250
L925F:  rts

L9260:  lda     DEVLST,y
        sta     L92C7
        ldx     #$11
        lda     L92C7
        and     #$80
        beq     L9271
        ldx     #$21
L9271:  stx     L9284
        lda     L92C7
        and     #$70
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     L9284
        sta     L9284
        L9284 := *+1
        lda     $BF00           ; self-modified
        sta     $06+1
        lda     #$00
        sta     $06
        ldy     #$07
        lda     ($06),y
        bne     L925F
        ldy     #$FB
        lda     ($06),y
        and     #$7F
        bne     L925F
        ldy     #$FF
        lda     ($06),y
        clc
        adc     #$03
        sta     $06
        lda     L92C7
        pha
        rol     a
        pla
        php
        and     #$20
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        plp
        adc     #$01
        sta     L92C1
        jsr     L92BD
        .byte   $04
        .addr   L92C0
        rts
L92BD:  jmp     ($06)

L92C0:  .byte   3
L92C1:  .byte   $00
        .addr   L92C5
        .byte   4
L92C5:  .byte   $00,$00
L92C7:  .byte   $00,$00

.proc get_file_info_params5
param_count:    .byte   $A
pathname:       .addr   $220
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

L92DB:  .byte   0,0

.proc block_params
param_count:    .byte   $03
unit_num:       .byte   $0
data_buffer:    .addr   $0800
block_num:      .word   $A
.endproc

L92E3:  .byte   $00
L92E4:  .byte   $00
L92E5:  .byte   $00
L92E6:  .byte   $00
L92E7:  lda     is_file_selected
        bne     L92ED
        rts

L92ED:  lda     #$00
        sta     L92E6
        jsr     L91D5
L92F5:  ldx     L92E6
        cpx     is_file_selected
        bne     L9300
        jmp     L9534

L9300:  lda     selected_window_index
        beq     L9331
        asl     a
        tax
        copy16  window_address_table,x, $08
        ldx     L92E6
        lda     selected_file_index,x
        jsr     L918E
        jsr     L91A0
        ldy     #$00
L931F:  lda     $E00A,y
        sta     $220,y
        iny
        cpy     $220
        bne     L931F
        dec     $220
        jmp     L9356

L9331:  ldx     L92E6
        lda     selected_file_index,x
        cmp     #$01
        bne     L933E
        jmp     L952E

L933E:  jsr     L918E
        ldy     #$00
L9343:  lda     ($06),y
        sta     $220,y
        iny
        cpy     $220
        bne     L9343
        dec     $220
        lda     #'/'
        sta     $0221
L9356:  yax_call JT_MLI_RELAY, GET_FILE_INFO, get_file_info_params5
        beq     L9366
        jsr     LA49B
        beq     L9356
L9366:  lda     selected_window_index
        beq     L9387
        lda     #$80
        sta     L92E3
        lda     L92E6
        clc
        adc     #$01
        cmp     is_file_selected
        beq     L9381
        inc     L92E3
        inc     L92E3
L9381:  jsr     L953F
        jmp     L93DB

L9387:  lda     #$81
        sta     L92E3
        lda     L92E6
        clc
        adc     #$01
        cmp     is_file_selected
        beq     L939D
        inc     L92E3
        inc     L92E3
L939D:  jsr     L953F
        lda     #$00
        sta     L942E
        ldx     L92E6
        lda     selected_file_index,x
        ldy     #$0F
L93AD:  cmp     $E1A0,y
        beq     L93B8
        dey
        bpl     L93AD
        jmp     L93DB

L93B8:  lda     DEVLST,y
        sta     block_params::unit_num
        yax_call JT_MLI_RELAY, READ_BLOCK, block_params
        bne     L93DB
        yax_call JT_MLI_RELAY, WRITE_BLOCK, block_params
        cmp     #$2B
        bne     L93DB
        lda     #$80
        sta     L942E
L93DB:  ldx     L92E6
        lda     selected_file_index,x
        jsr     L918E
        lda     #$01
        sta     L92E3
        copy16  $06, L92E4
        jsr     L953F
        lda     #$02
        sta     L92E3
        lda     selected_window_index
        bne     L9413
        bit     L942E
        bmi     L940C
        lda     #$00
        sta     L92E4
        beq     L9428
L940C:  lda     #$01
        sta     L92E4
        bne     L9428
L9413:  lda     get_file_info_params5::access
        and     #$C3
        cmp     #$C3
        beq     L9423
        lda     #$01
        sta     L92E4
        bne     L9428
L9423:  lda     #$00
        sta     L92E4
L9428:  jsr     L953F
        jmp     L942F

L942E:  .byte   0
L942F:  lda     #$03
        sta     L92E3
        lda     #$00
        sta     $220
        lda     selected_window_index
        bne     L9472                           ; ProDOS TRM 4.4.5:
        lda     get_file_info_params5::aux_type   ; "When file information about a volume
        sec                                      ; directory is requested, the total
        sbc     get_file_info_params5::blocks_used    ; number of blocks on the volume is
        pha                                      ; returned in the aux_type field and
        lda     get_file_info_params5::aux_type+1 ; the total blocks for all files is
        sbc     get_file_info_params5::blocks_used+1  ; returned in blocks_used."
        tax
        pla
        jsr     L4006
        jsr     L9549
        ldx     #$00
L9456:  lda     text_buffer2::data-1,x
        cmp     #$42
        beq     L9460
        inx
        bne     L9456
L9460:  stx     $220
        lda     #'/'
        sta     $220,x
        dex
L9469:  lda     text_buffer2::data-1,x
        sta     $220,x
        dex
        bne     L9469
L9472:  lda     selected_window_index
        bne     L9480
        ldax    get_file_info_params5::aux_type
        jmp     L9486

L9480:  ldax    get_file_info_params5::blocks_used
L9486:  jsr     L4006
        jsr     L9549
        ldx     $220
        ldy     #$00
L9491:  lda     $E6EC,y
        sta     $0221,x
        inx
        iny
        cpy     text_buffer2::length
        bne     L9491
        tya
        clc
        adc     $220
        sta     $220
        ldx     $220
L94A9:  lda     $220,x
        sta     LDFC9,x
        dex
        bpl     L94A9
        lda     #<LDFC9
        sta     L92E4
        lda     #>LDFC9
        sta     L92E4+1
        jsr     L953F
        lda     #$04
        sta     L92E3
        copy16  get_file_info_params5::create_date, date
        jsr     L4009
        copy16  #$E6EB, L92E4
        jsr     L953F
        lda     #$05
        sta     L92E3
        copy16  get_file_info_params5::mod_date, date
        jsr     L4009
        copy16  #$E6EB, L92E4
        jsr     L953F
        lda     #$06
        sta     L92E3
        lda     selected_window_index
        bne     L9519
        ldx     L953A
L950E:  lda     L953A,x
        sta     LDFC5,x
        dex
        bpl     L950E
        bmi     L951F
L9519:  lda     get_file_info_params5::file_type
        jsr     L402D
L951F:  copy16  #LDFC5, L92E4
        jsr     L953F
        bne     L9534
L952E:  inc     L92E6
        jmp     L92F5

L9534:  lda     #$00
        sta     LDFC9
        rts

L953A:  PASCAL_STRING " VOL"


L953F:  yax_call launch_dialog, index_get_info_dialog, L92E3
        rts

L9549:  ldx     #$00
L954B:  lda     $E6EC,x
        cmp     #$20
        bne     L9555
        inx
        bne     L954B
L9555:  ldy     #$00
        dex
L9558:  lda     $E6EC,x
        sta     $E6EC,y
        iny
        inx
        cpx     text_buffer2::length
        bne     L9558
        sty     text_buffer2::length
        rts

.proc rename_params
param_count:    .byte   2
pathname:       .addr   $220
new_pathname:   .addr   $1FC0
.endproc

L956E:  .byte   0
        .byte   0
L9570:  .byte   $1F

L9571:  lda     #$00
        sta     L9706
L9576:  lda     L9706
        cmp     is_file_selected
        bne     L9581
        lda     #$00
        rts

L9581:  ldx     L9706
        lda     selected_file_index,x
        cmp     #$01
        bne     L9591
        inc     L9706
        jmp     L9576

L9591:  lda     selected_window_index
        beq     L95C2
        asl     a
        tax
        copy16  window_address_table,x, $08
        ldx     L9706
        lda     selected_file_index,x
        jsr     L918E
        jsr     L91A0
        ldy     #$00
L95B0:  lda     $E00A,y
        sta     $220,y
        iny
        cpy     $220
        bne     L95B0
        dec     $220
        jmp     L95E0

L95C2:  ldx     L9706
        lda     selected_file_index,x
        jsr     L918E
        ldy     #$00
L95CD:  lda     ($06),y
        sta     $220,y
        iny
        cpy     $220
        bne     L95CD
        dec     $220
        lda     #'/'
        sta     $0221
L95E0:  ldx     L9706
        lda     selected_file_index,x
        jsr     L918E
        ldy     #$00
        lda     ($06),y
        tay
L95EE:  lda     ($06),y
        sta     $1F12,y
        dey
        bpl     L95EE
        ldy     #$00
        lda     ($06),y
        tay
        dey
        sec
        sbc     #$02
        sta     $1F00
L9602:  lda     ($06),y
        sta     $1EFF,y
        dey
        cpy     #$01
        bne     L9602
        lda     #$00
        jsr     L96F8
L9611:  lda     #$80
        jsr     L96F8
        beq     L962F
L9618:  ldx     L9706
        lda     selected_file_index,x
        jsr     L918E
        ldy     $1F12
L9624:  lda     $1F12,y
        sta     ($06),y
        dey
        bpl     L9624
        lda     #$FF
        rts

L962F:  sty     $08
        sty     L9707
        stx     $08+1
        stx     L9708
        lda     selected_window_index
        beq     L964D
        asl     a
        tax
        copy16  window_address_table,x, $06
        jmp     L9655

L964D:  copy16  #$9705, $06
L9655:  ldy     #$00
        lda     ($06),y
        tay
L965A:  lda     ($06),y
        sta     $1FC0,y
        dey
        bpl     L965A
        inc     $1FC0
        ldx     $1FC0
        lda     #'/'
        sta     $1FC0,x
        ldy     #$00
        lda     ($08),y
        sta     L9709
L9674:  inx
        iny
        lda     ($08),y
        sta     $1FC0,x
        cpy     L9709
        bne     L9674
        stx     $1FC0
        yax_call JT_MLI_RELAY, RENAME, rename_params
        beq     L969E
        jsr     JT_SHOW_ALERT0
        bne     L9696
        jmp     L9611

L9696:  lda     #$40
        jsr     L96F8
        jmp     L9618

L969E:  lda     #$40
        jsr     L96F8
        ldx     L9706
        lda     selected_file_index,x
        sta     LE22B
        yax_call JT_DESKTOP_RELAY, $E, LE22B
        copy16  L9707, $08
        ldx     L9706
        lda     selected_file_index,x
        jsr     L918E
        ldy     #$00
        lda     ($08),y
        clc
        adc     #$02
        sta     ($06),y
        lda     ($08),y
        tay
        inc     $06
        bne     L96DA
        inc     $06+1
L96DA:  lda     ($08),y
        sta     ($06),y
        dey
        bne     L96DA
        dec     $06
        lda     $06
        cmp     #$FF
        bne     L96EB
        dec     $06+1
L96EB:  lda     ($06),y
        tay
        lda     #' '
        sta     ($06),y
        inc     L9706
        jmp     L9576

L96F8:  sta     L956E
        yax_call launch_dialog, index_rename_dialog, L956E
        rts

        .byte   $00
L9706:  .byte   $00
L9707:  .byte   $00
L9708:  .byte   $00
L9709:  .byte   $00

.proc open_params3
param_count:    .byte   3
pathname:       .addr   $220
io_buffer:      .addr   $800
ref_num:        .byte   0
.endproc

.proc read_params3
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   L9718
request_count:  .word   4
trans_count:    .word   0
.endproc

L9718:  .res    4, 0

.proc close_params6
param_count:    .byte   1
ref_num:        .byte   0
.endproc

.proc read_params4
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   L97AD
request_count:  .word   $27
trans_count:    .word   0
.endproc

.proc read_params5
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   L972E
request_count:  .word   5
trans_count:    .word   0
.endproc

L972E:  .res    5, 0

        .res    4, 0

.proc close_params5
param_count:    .byte   1
ref_num:        .byte   0
.endproc

.proc close_params3
param_count:    .byte   1
ref_num:        .byte   0
.endproc

.proc destroy_params
param_count:    .byte   1
pathname:       .addr   $0220
.endproc

.proc open_params4
param_count:    .byte   3
pathname:       .addr   $220
io_buffer:      .addr   $0D00
ref_num:        .byte   0
.endproc

.proc open_params5
param_count:    .byte   3
pathname:       .addr   $1FC0
io_buffer:      .addr   $1100
ref_num:        .byte   0
.endproc

.proc read_params6
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   $1500
request_count:  .word   $AC0
trans_count:    .word   0
.endproc

.proc write_params
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   $1500
request_count:  .word   $AC0
trans_count:    .word   0
.endproc

.proc create_params3
param_count:    .byte   7
pathname:       .addr   $1FC0
access: .byte   %11000011
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
create_date:    .word   0
create_time:    .word   0
.endproc

.proc create_params2
param_count:    .byte   7
pathname:       .addr   $1FC0
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
create_date:    .word   0
create_time:    .word   0
.endproc

        .byte   $00,$00

.proc file_info_params2
param_count:    .byte   $A
pathname:       .addr   $220
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

        .byte   0

.proc file_info_params3
param_count:    .byte   $A
pathname:       .addr   $1FC0
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

        .byte   0

.proc set_eof_params
param_count:    .byte   2
ref_num:        .byte   0
eof:    .faraddr 0
.endproc

.proc mark_params
param_count:    .byte   2
ref_num:        .byte   0
position:       .faraddr 0
.endproc

.proc mark_params2
param_count:    .byte   2
ref_num:        .byte   0
position:       .faraddr 0
.endproc

.proc on_line_params2
param_count:    .byte   2
unit_num:       .byte   0
data_buffer:    .addr   $800
.endproc

L97AD:  .byte   $00
L97AE:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00
L97BD:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

L97DD:  .addr   L9B36
L97DF:  .addr   L9B33
L97E1:  .addr   rts2

rts2:   rts

L97E4:  .byte   $00
L97E5:  ldx     $E10C
        lda     $E061
        sta     $E062,x
        inx
        stx     $E10C
        rts

L97F3:  ldx     $E10C
        dex
        lda     $E062,x
        sta     $E061
        stx     $E10C
        rts

L9801:  lda     #$00
        sta     $E05F
        sta     $E10D
L9809:  yax_call JT_MLI_RELAY, OPEN, open_params3
        beq     L981E
        ldx     #$80
        jsr     JT_SHOW_ALERT
        beq     L9809
        jmp     LA39F

L981E:  lda     open_params3::ref_num
        sta     $E060
        sta     read_params3::ref_num
L9827:  yax_call JT_MLI_RELAY, READ, read_params3
        beq     L983C
        ldx     #$80
        jsr     JT_SHOW_ALERT
        beq     L9827
        jmp     LA39F

L983C:  jmp     L985B

L983F:  lda     $E060
        sta     close_params6::ref_num
L9845:  yax_call JT_MLI_RELAY, CLOSE, close_params6
        beq     L985A
        ldx     #$80
        jsr     JT_SHOW_ALERT
        beq     L9845
        jmp     LA39F

L985A:  rts

L985B:  inc     $E05F
        lda     $E060
        sta     read_params4::ref_num
L9864:  yax_call JT_MLI_RELAY, READ, read_params4
        beq     L987D
        cmp     #$4C
        beq     L989F
        ldx     #$80
        jsr     JT_SHOW_ALERT
        beq     L9864
        jmp     LA39F

L987D:  inc     $E10D
        lda     $E10D
        cmp     $E05E
        bcc     L989C
        lda     #$00
        sta     $E10D
        lda     $E060
        sta     read_params5::ref_num
        yax_call JT_MLI_RELAY, READ, read_params5
L989C:  lda     #$00
        rts

L989F:  lda     #$FF
        rts

L98A2:  lda     $E05F
        sta     $E061
        jsr     L983F
        jsr     L97E5
        jsr     LA2FD
        jmp     L9801

L98B4:  jsr     L983F
        jsr     L992A
        jsr     LA322
        jsr     L97F3
        jsr     L9801
        jsr     L98C9
        jmp     L9927

L98C9:  lda     $E05F
        cmp     $E061
        beq     L98D7
        jsr     L985B
        jmp     L98C9

L98D7:  rts

L98D8:  lda     #$00
        sta     $E05D
        jsr     L9801
L98E0:  jsr     L985B
        bne     L9912
        lda     L97AD
        beq     L98E0
        lda     L97AD
        sta     L992D
        and     #$0F
        sta     L97AD
        lda     #$00
        sta     L9923
        jsr     L9924
        lda     L9923
        bne     L98E0
        lda     L97BD
        cmp     #$0F
        bne     L98E0
        jsr     L98A2
        inc     $E05D
        jmp     L98E0

L9912:  lda     $E05D
        beq     L9920
        jsr     L98B4
        dec     $E05D
        jmp     L98E0

L9920:  jmp     L983F

L9923:  .byte   0
L9924:  jmp     (L97DD)
L9927:  jmp     (L97DF)
L992A:  jmp     (L97E1)

L992D:  .byte   $00,$00,$00,$00
L9931:  .addr   L9B36
        .addr   L9B33
        .addr   rts2

L9937:  .byte   0
L9938:  .addr   0
        .addr   $220
        .addr   $1FC0

L993E:  lda     #$00
        sta     L9937
        copy16  #L995A, L917D
        copy16  #L997C, L9180
        jmp     L9BBF

L995A:  stax    L9938
        lda     #$01
        sta     L9937
        jmp     L9BBF

L9968:  ldy     #$05
L996A:  lda     L9931,y
        sta     L97DD,y
        dey
        bpl     L996A
        lda     #$00
        sta     LA425
        sta     L918D
        rts

L997C:  lda     #$05
        sta     L9937
        jmp     L9BBF

L9984:  lda     #$00
        sta     L9937
        copy16  #$99A7, L917D
        copy16  #$99DC, L9180
        yax_call launch_dialog, index_download_dialog, L9937
        rts

        stax    L9938
        lda     #$01
        sta     L9937
        yax_call launch_dialog, index_download_dialog, L9937
        rts

L99BC:  lda     #$80
        sta     L918D
        ldy     #$05
L99C3:  lda     L9931,y
        sta     L97DD,y
        dey
        bpl     L99C3
        lda     #$00
        sta     LA425
        copy16  #$99EB, L9186
        rts

        lda     #$03
        sta     L9937
        yax_call launch_dialog, index_download_dialog, L9937
        rts

        lda     #$04
        sta     L9937
        yax_call launch_dialog, index_download_dialog, L9937
        cmp     #$02
        bne     L99FE
        rts

L99FE:  jmp     LA39F

L9A01:  lda     #$80
        sta     $E05B
        lda     #$00
        sta     $E05C
        beq     L9A0F
L9A0D:  lda     #$FF
L9A0F:  sta     L9B31
        lda     #$02
        sta     L9937
        jsr     LA379
        bit     L9189
        bvc     L9A22
        jsr     L9BC9
L9A22:  bit     $E05B
        bpl     L9A70
        bvs     L9A50
        lda     L9B31
        bne     L9A36
        lda     selected_window_index
        bne     L9A36
        jmp     L9B28

L9A36:  ldx     $1FC0
        ldy     L9B32
        dey
L9A3D:  iny
        inx
        lda     $220,y
        sta     $1FC0,x
        cpy     $220
        bne     L9A3D
        stx     $1FC0
        jmp     L9A70

L9A50:  ldx     $1FC0
        lda     #'/'
        sta     $1FC1,x
        inc     $1FC0
        ldy     #$00
        ldx     $1FC0
L9A60:  iny
        inx
        lda     $E04B,y
        sta     $1FC0,x
        cpy     $E04B
        bne     L9A60
        stx     $1FC0
L9A70:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     L9A81
        jsr     LA49B
        jmp     L9A70

L9A81:  lda     file_info_params2::storage_type
        cmp     #ST_VOLUME_DIRECTORY
        beq     L9A90
        cmp     #ST_LINKED_DIRECTORY
        beq     L9A90
        lda     #$00
        beq     L9A95
L9A90:  jsr     LA2F1
        lda     #$FF
L9A95:  sta     L9B30
        jsr     LA40A
        lda     LA2EE
        bne     L9AA8
        lda     LA2ED
        bne     L9AA8
        jmp     LA39F

L9AA8:  ldy     #$07
L9AAA:  lda     file_info_params2,y
        sta     create_params2,y
        dey
        cpy     #$02
        bne     L9AAA
        lda     #%11000011
        sta     create_params2::access
        lda     $E05B
        beq     L9B23
        jsr     L9C01
        bcs     L9B2C
        ldy     #$11
        ldx     #$0B
L9AC8:  lda     file_info_params2,y
        sta     create_params2,x
        dex
        dey
        cpy     #$0D
        bne     L9AC8
        lda     create_params2::storage_type
        cmp     #ST_VOLUME_DIRECTORY
        bne     L9AE0
        lda     #ST_LINKED_DIRECTORY
        sta     create_params2::storage_type
L9AE0:  yax_call JT_MLI_RELAY, CREATE, create_params2
        beq     L9B23
        cmp     #$47
        bne     L9B1D
        bit     L918D
        bmi     L9B14
        lda     #$03
        sta     L9937
        jsr     L9BBF
        pha
        lda     #$02
        sta     L9937
        pla
        cmp     #$02
        beq     L9B14
        cmp     #$03
        beq     L9B2C
        cmp     #$04
        bne     L9B1A
        lda     #$80
        sta     L918D
L9B14:  jsr     LA426
        jmp     L9B23

L9B1A:  jmp     LA39F

L9B1D:  jsr     LA49B
        jmp     L9AE0

L9B23:  lda     L9B30
        beq     L9B2D
L9B28:  jmp     L98D8

        .byte   0
L9B2C:  rts

L9B2D:  jmp     L9CDA

L9B30:  .byte   0
L9B31:  .byte   0
L9B32:  .byte   0
L9B33:  jmp     LA360

L9B36:  jsr     LA3D1
        beq     L9B3E
        jmp     LA39F

L9B3E:  lda     L97BD
        cmp     #$0F
        bne     L9B88
        jsr     LA2FD
L9B48:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     L9B59
        jsr     LA49B
        jmp     L9B48

L9B59:  jsr     LA33B
        jsr     LA40A
        jsr     LA2F1
        lda     LA2EE
        bne     L9B6F
        lda     LA2ED
        bne     L9B6F
        jmp     LA39F

L9B6F:  jsr     L9E19
        bcs     L9B7A
        jsr     LA322
        jmp     L9BBE

L9B7A:  jsr     LA360
        jsr     LA322
        lda     #$FF
        sta     L9923
        jmp     L9BBE

L9B88:  jsr     LA33B
        jsr     LA2FD
        jsr     LA40A
L9B91:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     L9BA2
        jsr     LA49B
        jmp     L9B91

L9BA2:  jsr     L9C01
        bcc     L9BAA
        jmp     LA39F

L9BAA:  jsr     LA322
        jsr     L9E19
        bcs     L9BBB
        jsr     LA2FD
        jsr     L9CDA
        jsr     LA322
L9BBB:  jsr     LA360
L9BBE:  rts

L9BBF:  yax_call launch_dialog, index_copy_file_dialog, L9937
        rts

L9BC9:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params3
        beq     L9BDA
        jsr     LA497
        jmp     L9BC9

L9BDA:  sub16  file_info_params3::aux_type, file_info_params3::blocks_used, L9BFF
        lda     L9BFF
        cmp     LA2EF
        lda     L9C00
        sbc     LA2F0
        bcs     L9BFE
        jmp     L9185

L9BFE:  rts

L9BFF:  .byte   0
L9C00:  .byte   0
L9C01:  jsr     L9C1A
        bcc     L9C19
        lda     #$04
        sta     L9937
        jsr     L9BBF
        beq     L9C13
        jmp     LA39F

L9C13:  lda     #$03
        sta     L9937
        sec
L9C19:  rts

L9C1A:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     L9C2B
        jsr     LA49B
        jmp     L9C1A

L9C2B:  lda     #$00
        sta     L9CD8
        sta     L9CD9
L9C33:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params3
        beq     L9C48
        cmp     #$46
        beq     L9C54
        jsr     LA497
        jmp     L9C33

L9C48:  copy16  file_info_params3::blocks_used, L9CD8
L9C54:  lda     $1FC0
        sta     L9CD6
        ldy     #$01
L9C5C:  iny
        cpy     $1FC0
        bcs     L9CCC
        lda     $1FC0,y
        cmp     #$2F
        bne     L9C5C
        tya
        sta     $1FC0
        sta     L9CD7
L9C70:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params3
        beq     L9C95
        pha
        lda     L9CD6
        sta     $1FC0
        pla
        jsr     LA497
        jmp     L9C70

        lda     L9CD7
        sta     $1FC0
        jmp     L9C70

        jmp     LA39F

L9C95:  sub16  file_info_params3::aux_type, file_info_params3::blocks_used, L9CD4
        add16 L9CD4, L9CD8, L9CD4
        lda     L9CD4
        cmp     file_info_params2::blocks_used
        lda     L9CD5
        sbc     file_info_params2::blocks_used+1
        bcs     L9CCC
        sec
        bcs     L9CCD
L9CCC:  clc
L9CCD:  lda     L9CD6
        sta     $1FC0
        rts

L9CD4:  .byte   0
L9CD5:  .byte   0
L9CD6:  .byte   0
L9CD7:  .byte   0
L9CD8:  .byte   0
L9CD9:  .byte   0
L9CDA:  jsr     LA2F1
        lda     #$00
        sta     L9E17
        sta     L9E18
        sta     mark_params::position
        sta     mark_params::position+1
        sta     mark_params::position+2
        sta     mark_params2::position
        sta     mark_params2::position+1
        sta     mark_params2::position+2
        jsr     L9D62
        jsr     L9D74
        jsr     L9D81
        beq     L9D09
        lda     #$FF
        sta     L9E17
        bne     L9D0C
L9D09:  jsr     L9D9C
L9D0C:  jsr     L9DA9
        bit     L9E17
        bpl     L9D28
        jsr     L9E0D
L9D17:  jsr     L9D81
        bne     L9D17
        jsr     L9D9C
        yax_call JT_MLI_RELAY, SET_MARK, mark_params2
L9D28:  bit     L9E18
        bmi     L9D51
        jsr     L9DE8
        bit     L9E17
        bpl     L9D0C
        jsr     L9E03
        jsr     L9D62
        jsr     L9D74
        yax_call JT_MLI_RELAY, SET_MARK, mark_params
        beq     L9D0C
        lda     #$FF
        sta     L9E18
        jmp     L9D0C

L9D51:  jsr     L9E03
        bit     L9E17
        bmi     L9D5C
        jsr     L9E0D
L9D5C:  jsr     LA46D
        jmp     LA479

L9D62:  yax_call JT_MLI_RELAY, OPEN, open_params4
        beq     L9D73
        jsr     LA49B
        jmp     L9D62

L9D73:  rts

L9D74:  lda     open_params4::ref_num
        sta     read_params6::ref_num
        sta     close_params5::ref_num
        sta     mark_params::ref_num
        rts

L9D81:  yax_call JT_MLI_RELAY, OPEN, open_params5
        beq     L9D9B
        cmp     #$45
        beq     L9D96
        jsr     LA497
        jmp     L9D81

L9D96:  jsr     LA497
        lda     #$45
L9D9B:  rts

L9D9C:  lda     open_params5::ref_num
        sta     write_params::ref_num
        sta     close_params3::ref_num
        sta     mark_params2::ref_num
        rts

L9DA9:  copy16  #$0AC0, read_params6::request_count
L9DB3:  yax_call JT_MLI_RELAY, READ, read_params6
        beq     L9DC8
        cmp     #$4C
        beq     L9DD9
        jsr     LA49B
        jmp     L9DB3

L9DC8:  copy16  read_params6::trans_count, write_params::request_count
        ora     read_params6::trans_count
        bne     L9DDE
L9DD9:  lda     #$FF
        sta     L9E18
L9DDE:  yax_call JT_MLI_RELAY, GET_MARK, mark_params
        rts

L9DE8:  yax_call JT_MLI_RELAY, WRITE, write_params
        beq     L9DF9
        jsr     LA497
        jmp     L9DE8

L9DF9:  yax_call JT_MLI_RELAY, GET_MARK, mark_params2
        rts

L9E03:  yax_call JT_MLI_RELAY, CLOSE, close_params3
        rts

L9E0D:  yax_call JT_MLI_RELAY, CLOSE, close_params5
        rts

L9E17:  .byte   0
L9E18:  .byte   0
L9E19:  ldx     #$07
L9E1B:  lda     file_info_params2,x
        sta     create_params3,x
        dex
        cpx     #$03
        bne     L9E1B
L9E26:  yax_call JT_MLI_RELAY, CREATE, create_params3
        beq     L9E6F
        cmp     #$47
        bne     L9E69
        bit     L918D
        bmi     L9E60
        lda     #$03
        sta     L9937
        yax_call launch_dialog, index_copy_file_dialog, L9937
        pha
        lda     #$02
        sta     L9937
        pla
        cmp     #$02
        beq     L9E60
        cmp     #$03
        beq     L9E71
        cmp     #$04
        bne     L9E66
        lda     #$80
        sta     L918D
L9E60:  jsr     LA426
        jmp     L9E6F

L9E66:  jmp     LA39F

L9E69:  jsr     LA497
        jmp     L9E26

L9E6F:  clc
        rts

L9E71:  sec
        rts

L9E73:  .byte   $94,$9F,$E3,$97,$2E,$A0
L9E79:  .byte   0
L9E7A:  .word   0
        .byte   $20
        .byte   $02

L9E7E:  sta     L9E79
        copy16  #$9EB1, L9183
        copy16  #$9EA3, L917D
        jsr     LA044
        copy16  #$9ED3, L9180
        rts

        stax    L9E7A
        lda     #$01
        sta     L9E79
        jmp     LA044

        lda     #$02
        sta     L9E79
        jsr     LA044
        beq     L9EBE
        jmp     LA39F

L9EBE:  rts

L9EBF:  ldy     #$05
L9EC1:  lda     L9E73,y
        sta     L97DD,y
        dey
        bpl     L9EC1
        lda     #$00
        sta     LA425
        sta     L918D
        rts

        lda     #$05
        sta     L9E79
        jmp     LA044

L9EDB:  lda     #$03
        sta     L9E79
        jsr     LA379
L9EE3:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     L9EF4
        jsr     LA49B
        jmp     L9EE3

L9EF4:  lda     file_info_params2::storage_type
        sta     L9F1D
        cmp     #ST_LINKED_DIRECTORY
        beq     L9F02
        lda     #$00
        beq     L9F04
L9F02:  lda     #$FF
L9F04:  sta     L9F1C
        beq     L9F1E
        jsr     L98D8
        lda     L9F1D
        cmp     #$0D
        bne     L9F18
        lda     #$FF
        sta     L9F1D
L9F18:  jmp     L9F1E

        rts

L9F1C:  .byte   0
L9F1D:  .byte   0
L9F1E:  bit     $E05C
        bmi     L9F26
        jsr     LA3EF
L9F26:  jsr     LA2F1
L9F29:  yax_call JT_MLI_RELAY, DESTROY, destroy_params
        beq     L9F8D
        cmp     #$4E
        bne     L9F8E
        bit     L918D
        bmi     L9F62
        lda     #$04
        sta     L9E79
        jsr     LA044
        pha
        lda     #$03
        sta     L9E79
        pla
        cmp     #$03
        beq     L9F8D
        cmp     #$02
        beq     L9F62
        cmp     #$04
        bne     L9F5F
        lda     #$80
        sta     L918D
        bne     L9F62
L9F5F:  jmp     LA39F

L9F62:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        lda     file_info_params2::access
        and     #$80
        bne     L9F8D
        lda     #$C3
        sta     file_info_params2::access
        lda     #7              ; param count for SET_FILE_INFO
        sta     file_info_params2
        yax_call JT_MLI_RELAY, SET_FILE_INFO, file_info_params2
        lda     #$A             ; param count for GET_FILE_INFO
        sta     file_info_params2
        jmp     L9F29

L9F8D:  rts

L9F8E:  jsr     LA49B
        jmp     L9F29

        jsr     LA3D1
        beq     L9F9C
        jmp     LA39F

L9F9C:  jsr     LA2FD
        bit     $E05C
        bmi     L9FA7
        jsr     LA3EF
L9FA7:  jsr     LA2F1
L9FAA:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     L9FBB
        jsr     LA49B
        jmp     L9FAA

L9FBB:  lda     file_info_params2::storage_type
        cmp     #ST_LINKED_DIRECTORY
        beq     LA022
L9FC2:  yax_call JT_MLI_RELAY, DESTROY, destroy_params
        beq     LA022
        cmp     #$4E
        bne     LA01C
        bit     L918D
        bmi     LA001
        lda     #$04
        sta     L9E79
        yax_call launch_dialog, index_delete_file_dialog, L9E79
        pha
        lda     #$03
        sta     L9E79
        pla
        cmp     #$03
        beq     LA022
        cmp     #$02
        beq     LA001
        cmp     #$04
        bne     L9FFE
        lda     #$80
        sta     L918D
        bne     LA001
L9FFE:  jmp     LA39F

LA001:  lda     #$C3
        sta     file_info_params2::access
        lda     #7              ; param count for SET_FILE_INFO
        sta     file_info_params2
        yax_call JT_MLI_RELAY, SET_FILE_INFO, file_info_params2
        lda     #$A             ; param count for GET_FILE_INFO
        sta     file_info_params2
        jmp     L9FC2

LA01C:  jsr     LA49B
        jmp     L9FC2

LA022:  jmp     LA322

        jsr     LA322
        lda     #$FF
        sta     L9923
        rts

LA02E:  yax_call JT_MLI_RELAY, DESTROY, destroy_params
        beq     LA043
        cmp     #$4E
        beq     LA043
        jsr     LA49B
        jmp     LA02E

LA043:  rts

LA044:  yax_call launch_dialog, index_delete_file_dialog, L9E79
        rts

LA04E:  .addr   LA170
        .addr   rts2
        .addr   rts2
LA054:  .byte   0
LA055:  .word   0
        .addr   $220

LA059:  lda     #$00
        sta     LA054
        bit     L918B
        bpl     LA085
        copy16  #$A0D1, L9183
        copy16  #$A0B5, L917D
        jsr     LA10A
        copy16  #$A0F8, L9180
        rts

LA085:  copy16  #$A0C3, L9183
        copy16  #$A0A7, L917D
        jsr     LA100
        copy16  #$A0F0, L9180
        rts

        stax    LA055
        lda     #$01
        sta     LA054
        jmp     LA100

        stax    LA055
        lda     #$01
        sta     LA054
        jmp     LA10A

        lda     #$02
        sta     LA054
        jsr     LA100
        beq     LA0D0
        jmp     LA39F

LA0D0:  rts

        lda     #$02
        sta     LA054
        jsr     LA10A
        beq     LA0DE
        jmp     LA39F

LA0DE:  rts

LA0DF:  lda     #$00
        sta     LA425
        ldy     #$05
LA0E6:  lda     LA04E,y
        sta     L97DD,y
        dey
        bpl     LA0E6
        rts

        lda     #$04
        sta     LA054
        jmp     LA100

        lda     #$04
        sta     LA054
        jmp     LA10A

LA100:  yax_call launch_dialog, index_lock_dialog, LA054
        rts

LA10A:  yax_call launch_dialog, index_unlock_dialog, LA054
        rts

LA114:  lda     #$03
        sta     LA054
        jsr     LA379
        ldx     $1FC0
        ldy     L9B32
        dey
LA123:  iny
        inx
        lda     $220,y
        sta     $1FC0,x
        cpy     $220
        bne     LA123
        stx     $1FC0
LA133:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     LA144
        jsr     LA49B
        jmp     LA133

LA144:  lda     file_info_params2::storage_type
        sta     LA169
        cmp     #ST_VOLUME_DIRECTORY
        beq     LA156
        cmp     #ST_LINKED_DIRECTORY
        beq     LA156
        lda     #$00
        beq     LA158
LA156:  lda     #$FF
LA158:  sta     LA168
        beq     LA16A
        jsr     L98D8
        lda     LA169
        cmp     #$0F
        bne     LA16A
        rts

LA168:  .byte   0
LA169:  .byte   0
LA16A:  jsr     LA173
        jmp     LA2FD

LA170:  jsr     LA2FD
LA173:  jsr     LA1C3
        jsr     LA2F1
LA179:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     LA18A
        jsr     LA49B
        jmp     LA179

LA18A:  lda     file_info_params2::storage_type
        cmp     #ST_VOLUME_DIRECTORY
        beq     LA1C0
        cmp     #ST_LINKED_DIRECTORY
        beq     LA1C0
        bit     L918B
        bpl     LA19E
        lda     #%11000011
        bne     LA1A0
LA19E:  lda     #$21
LA1A0:  sta     file_info_params2::access
LA1A3:  lda     #7              ; param count for SET_FILE_INFO
        sta     file_info_params2
        yax_call JT_MLI_RELAY, SET_FILE_INFO, file_info_params2
        pha
        lda     #$A             ; param count for GET_FILE_INFO
        sta     file_info_params2
        pla
        beq     LA1C0
        jsr     LA49B
        jmp     LA1A3

LA1C0:  jmp     LA322

LA1C3:  sub16  LA2ED, #$01, LA055
        bit     L918B
        bpl     LA1DC
        jmp     LA10A

LA1DC:  jmp     LA100

LA1DF:  .byte   0
        .addr   LA2ED, LA2EF

LA1E4:  lda     #$00
        sta     LA1DF
        copy16  #$A220, L9183
        copy16  #$A211, L917D
        yax_call launch_dialog, index_get_size_dialog, LA1DF
        copy16  #$A233, L9180
        rts

        lda     #$01
        sta     LA1DF
        yax_call launch_dialog, index_get_size_dialog, LA1DF
LA21F:  rts

        lda     #$02
        sta     LA1DF
        yax_call launch_dialog, index_get_size_dialog, LA1DF
        beq     LA21F
        jmp     LA39F

        lda     #$03
        sta     LA1DF
        yax_call launch_dialog, index_get_size_dialog, LA1DF
LA241:  rts

LA242:  .addr   LA2AE,rts2,rts2

LA248:  lda     #$00
        sta     LA425
        ldy     #$05
LA24F:  lda     LA242,y
        sta     L97DD,y
        dey
        bpl     LA24F
        lda     #$00
        sta     LA2ED
        sta     LA2EE
        sta     LA2EF
        sta     LA2F0
        ldy     #$17
        lda     #$00
LA26A:  sta     BITMAP,y
        dey
        bpl     LA26A
        rts

LA271:  jsr     LA379
LA274:  yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        beq     LA285
        jsr     LA49B
        jmp     LA274

LA285:  lda     file_info_params2::storage_type
        sta     LA2AA
        cmp     #ST_VOLUME_DIRECTORY
        beq     LA297
        cmp     #ST_LINKED_DIRECTORY
        beq     LA297
        lda     #$00
        beq     LA299
LA297:  lda     #$FF
LA299:  sta     LA2A9
        beq     LA2AB
        jsr     L98D8
        lda     LA2AA
        cmp     #$0F
        bne     LA2AB
        rts

LA2A9:  .byte   0
LA2AA:  .byte   0
LA2AB:  jmp     LA2AE

LA2AE:  bit     L9189
        bvc     LA2D4
        jsr     LA2FD
        yax_call JT_MLI_RELAY, GET_FILE_INFO, file_info_params2
        bne     LA2D4
        lda     LA2EF
        clc
        adc     file_info_params2::blocks_used
        sta     LA2EF
        lda     LA2F0
        adc     file_info_params2::blocks_used+1
        sta     LA2F0
LA2D4:  inc     LA2ED
        bne     LA2DC
        inc     LA2EE
LA2DC:  bit     L9189
        bvc     LA2E4
        jsr     LA322
LA2E4:  ldax    LA2ED
        jmp     L917C

LA2ED:  .byte   0
LA2EE:  .byte   0
LA2EF:  .byte   0
LA2F0:  .byte   0
LA2F1:  lda     LA2ED
        bne     LA2F9
        dec     LA2EE
LA2F9:  dec     LA2ED
        rts

LA2FD:  lda     L97AD
        bne     LA303
        rts

LA303:  ldx     #$00
        ldy     $220
        lda     #'/'
        sta     $0221,y
        iny
LA30E:  cpx     L97AD
        bcs     LA31E
        lda     L97AE,x
        sta     $0221,y
        inx
        iny
        jmp     LA30E

LA31E:  sty     $220
        rts

LA322:  ldx     $220
        bne     LA328
        rts

LA328:  lda     $220,x
        cmp     #$2F
        beq     LA336
        dex
        bne     LA328
        stx     $220
        rts

LA336:  dex
        stx     $220
        rts

LA33B:  lda     L97AD
        bne     LA341
        rts

LA341:  ldx     #$00
        ldy     $1FC0
        lda     #'/'
        sta     $1FC1,y
        iny
LA34C:  cpx     L97AD
        bcs     LA35C
        lda     L97AE,x
        sta     $1FC1,y
        inx
        iny
        jmp     LA34C

LA35C:  sty     $1FC0
        rts

LA360:  ldx     $1FC0
        bne     LA366
        rts

LA366:  lda     $1FC0,x
        cmp     #$2F
        beq     LA374
        dex
        bne     LA366
        stx     $1FC0
        rts

LA374:  dex
        stx     $1FC0
        rts

LA379:  ldy     #$00
        sty     L9B32
        dey
LA37F:  iny
        lda     $E00A,y
        cmp     #$2F
        bne     LA38A
        sty     L9B32
LA38A:  sta     $220,y
        cpy     $E00A
        bne     LA37F
        ldy     LDFC9
LA395:  lda     LDFC9,y
        sta     $1FC0,y
        dey
        bpl     LA395
        rts

LA39F:  jsr     L917F
        jmp     LA3A7

.proc close_params4
param_count:    .byte   1
ref_num:        .byte   0
.endproc

LA3A7:  yax_call JT_MLI_RELAY, CLOSE, close_params4
        lda     selected_window_index
        beq     LA3CA
        sta     getwinport_params2::window_id
        yax_call JT_MGTK_RELAY, MGTK::GetWinPort, getwinport_params2
        yax_call JT_MGTK_RELAY, MGTK::SetPort, grafport2
LA3CA:  ldx     L9188
        txs
        lda     #$FF
        rts

LA3D1:  yax_call JT_MGTK_RELAY, MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_key_down
        bne     LA3EC
        lda     event_params_key
        cmp     #KEY_ESCAPE
        bne     LA3EC
        lda     #$FF
        bne     LA3EE
LA3EC:  lda     #$00
LA3EE:  rts

LA3EF:  sub16  LA2ED, #$01, L9E7A
        yax_call launch_dialog, index_delete_file_dialog, L9E79
        rts

LA40A:  sub16  LA2ED, #$01, L9938
        yax_call launch_dialog, index_copy_file_dialog, L9937
        rts

LA425:  .byte   0
LA426:  jsr     LA46D
        lda     #$C3
        sta     file_info_params3::access
        jsr     LA479
        lda     file_info_params2::file_type
        cmp     #$0F
        beq     LA46C
        yax_call JT_MLI_RELAY, OPEN, open_params5
        beq     LA449
        jsr     LA497
        jmp     LA426

LA449:  lda     open_params5::ref_num
        sta     set_eof_params::ref_num
        sta     close_params3::ref_num
LA452:  yax_call JT_MLI_RELAY, SET_EOF, set_eof_params
        beq     LA463
        jsr     LA497
        jmp     LA452

LA463:  yax_call JT_MLI_RELAY, CLOSE, close_params3
LA46C:  rts

LA46D:  ldx     #$0A
LA46F:  lda     file_info_params2::access,x
        sta     file_info_params3::access,x
        dex
        bpl     LA46F
        rts

LA479:  lda     #7              ; SET_FILE_INFO param_count
        sta     file_info_params3
        yax_call JT_MLI_RELAY, SET_FILE_INFO, file_info_params3
        pha
        lda     #$A             ; GET_FILE_INFO param_count
        sta     file_info_params3
        pla
        beq     LA496
        jsr     LA497
        jmp     LA479

LA496:  rts

LA497:  ldx     #$80
        bne     LA49D
LA49B:  ldx     #$00
LA49D:  stx     LA4C5
        cmp     #$45
        beq     LA4AE
        cmp     #$44
        beq     LA4AE
        jsr     JT_SHOW_ALERT0
        bne     LA4C2
        rts

LA4AE:  bit     LA4C5
        bpl     LA4B8
        lda     #$FD
        jmp     LA4BA

LA4B8:  lda     #$FC
LA4BA:  jsr     JT_SHOW_ALERT0
        bne     LA4C2
        jmp     LA4C6

LA4C2:  jmp     LA39F

LA4C5:  .byte   0
LA4C6:  yax_call JT_MLI_RELAY, ON_LINE, on_line_params2
        rts

        .assert * = $A4D0, error, "Segment length mismatch"
        PAD_TO $A500

;;; ==================================================
;;; Dialog Launcher (or just proc handler???)

        index_about_dialog              := 0
        index_copy_file_dialog          := 1
        index_delete_file_dialog        := 2
        index_new_folder_dialog         := 3
        index_get_info_dialog           := 6
        index_lock_dialog               := 7
        index_unlock_dialog             := 8
        index_rename_dialog             := 9
        index_download_dialog           := $A
        index_get_size_dialog           := $B
        index_warning_dialog            := $C

launch_dialog:
        jmp     LA520

LA503:  .addr   show_about_dialog
        .addr   show_copy_file_dialog
        .addr   show_delete_file_dialog
        .addr   show_new_folder_dialog
        .addr   rts1
        .addr   rts1
        .addr   show_get_info_dialog
        .addr   show_lock_dialog
        .addr   show_unlock_dialog
        .addr   show_rename_dialog
        .addr   show_download_dialog
        .addr   show_get_size_dialog
        .addr   show_warning_dialog

dialog_param_addr:  .addr   0
        .byte   0

LA520:  stax    dialog_param_addr
        tya
        asl     a
        tax
        copy16  LA503,x, LA565
        lda     #$00
        sta     LD8EB
        sta     LD8EC
        sta     LD8F0
        sta     LD8F1
        sta     LD8F2
        sta     LD8E8
        sta     LD8F5
        sta     LD8ED
        sta     cursor_ip_flag
        lda     #$14
        sta     LD8E9
        lda     #<rts1
        sta     jump_relay+1
        lda     #>rts1
        sta     jump_relay+2
        jsr     set_cursor_pointer

        LA565 := *+1
        jmp     dummy0000       ; self-modified


;;; ==================================================
;;; Message handler for OK/Cancel dialog

prompt_input_loop:
        lda     LD8E8
        beq     LA579
        dec     LD8E9
        bne     LA579
        jsr     LB8F5
        lda     #$14
        sta     LD8E9
LA579:  MGTK_RELAY_CALL MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_down
        bne     LA58C
        jmp     prompt_click_handler

LA58C:  cmp     #MGTK::event_kind_key_down
        bne     LA593
        jmp     prompt_key_handler

LA593:  lda     LD8E8
        beq     prompt_input_loop
        MGTK_RELAY_CALL MGTK::FindWindow, event_params_coords
        lda     findwindow_params_which_area
        bne     LA5A9
        jmp     prompt_input_loop

LA5A9:  lda     $D20E
        cmp     winfoF
        beq     LA5B4
        jmp     prompt_input_loop

LA5B4:  lda     winfoF
        jsr     set_port_from_window_id
        lda     winfoF
        sta     event_params
        MGTK_RELAY_CALL MGTK::ScreenToWindow, event_params
        MGTK_RELAY_CALL MGTK::MoveTo, $D20D
        MGTK_RELAY_CALL MGTK::InRect, rect1
        cmp     #MGTK::inrect_inside
        bne     LA5E5
        jsr     set_cursor_insertion_point_with_flag
        jmp     LA5E8

LA5E5:  jsr     set_cursor_pointer_with_flag
LA5E8:  jsr     reset_state
        jmp     prompt_input_loop

;;; Click handler for prompt dialog

prompt_click_handler:
        MGTK_RELAY_CALL MGTK::FindWindow, event_params_coords
        lda     findwindow_params_which_area
        bne     LA5FF
        lda     #$FF
        rts

LA5FF:  cmp     #$02
        bne     LA606
        jmp     LA609

LA606:  lda     #$FF
        rts

LA609:  lda     $D20E
        cmp     winfoF
        beq     LA614
        lda     #$FF
        rts

LA614:  lda     winfoF
        jsr     set_port_from_window_id
        lda     winfoF
        sta     event_params
        MGTK_RELAY_CALL MGTK::ScreenToWindow, event_params
        MGTK_RELAY_CALL MGTK::MoveTo, $D20D
        bit     LD8E7
        bvc     LA63A
        jmp     check_button_yes

LA63A:  MGTK_RELAY_CALL MGTK::InRect, desktop_aux::ok_button_rect
        cmp     #MGTK::inrect_inside
        beq     check_button_ok
        jmp     maybe_check_button_cancel

        prompt_button_ok := 0
        prompt_button_cancel := 1
        prompt_button_yes := 2
        prompt_button_no := 3
        prompt_button_all := 4

check_button_ok:
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        jsr     button_loop_ok
        bmi     :+
        lda     #prompt_button_ok
:       rts

check_button_yes:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::yes_button_rect
        cmp     #MGTK::inrect_inside
        bne     check_button_no
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::yes_button_rect
        jsr     button_loop_yes
        bmi     :+
        lda     #prompt_button_yes
:       rts

check_button_no:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::no_button_rect
        cmp     #MGTK::inrect_inside
        bne     check_button_all
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::no_button_rect
        jsr     button_loop_no
        bmi     :+
        lda     #prompt_button_no
:       rts

check_button_all:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::all_button_rect
        cmp     #MGTK::inrect_inside
        bne     maybe_check_button_cancel
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::all_button_rect
        jsr     button_loop_all
        bmi     :+
        lda     #prompt_button_all
:       rts

maybe_check_button_cancel:
        bit     LD8E7
        bpl     check_button_cancel
        lda     #$FF
        rts

check_button_cancel:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::cancel_button_rect
        cmp     #MGTK::inrect_inside
        beq     :+
        jmp     LA6ED
:       jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        jsr     button_loop_cancel
        bmi     :+
        lda     #prompt_button_cancel
:       rts

LA6ED:  bit     LD8E8
        bmi     LA6F7
        lda     #$FF
        jmp     jump_relay

LA6F7:  jsr     LB9B8
        lda     #$FF
        rts

;;; Key handler for prompt dialog

prompt_key_handler:
        lda     event_params_modifiers
        cmp     #MGTK::event_modifier_solid_apple
        bne     LA71A
        lda     event_params_key
        and     #$7F
        cmp     #KEY_LEFT
        bne     LA710
        jmp     LA815

LA710:  cmp     #KEY_RIGHT
        bne     LA717
        jmp     LA820

LA717:  lda     #$FF
        rts

LA71A:  lda     event_params_key
        and     #$7F
        cmp     #KEY_LEFT
        bne     LA72E
        bit     LD8ED
        bpl     LA72B
        jmp     L0CB8

LA72B:  jmp     LA82B

LA72E:  cmp     #KEY_RIGHT
        bne     LA73D
        bit     LD8ED
        bpl     LA73A
        jmp     L0CD7

LA73A:  jmp     LA83E

LA73D:  cmp     #KEY_RETURN
        bne     LA749
        bit     LD8E7
        bvs     LA717
        jmp     LA851

LA749:  cmp     #KEY_ESCAPE
        bne     LA755
        bit     LD8E7
        bmi     LA717
        jmp     LA86F

LA755:  cmp     #KEY_DELETE
        bne     LA75C
        jmp     LA88D

LA75C:  cmp     #KEY_UP
        bne     LA76B
        bit     LD8ED
        bmi     LA768
        jmp     LA717

LA768:  jmp     L0D14

LA76B:  cmp     #KEY_DOWN
        bne     LA77A
        bit     LD8ED
        bmi     LA777
        jmp     LA717

LA777:  jmp     L0CF9

LA77A:  bit     LD8E7
        bvc     LA79B
        cmp     #'Y'
        beq     LA7E8
        cmp     #'y'
        beq     LA7E8
        cmp     #'N'
        beq     LA7F7
        cmp     #'n'
        beq     LA7F7
        cmp     #'A'
        beq     LA806
        cmp     #'a'
        beq     LA806
        cmp     #KEY_RETURN
        beq     LA7E8
LA79B:  bit     LD8F5
        bmi     LA7C8
        cmp     #$2E
        beq     LA7D8
        cmp     #$30
        bcs     LA7AB
        jmp     LA717

LA7AB:  cmp     #$7B
        bcc     LA7B2
        jmp     LA717

LA7B2:  cmp     #$3A
        bcc     LA7D8
        cmp     #$41
        bcs     LA7BD
        jmp     LA717

LA7BD:  cmp     #$5B
        bcc     LA7DD
        cmp     #$61
        bcs     LA7DD
        jmp     LA717

LA7C8:  cmp     #$20
        bcs     LA7CF
        jmp     LA717

LA7CF:  cmp     #$7E
        beq     LA7DD
        bcc     LA7DD
        jmp     LA717

LA7D8:  ldx     path_buf1
        beq     LA7E5
LA7DD:  ldx     LD8E8
        beq     LA7E5
        jsr     LBB0B
LA7E5:  lda     #$FF
        rts

LA7E8:  jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::yes_button_rect
        lda     #$02
        rts

LA7F7:  jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::no_button_rect
        lda     #$03
        rts

LA806:  jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::all_button_rect
        lda     #$04
        rts

LA815:  lda     LD8E8
        beq     LA81D
        jsr     LBC5E
LA81D:  lda     #$FF
        rts

LA820:  lda     LD8E8
        beq     LA828
        jsr     LBCC9
LA828:  lda     #$FF
        rts

LA82B:  lda     LD8E8
        beq     LA83B
        bit     LD8ED
        bpl     LA838
        jmp     L0CD7

LA838:  jsr     LBBA4
LA83B:  lda     #$FF
        rts

LA83E:  lda     LD8E8
        beq     LA84E
        bit     LD8ED
        bpl     LA84B
        jmp     L0CB8

LA84B:  jsr     LBC03
LA84E:  lda     #$FF
        rts

LA851:  lda     winfoF
        jsr     set_port_from_window_id
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        lda     #$00
        rts

LA86F:  lda     winfoF
        jsr     set_port_from_window_id
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        lda     #$01
        rts

LA88D:  lda     LD8E8
        beq     LA895
        jsr     LBB63
LA895:  lda     #$FF
        rts

rts1:
        rts

jump_relay:
        jmp     dummy0000


;;; ==================================================
;;; "About" dialog

.proc show_about_dialog
        MGTK_RELAY_CALL MGTK::OpenWindow, winfo18
        lda     winfo18::window_id
        jsr     set_port_from_window_id
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::about_dialog_outer_rect
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::about_dialog_inner_rect
        addr_call draw_centered_string, desktop_aux::str_about1
        axy_call draw_dialog_label, $81, desktop_aux::str_about2
        axy_call draw_dialog_label, $82, desktop_aux::str_about3
        axy_call draw_dialog_label, $83, desktop_aux::str_about4
        axy_call draw_dialog_label, $05, desktop_aux::str_about5
        axy_call draw_dialog_label, $86, desktop_aux::str_about6
        axy_call draw_dialog_label, $07, desktop_aux::str_about7
        axy_call draw_dialog_label, $09, desktop_aux::str_about8
        copy16  #$136, dialog_label_pos
        axy_call draw_dialog_label, $09, desktop_aux::str_about9
        copy16  #$28, dialog_label_pos

:       MGTK_RELAY_CALL MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_down
        beq     close
        cmp     #MGTK::event_kind_key_down
        bne     :-
        lda     event_params_key
        and     #$7F
        cmp     #KEY_ESCAPE
        beq     close
        cmp     #KEY_RETURN
        bne     :-
        jmp     close

close:  MGTK_RELAY_CALL MGTK::CloseWindow, winfo18
        jsr     reset_state
        jsr     set_cursor_pointer_with_flag
        rts
.endproc

;;; ==================================================

show_copy_file_dialog:

        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        cmp     #$01
        bne     LA965
        jmp     LA9B5

LA965:  cmp     #$02
        bne     LA96C
        jmp     LA9E6

LA96C:  cmp     #$03
        bne     LA973
        jmp     LAA6A

LA973:  cmp     #$04
        bne     LA97A
        jmp     LAA9C

LA97A:  cmp     #$05
        bne     LA981
        jmp     LAA5A

LA981:  lda     #$00
        sta     LD8E8
        jsr     LB53A
        addr_call draw_centered_string, desktop_aux::str_copy_title
        axy_call draw_dialog_label, $01, desktop_aux::str_copy_copying
        axy_call draw_dialog_label, $02, desktop_aux::str_copy_from
        axy_call draw_dialog_label, $03, desktop_aux::str_copy_to
        axy_call draw_dialog_label, $04, desktop_aux::str_copy_remaining
        rts

LA9B5:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB0B6
        addr_call draw_text1, str_7_spaces
        addr_call draw_text1, str_files
        rts

LA9E6:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     LBE8D
        jsr     LBE9A
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$03
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        sta     $06+1
        stx     $06
        jsr     LBE63
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LAE7E
        addr_call draw_text1, path_buf0
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$05
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        sta     $06+1
        stx     $06
        jsr     LBE78
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LAE82
        addr_call draw_text1, path_buf1
        yax_call MGTK_RELAY, MGTK::MoveTo, desktop_aux::LB0BA
        addr_call draw_text1, str_7_spaces
        rts

LAA5A:  jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        rts

LAA6A:  jsr     bell
        lda     winfoF
        jsr     set_port_from_window_id
        axy_call draw_dialog_label, $06, desktop_aux::str_exists_prompt
        jsr     draw_yes_no_all_cancel_buttons
LAA7F:  jsr     prompt_input_loop
        bmi     LAA7F
        pha
        jsr     erase_yes_no_all_cancel_buttons
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::prompt_rect
        pla
        rts

LAA9C:  jsr     bell
        lda     winfoF
        jsr     set_port_from_window_id
        axy_call draw_dialog_label, $06, desktop_aux::str_large_prompt
        jsr     draw_ok_cancel_buttons
LAAB1:  jsr     prompt_input_loop
        bmi     LAAB1
        pha
        jsr     erase_ok_cancel_buttons
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::prompt_rect
        pla
        rts

.proc bell
        sta     ALTZPOFF
        sta     ROMIN2
        jsr     BELL1
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        rts
.endproc

;;; ==================================================
;;; "DownLoad" dialog

.proc show_download_dialog
        ptr := $6

        jsr     copy_dialog_param_addr_to_ptr
        ldy     #0
        lda     (ptr),y
        cmp     #1
        bne     :+
        jmp     do1
:       cmp     #2
        bne     :+
        jmp     do2
:       cmp     #3
        bne     :+
        jmp     do3
:       cmp     #4
        bne     else
        jmp     do4

else:   lda     #0
        sta     LD8E8
        jsr     LB53A
        addr_call draw_centered_string, desktop_aux::str_download
        axy_call draw_dialog_label, $01, desktop_aux::str_copy_copying
        axy_call draw_dialog_label, $02, desktop_aux::str_copy_from
        axy_call draw_dialog_label, $03, desktop_aux::str_copy_to
        axy_call draw_dialog_label, $04, desktop_aux::str_copy_remaining
        rts

do1:    ldy     #1
        lda     (ptr),y
        sta     LD909
        iny
        lda     (ptr),y
        sta     LD909+1
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB0B6
        addr_call draw_text1, str_7_spaces
        addr_call draw_text1, str_files
        rts

do2:    ldy     #$01
        lda     (ptr),y
        sta     LD909
        iny
        lda     (ptr),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     LBE8D
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$03
        lda     (ptr),y
        tax
        iny
        lda     (ptr),y
        sta     ptr+1
        stx     ptr
        jsr     LBE63
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LAE7E
        addr_call draw_text1, path_buf0
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB0BA
        addr_call draw_text1, str_7_spaces
        rts

do3:    jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        rts

do4:    jsr     bell
        lda     winfoF
        jsr     set_port_from_window_id
        axy_call draw_dialog_label, ptr, desktop_aux::str_ramcard_full
        jsr     draw_ok_button
:       jsr     prompt_input_loop
        bmi     :-
        pha
        jsr     erase_ok_button
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::prompt_rect
        pla
        rts
.endproc

;;; ==================================================
;;; "Get Size" dialog

.proc show_get_size_dialog
        ptr := $6

        jsr     copy_dialog_param_addr_to_ptr
        ldy     #0
        lda     (ptr),y
        cmp     #1
        bne     :+
        jmp     do1
:       cmp     #2
        bne     :+
        jmp     do2
:       cmp     #3
        bne     else
        jmp     do3

else:   jsr     LB53A
        addr_call draw_centered_string, desktop_aux::str_size_title
        axy_call draw_dialog_label, $01, desktop_aux::str_size_number
        ldy     #1
        jsr     draw_colon
        axy_call draw_dialog_label, $02, desktop_aux::str_size_blocks
        ldy     #2
        jsr     draw_colon
        rts

do1:    ldy     #$01
        lda     (ptr),y
        sta     LD909
        tax
        iny
        lda     (ptr),y
        sta     ptr+1
        stx     ptr
        ldy     #$00
        lda     (ptr),y
        sta     LD909
        iny
        lda     (ptr),y
        sta     LD90A
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        lda     #$A5
        sta     dialog_label_pos
        yax_call draw_dialog_label, $01, str_7_spaces
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$03
        lda     (ptr),y
        tax
        iny
        lda     (ptr),y
        sta     ptr+1
        stx     ptr
        ldy     #$00
        lda     (ptr),y
        sta     LD909
        iny
        lda     (ptr),y
        sta     LD90A
        jsr     LBDDF
        lda     #$A5
        sta     dialog_label_pos
        yax_call draw_dialog_label, $02, str_7_spaces
        rts

do3:    jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        rts

do2:    lda     winfoF
        jsr     set_port_from_window_id
        jsr     draw_ok_button
:       jsr     prompt_input_loop
        bmi     :-
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::press_ok_to_rect
        jsr     erase_ok_button
        lda     #$00
        rts
.endproc

;;; ==================================================
;;; "Delete File" dialog

show_delete_file_dialog:
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        cmp     #$01
        bne     LACE2
        jmp     LAD2A

LACE2:  cmp     #$02
        bne     LACE9
        jmp     LADBB

LACE9:  cmp     #$03
        bne     LACF0
        jmp     LAD6C

LACF0:  cmp     #$04
        bne     LACF7
        jmp     LAE05

LACF7:  cmp     #$05
        bne     LACFE
        jmp     LADF5

LACFE:  sta     LAD1F
        lda     #$00
        sta     LD8E8
        jsr     LB53A
        addr_call draw_centered_string, desktop_aux::str_delete_title
        lda     LAD1F
        beq     LAD20
        axy_call draw_dialog_label, $04, desktop_aux::str_ok_empty
        rts

LAD1F:  .byte   0
LAD20:  axy_call draw_dialog_label, $04, desktop_aux::str_delete_ok
        rts

LAD2A:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        lda     LAD1F
        bne     LAD54
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB16A
        jmp     LAD5D

LAD54:  MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB172
LAD5D:  addr_call draw_text1, str_7_spaces
        addr_call draw_text1, str_files
        rts

LAD6C:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     LBE8D
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$03
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        sta     $06+1
        stx     $06
        jsr     LBE63
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LAE7E
        addr_call draw_text1, path_buf0
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB16E
        addr_call draw_text1, str_7_spaces
        rts

LADBB:  lda     winfoF
        jsr     set_port_from_window_id
        jsr     draw_ok_cancel_buttons
LADC4:  jsr     prompt_input_loop
        bmi     LADC4
        bne     LADF4
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::press_ok_to_rect
        jsr     erase_ok_cancel_buttons
        yax_call draw_dialog_label, $02, desktop_aux::str_file_colon
        yax_call draw_dialog_label, $04, desktop_aux::str_delete_remaining
        lda     #$00
LADF4:  rts

LADF5:  jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        rts

LAE05:  lda     winfoF
        jsr     set_port_from_window_id
        axy_call draw_dialog_label, $06, desktop_aux::str_delete_locked_file
        jsr     draw_yes_no_all_cancel_buttons
LAE17:  jsr     prompt_input_loop
        bmi     LAE17
        pha
        jsr     erase_yes_no_all_cancel_buttons
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy ; white
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::prompt_rect ; erase prompt
        pla
        rts

;;; ==================================================
;;; "New Folder" dialog

show_new_folder_dialog:
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        cmp     #$80
        bne     LAE42
        jmp     LAE70

LAE42:  cmp     #$40
        bne     LAE49
        jmp     LAF16

LAE49:  lda     #$80
        sta     LD8E8
        jsr     LBD69
        lda     #$00
        jsr     LB509
        lda     winfoF
        jsr     set_port_from_window_id
        addr_call draw_centered_string, desktop_aux::str_new_folder_title
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, rect1
        rts

LAE70:  lda     #$80
        sta     LD8E8
        lda     #$00
        sta     LD8E7
        jsr     LBD75
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$01
        lda     ($06),y
        sta     $08
        iny
        lda     ($06),y
        sta     $08+1
        ldy     #$00
        lda     ($08),y
        tay
LAE90:  lda     ($08),y
        sta     path_buf0,y
        dey
        bpl     LAE90
        lda     winfoF
        jsr     set_port_from_window_id
        yax_call draw_dialog_label, $02, desktop_aux::str_in_colon
        lda     #$37
        sta     dialog_label_pos
        yax_call draw_dialog_label, $02, path_buf0
        lda     #$28
        sta     dialog_label_pos
        yax_call draw_dialog_label, $04, desktop_aux::str_enter_folder_name
        jsr     LB961
LAEC6:  jsr     prompt_input_loop
        bmi     LAEC6
        bne     LAF16
        lda     path_buf1
        beq     LAEC6
        cmp     #$10
        bcc     LAEE1
LAED6:  lda     #$FB
        jsr     JT_SHOW_ALERT0
        jsr     LB961
        jmp     LAEC6

LAEE1:  lda     path_buf0
        clc
        adc     path_buf1
        clc
        adc     #$01
        cmp     #$41
        bcs     LAED6
        inc     path_buf0
        ldx     path_buf0
        lda     #'/'
        sta     path_buf0,x
        ldx     path_buf0
        ldy     #$00
LAEFF:  inx
        iny
        lda     path_buf1,y
        sta     path_buf0,x
        cpy     path_buf1
        bne     LAEFF
        stx     path_buf0
        ldy     #<path_buf0
        ldx     #>path_buf0
        lda     #0
        rts

LAF16:  jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        lda     #$01
        rts

;;; ==================================================
;;; "Get Info" dialog

show_get_info_dialog:
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        bmi     LAF34
        jmp     LAFB9

LAF34:  lda     #$00
        sta     LD8E8
        lda     ($06),y
        lsr     a
        lsr     a
        ror     a
        eor     #$80
        jsr     LB509
        lda     winfoF
        jsr     set_port_from_window_id
        addr_call draw_centered_string, desktop_aux::str_info_title
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        and     #$7F
        lsr     a
        ror     a
        sta     LB01D
        yax_call draw_dialog_label, $01, desktop_aux::str_info_name
        bit     LB01D
        bmi     LAF78
        yax_call draw_dialog_label, $02, desktop_aux::str_info_locked
        jmp     LAF81

LAF78:  yax_call draw_dialog_label, $02, desktop_aux::str_info_protected
LAF81:  bit     LB01D
        bpl     LAF92
        yax_call draw_dialog_label, $03, desktop_aux::str_info_blocks
        jmp     LAF9B

LAF92:  yax_call draw_dialog_label, $03, desktop_aux::str_info_size
LAF9B:  yax_call draw_dialog_label, $04, desktop_aux::str_info_create
        yax_call draw_dialog_label, $05, desktop_aux::str_info_mod
        yax_call draw_dialog_label, $06, desktop_aux::str_info_type
        jmp     reset_state

LAFB9:  lda     winfoF
        jsr     set_port_from_window_id
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        sta     LB01E
        tay
        jsr     draw_colon
        lda     #$A5
        sta     dialog_label_pos
        jsr     copy_dialog_param_addr_to_ptr
        lda     LB01E
        cmp     #$02
        bne     LAFF0
        ldy     #$01
        lda     ($06),y
        beq     LAFE9
        addr_jump LAFF8, desktop_aux::str_yes_label

LAFE9:  addr_jump LAFF8, desktop_aux::str_no_label

LAFF0:  ldy     #$02
        lda     ($06),y
        tax
        dey
        lda     ($06),y
LAFF8:  ldy     LB01E
        jsr     draw_dialog_label
        lda     LB01E
        cmp     #$06
        beq     LB006
        rts

LB006:  jsr     prompt_input_loop
        bmi     LB006
        pha
        jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer_with_flag
        pla
        rts

LB01D:  .byte   0
LB01E:  .byte   0

;;; ==================================================
;;; Draw ":" after dialog label

.proc draw_colon
        lda     #$A0
        sta     dialog_label_pos
        ldax    #desktop_aux::str_colon
        jsr     draw_dialog_label
        rts
.endproc

;;; ==================================================
;;; "Lock" dialog

show_lock_dialog:
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        cmp     #$01
        bne     LB03A
        jmp     LB068

LB03A:  cmp     #$02
        bne     LB041
        jmp     LB0F1

LB041:  cmp     #$03
        bne     LB048
        jmp     LB0A2

LB048:  cmp     #$04
        bne     LB04F
        jmp     LB13A

LB04F:  lda     #$00
        sta     LD8E8
        jsr     LB53A
        addr_call draw_centered_string, desktop_aux::str_lock_title
        yax_call draw_dialog_label, $04, desktop_aux::str_lock_ok
        rts

LB068:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB231
        addr_call draw_text1, str_7_spaces
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB239
        addr_call draw_text1, str_files
        rts

LB0A2:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     LBE8D
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$03
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        sta     $06+1
        stx     $06
        jsr     LBE63
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LAE7E
        addr_call draw_text1, path_buf0
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB241
        addr_call draw_text1, str_7_spaces
        rts

LB0F1:  lda     winfoF
        jsr     set_port_from_window_id
        jsr     draw_ok_cancel_buttons
LB0FA:  jsr     prompt_input_loop
        bmi     LB0FA
        bne     LB139
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::press_ok_to_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        yax_call draw_dialog_label, $02, desktop_aux::str_file_colon
        yax_call draw_dialog_label, $04, desktop_aux::str_lock_remaining
        lda     #$00
LB139:  rts

LB13A:  jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        rts

;;; ==================================================
;;; "Unlock" dialog

show_unlock_dialog:
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        cmp     #$01
        bne     LB158
        jmp     LB186

LB158:  cmp     #$02
        bne     LB15F
        jmp     LB20F

LB15F:  cmp     #$03
        bne     LB166
        jmp     LB1C0

LB166:  cmp     #$04
        bne     LB16D
        jmp     LB258

LB16D:  lda     #$00
        sta     LD8E8
        jsr     LB53A
        addr_call draw_centered_string, desktop_aux::str_unlock_title
        yax_call draw_dialog_label, $04, desktop_aux::str_unlock_ok
        rts

LB186:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB22D
        addr_call draw_text1, str_7_spaces
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB235
        addr_call draw_text1, str_files
        rts

LB1C0:  ldy     #$01
        lda     ($06),y
        sta     LD909
        iny
        lda     ($06),y
        sta     LD90A
        jsr     LBDC4
        jsr     LBDDF
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     LBE8D
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$03
        lda     ($06),y
        tax
        iny
        lda     ($06),y
        sta     $06+1
        stx     $06
        jsr     LBE63
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LAE7E
        addr_call draw_text1, path_buf0
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::LB23D
        addr_call draw_text1, str_7_spaces
        rts

LB20F:  lda     winfoF
        jsr     set_port_from_window_id
        jsr     draw_ok_cancel_buttons
LB218:  jsr     prompt_input_loop
        bmi     LB218
        bne     LB257
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::press_ok_to_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        yax_call draw_dialog_label, $02, desktop_aux::str_file_colon
        yax_call draw_dialog_label, $04, desktop_aux::str_unlock_remaining
        lda     #$00
LB257:  rts

LB258:  jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        rts

;;; ==================================================
;;; "Rename" dialog

show_rename_dialog:
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$00
        lda     ($06),y
        cmp     #$80
        bne     LB276
        jmp     LB2ED

LB276:  cmp     #$40
        bne     LB27D
        jmp     LB313

LB27D:  jsr     LBD75
        jsr     copy_dialog_param_addr_to_ptr
        lda     #$80
        sta     LD8E8
        jsr     LBD69
        lda     #$00
        jsr     LB509
        lda     winfoF
        jsr     set_port_from_window_id
        addr_call draw_centered_string, desktop_aux::str_rename_title
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, rect1
        yax_call draw_dialog_label, $02, desktop_aux::str_rename_old
        lda     #$55
        sta     dialog_label_pos
        jsr     copy_dialog_param_addr_to_ptr
        ldy     #$01
        lda     ($06),y
        sta     $08
        iny
        lda     ($06),y
        sta     $08+1
        ldy     #$00
        lda     ($08),y
        tay
LB2CA:  lda     ($08),y
        sta     buf_filename,y
        dey
        bpl     LB2CA
        yax_call draw_dialog_label, $02, buf_filename
        yax_call draw_dialog_label, $04, desktop_aux::str_rename_new
        lda     #$00
        sta     path_buf1
        jsr     LB961
        rts

LB2ED:  lda     #$00
        sta     LD8E7
        lda     #$80
        sta     LD8E8
        lda     winfoF
        jsr     set_port_from_window_id
LB2FD:  jsr     prompt_input_loop
        bmi     LB2FD
        bne     LB313
        lda     path_buf1
        beq     LB2FD
        jsr     LBCC9
        ldy     #$43
        ldx     #$D4
        lda     #$00
        rts

LB313:  jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        lda     #$01
        rts

;;; ==================================================
;;; "Warning!" dialog
;;; $6/$7 ptr to message num

.proc show_warning_dialog
        ptr := $6

        ;; Create window
        MGTK_RELAY_CALL MGTK::HideCursor
        jsr     create_window_with_alert_bitmap
        lda     winfoF
        jsr     set_port_from_window_id
        addr_call draw_centered_string, desktop_aux::str_warning
        MGTK_RELAY_CALL MGTK::ShowCursor
        jsr     copy_dialog_param_addr_to_ptr

        ;; Dig up message
        ldy     #$00
        lda     (ptr),y
        pha
        bmi     only_ok         ; high bit set means no cancel
        tax
        lda     warning_cancel_table,x
        bne     ok_and_cancel

only_ok:                        ; no cancel button
        pla
        and     #$7F
        pha
        jsr     draw_ok_button
        jmp     draw_string

ok_and_cancel:                  ; has cancel button
        jsr     draw_ok_cancel_buttons

draw_string:
        ;; First string
        pla
        pha
        asl     a               ; * 2
        asl     a               ; * 4, since there are two strings each
        tay
        lda     warning_message_table+1,y
        tax
        lda     warning_message_table,y
        ldy     #$03
        jsr     draw_dialog_label

        ;; Second string
        pla
        asl     a
        asl     a
        tay
        lda     warning_message_table+2+1,y
        tax
        lda     warning_message_table+2,y
        ldy     #$04
        jsr     draw_dialog_label

        ;; Input loop
:       jsr     prompt_input_loop
        bmi     :-

        pha
        jsr     reset_state
        MGTK_RELAY_CALL MGTK::CloseWindow, winfoF
        jsr     set_cursor_pointer
        pla
        rts

        ;; high bit set if "cancel" should be an option
warning_cancel_table:
        .byte   $80,$00,$00,$80,$00,$00,$80

warning_message_table:
        .addr   desktop_aux::str_insert_system_disk,desktop_aux::str_1_space
        .addr   desktop_aux::str_selector_list_full,desktop_aux::str_before_new_entries
        .addr   desktop_aux::str_selector_list_full,desktop_aux::str_before_new_entries
        .addr   desktop_aux::str_window_must_be_closed,desktop_aux::str_1_space
        .addr   desktop_aux::str_window_must_be_closed,desktop_aux::str_1_space
        .addr   desktop_aux::str_too_many_windows,desktop_aux::str_1_space
        .addr   desktop_aux::str_save_selector_list,desktop_aux::str_on_system_disk
.endproc
        warning_msg_insert_system_disk          := 0
        warning_msg_selector_list_full          := 1
        warning_msg_selector_list_full2         := 2
        warning_msg_window_must_be_closed       := 3
        warning_msg_window_must_be_closed2      := 4
        warning_msg_too_many_windows            := 5
        warning_msg_save_selector_list          := 6

;;; ==================================================

.proc copy_dialog_param_addr_to_ptr
        copy16  dialog_param_addr, $06
        rts
.endproc

.proc set_cursor_pointer_with_flag
        bit     cursor_ip_flag
        bpl     :+
        jsr     set_cursor_pointer
        lda     #$00
        sta     cursor_ip_flag
:       rts
.endproc

.proc set_cursor_insertion_point_with_flag
        bit     cursor_ip_flag
        bmi     :+
        jsr     set_cursor_insertion_point
        lda     #$80
        sta     cursor_ip_flag
:       rts
.endproc

cursor_ip_flag:                 ; high bit set if IP, clear if pointer
        .byte   0

set_cursor_watch:
        MGTK_RELAY_CALL MGTK::HideCursor
        MGTK_RELAY_CALL MGTK::SetCursor, watch_cursor
        MGTK_RELAY_CALL MGTK::ShowCursor
        rts

set_cursor_pointer:
        MGTK_RELAY_CALL MGTK::HideCursor
        MGTK_RELAY_CALL MGTK::SetCursor, pointer_cursor
        MGTK_RELAY_CALL MGTK::ShowCursor
        rts

set_cursor_insertion_point:
        MGTK_RELAY_CALL MGTK::HideCursor
        MGTK_RELAY_CALL MGTK::SetCursor, insertion_point_cursor
        MGTK_RELAY_CALL MGTK::ShowCursor
        rts

set_penmode_xor2:
        MGTK_RELAY_CALL MGTK::SetPenMode, penXOR
        rts

        ldx     #$03
LB447:  lda     event_params_coords,x
        sta     LB502,x
        dex
        bpl     LB447
        lda     #$00
        sta     LB501
        lda     machine_type
        asl     a
        sta     LB500
        rol     LB501
LB45F:  dec     LB500
        lda     LB500
        cmp     #$FF
        bne     LB46C
        dec     LB501
LB46C:  lda     LB501
        bne     LB476
        lda     LB500
        beq     LB4B7
LB476:  MGTK_RELAY_CALL MGTK::PeekEvent, event_params
        jsr     LB4BA
        bmi     LB4B7
        lda     #$FF
        sta     LB508
        lda     event_params_kind
        sta     LB507
        cmp     #MGTK::event_kind_no_event
        beq     LB45F
        cmp     #MGTK::event_kind_drag
        beq     LB45F
        cmp     #MGTK::event_kind_button_up
        bne     LB4A7
        MGTK_RELAY_CALL MGTK::GetEvent, event_params
        jmp     LB45F

LB4A7:  cmp     #$01
        bne     LB4B7
        MGTK_RELAY_CALL MGTK::GetEvent, event_params
        lda     #$00
        rts

LB4B7:  lda     #$FF
        rts

LB4BA:  lda     event_params_xcoord
        sec
        sbc     LB502
        sta     LB506
        lda     event_params_xcoord+1
        sbc     LB503
        bpl     LB4D6
        lda     LB506
        cmp     #$FB
        bcs     LB4DD
LB4D3:  lda     #$FF
        rts

LB4D6:  lda     LB506
        cmp     #$05
        bcs     LB4D3
LB4DD:  lda     event_params_ycoord
        sec
        sbc     LB504
        sta     LB506
        lda     event_params_ycoord+1
        sbc     LB505
        bpl     LB4F6
        lda     LB506
        cmp     #$FC
        bcs     LB4FD
LB4F6:  lda     LB506
        cmp     #$04
        bcs     LB4D3
LB4FD:  lda     #$00
        rts

LB500:  .byte   0
LB501:  .byte   0
LB502:  .byte   0
LB503:  .byte   0
LB504:  .byte   0
LB505:  .byte   0
LB506:  .byte   0
LB507:  .byte   0
LB508:  .byte   0
LB509:  sta     LD8E7
        jsr     LB53A
        bit     LD8E7
        bvc     LB51A
        jsr     draw_yes_no_all_cancel_buttons
        jmp     LB526

LB51A:  MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::ok_button_rect
        jsr     draw_ok_label
LB526:  bit     LD8E7
        bmi     LB537
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::cancel_button_rect
        jsr     draw_cancel_label
LB537:  jmp     reset_state

LB53A:  MGTK_RELAY_CALL MGTK::OpenWindow, winfoF
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::confirm_dialog_outer_rect
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::confirm_dialog_inner_rect
        rts

create_window_with_alert_bitmap:
        MGTK_RELAY_CALL MGTK::OpenWindow, winfoF
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     set_fill_white
        MGTK_RELAY_CALL MGTK::PaintBits, alert_bitmap2_params
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::confirm_dialog_outer_rect
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::confirm_dialog_inner_rect
        rts

;;; ==================================================

.proc draw_dialog_label
        textwidth_params := $8
        textptr := $8
        textlen := $A
        result  := $B

        stx     $06+1
        sta     $06
        tya
        bmi     :+
        jmp     skip

:       tya
        pha
        lda     $06
        clc
        adc     #$01

        sta     textptr
        lda     $06+1
        adc     #$00
        sta     textptr+1
        jsr     LBD7B
        sta     textlen
        MGTK_RELAY_CALL MGTK::TextWidth, textwidth_params
        lsr     result+1
        ror     result
        lda     #<200
        sec
        sbc     result
        sta     dialog_label_pos
        lda     #>200
        sbc     result+1
        sta     dialog_label_pos+1
        pla
        tay

skip:   dey
        tya
        asl     a
        asl     a
        asl     a
        clc
        adc     pointD::ycoord
        sta     dialog_label_pos+2
        lda     pointD::ycoord+1
        adc     #0
        sta     dialog_label_pos+3
        MGTK_RELAY_CALL MGTK::MoveTo, dialog_label_pos
        ldax    $06
        jsr     draw_text1
        ldx     dialog_label_pos
        lda     #$28
        sta     dialog_label_pos
        rts
.endproc

;;; ==================================================

draw_ok_label:
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::ok_label_pos
        addr_call draw_text1, desktop_aux::str_ok_label
        rts

draw_cancel_label:
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::cancel_label_pos
        addr_call draw_text1, desktop_aux::str_cancel_label
        rts

draw_yes_label:
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::yes_label_pos
        addr_call draw_text1, desktop_aux::str_yes_label
        rts

draw_no_label:
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::no_label_pos
        addr_call draw_text1, desktop_aux::str_no_label
        rts

draw_all_label:
        MGTK_RELAY_CALL MGTK::MoveTo, desktop_aux::all_label_pos
        addr_call draw_text1, desktop_aux::str_all_label
        rts

draw_yes_no_all_cancel_buttons:
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::yes_button_rect
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::no_button_rect
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::all_button_rect
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::cancel_button_rect
        jsr     draw_yes_label
        jsr     draw_no_label
        jsr     draw_all_label
        jsr     draw_cancel_label
        lda     #$40
        sta     LD8E7
        rts

erase_yes_no_all_cancel_buttons:
        jsr     set_fill_white
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::yes_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::no_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::all_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        rts

draw_ok_cancel_buttons:
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::ok_button_rect
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::cancel_button_rect
        jsr     draw_ok_label
        jsr     draw_cancel_label
        lda     #$00
        sta     LD8E7
        rts

erase_ok_cancel_buttons:
        jsr     set_fill_white
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        rts

draw_ok_button:
        jsr     set_penmode_xor2
        MGTK_RELAY_CALL MGTK::FrameRect, desktop_aux::ok_button_rect
        jsr     draw_ok_label
        lda     #$80
        sta     LD8E7
        rts

erase_ok_button:
        jsr     set_fill_white
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        rts

;;; ==================================================

.proc draw_text1
        params := $6
        textptr := $6
        textlen := $8

        stax    textptr
        jsr     LBD7B
        beq     done
        sta     textlen
        inc     textptr
        bne     :+
        inc     textptr+1
:       MGTK_RELAY_CALL MGTK::DrawText, params
done:   rts
.endproc

;;; ==================================================

.proc draw_centered_string
        str       := $6
        str_data  := $6
        str_len   := $8
        str_width := $9

        stax    str             ; input is length-prefixed string

        jsr     LBD7B
        sta     str_len
        inc     str_data        ; point past length byte
        bne     :+
        inc     str_data+1
:       MGTK_RELAY_CALL MGTK::TextWidth, str
        lsr     str_width+1     ; divide by two
        ror     str_width
        lda     #$01
        sta     LB76B
        lda     #$90
        lsr     LB76B           ; divide by two
        ror     a
        sec
        sbc     str_width
        sta     point4::xcoord
        lda     LB76B
        sbc     str_width+1
        sta     point4::xcoord+1
        MGTK_RELAY_CALL MGTK::MoveTo, point4
        MGTK_RELAY_CALL MGTK::DrawText, str
        rts

LB76B:  .byte   0
.endproc

;;; ==================================================

        ;; Unreferenced ???
LB76C:  stax    $06
        MGTK_RELAY_CALL MGTK::MoveTo, point7
        ldax    $06
        jsr     draw_text1
        rts

LB781:  stx     $0B
        sta     $0A
        ldy     #$00
        lda     ($0A),y
        tay
        bne     LB78D
        rts

LB78D:  dey
        beq     LB792
        bpl     LB793
LB792:  rts

LB793:  lda     ($0A),y
        and     #$7F
        cmp     #$2F
        beq     LB79F
        cmp     #$2E
        bne     LB7A3
LB79F:  dey
        jmp     LB78D

LB7A3:  iny
        lda     ($0A),y
        and     #$7F
        cmp     #$41
        bcc     LB7B5
        cmp     #$5B
        bcs     LB7B5
        clc
        adc     #$20
        sta     ($0A),y
LB7B5:  dey
        jmp     LB78D

.proc set_port_from_window_id
        sta     getwinport_params2::window_id
        MGTK_RELAY_CALL MGTK::GetWinPort, getwinport_params2
        MGTK_RELAY_CALL MGTK::SetPort, grafport2
        rts
.endproc

;;; ==================================================
;;; Event loop during button press - handle inverting
;;; the text as mouse is dragged in/out, report final
;;; click (A as passed) / cancel (A is negative)

button_loop_ok:
        lda     #prompt_button_ok
        jmp     button_event_loop

button_loop_cancel:
        lda     #prompt_button_cancel
        jmp     button_event_loop

button_loop_yes:
        lda     #prompt_button_yes
        jmp     button_event_loop

button_loop_no:
        lda     #prompt_button_no
        jmp     button_event_loop

button_loop_all:
        lda     #prompt_button_all
        jmp     button_event_loop

.proc button_event_loop
        ;; Configure test and fill procs
        pha
        asl     a
        asl     a
        tax
        copy16  test_fill_button_proc_table,x, test_button_proc_addr
        copy16  test_fill_button_proc_table+2,x, fill_button_proc_addr
        pla
        jmp     event_loop

test_fill_button_proc_table:
        .addr   test_ok_button,fill_ok_button
        .addr   test_cancel_button,fill_cancel_button
        .addr   test_yes_button,fill_yes_button
        .addr   test_no_button,fill_no_button
        .addr   test_all_button,fill_all_button

test_ok_button:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::ok_button_rect
        rts

test_cancel_button:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::cancel_button_rect
        rts

test_yes_button:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::yes_button_rect
        rts

test_no_button:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::no_button_rect
        rts

test_all_button:
        MGTK_RELAY_CALL MGTK::InRect, desktop_aux::all_button_rect
        rts

fill_ok_button:
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::ok_button_rect
        rts

fill_cancel_button:
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::cancel_button_rect
        rts

fill_yes_button:
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::yes_button_rect
        rts

fill_no_button:
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::no_button_rect
        rts

fill_all_button:
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::all_button_rect
        rts

test_proc:  jmp     (test_button_proc_addr)
fill_proc:  jmp     (fill_button_proc_addr)

test_button_proc_addr:  .addr   0
fill_button_proc_addr:  .addr   0

event_loop:
        sta     click_result
        lda     #0
        sta     down_flag
loop:   MGTK_RELAY_CALL MGTK::GetEvent, event_params
        lda     event_params_kind
        cmp     #MGTK::event_kind_button_up
        beq     exit
        lda     winfoF
        sta     event_params
        MGTK_RELAY_CALL MGTK::ScreenToWindow, event_params
        MGTK_RELAY_CALL MGTK::MoveTo, $D20D
        jsr     test_proc
        cmp     #MGTK::inrect_inside
        beq     inside
        lda     down_flag       ; outside but was inside?
        beq     invert
        jmp     loop

inside: lda     down_flag       ; already depressed?
        bne     invert
        jmp     loop

invert: jsr     set_penmode_xor2
        jsr     fill_proc
        lda     down_flag
        clc
        adc     #$80
        sta     down_flag
        jmp     loop

exit:   lda     down_flag       ; was depressed?
        beq     clicked
        lda     #$FF            ; hi bit = cancelled
        rts

clicked:
        jsr     fill_proc       ; invert one last time
        lda     click_result    ; grab expected result
        rts

down_flag:
        .byte   0

click_result:
        .byte   0

        rts                     ; ???
.endproc

;;; ==================================================

.proc LB8F5
        point := $6
        xcoord := $6
        ycoord := $8

        jsr     LBD3B
        stax    xcoord
        copy16  point6::ycoord, ycoord
        MGTK_RELAY_CALL MGTK::MoveTo, point
        MGTK_RELAY_CALL MGTK::SetPortBits, setportbits_params3
        bit     LD8EB
        bpl     LB92D
        MGTK_RELAY_CALL MGTK::SetTextBG, desktop_aux::LAE6C
        lda     #$00
        sta     LD8EB
        beq     LB93B
LB92D:  MGTK_RELAY_CALL MGTK::SetTextBG, desktop_aux::LAE6D
        lda     #$FF
        sta     LD8EB

        drawtext_params := $6
        textptr := $6
        textlen := $8

LB93B:  copy16  #LD8EF, textptr
        lda     LD8EE
        sta     textlen
        MGTK_RELAY_CALL MGTK::DrawText, drawtext_params
        MGTK_RELAY_CALL MGTK::SetTextBG, desktop_aux::LAE6D
        lda     winfoF
        jsr     set_port_from_window_id
        rts
.endproc

LB961:  lda     path_buf1
        beq     LB9B7
        lda     winfoF
        jsr     set_port_from_window_id
        jsr     set_fill_white
        MGTK_RELAY_CALL MGTK::PaintRect, rect1
        MGTK_RELAY_CALL MGTK::SetPenMode, penXOR
        MGTK_RELAY_CALL MGTK::FrameRect, rect1
        MGTK_RELAY_CALL MGTK::MoveTo, point6
        MGTK_RELAY_CALL MGTK::SetPortBits, setportbits_params3
        addr_call draw_text1, path_buf1
        addr_call draw_text1, path_buf2
        addr_call draw_text1, str_2_spaces
        lda     winfoF
        jsr     set_port_from_window_id
LB9B7:  rts

LB9B8:  MGTK_RELAY_CALL MGTK::ScreenToWindow, event_params
        MGTK_RELAY_CALL MGTK::MoveTo, $D20D
        MGTK_RELAY_CALL MGTK::InRect, rect1
        cmp     #MGTK::inrect_inside
        beq     LB9D8
        rts

LB9D8:  jsr     LBD3B
        stax    $06
        lda     $D20D
        cmp     $06
        lda     $D20E
        sbc     $06+1
        bcs     LB9EE
        jmp     LBA83

.proc LB9EE
        ptr := $6
        jsr     LBD3B
        stax    LBB09
        ldx     path_buf2
        inx
        lda     #' '
        sta     path_buf2,x
        inc     path_buf2
        copy16  #path_buf2, ptr
        lda     path_buf2
        sta     ptr+2
LBA10:  MGTK_RELAY_CALL MGTK::TextWidth, ptr
        add16 $09, LBB09, $09
        lda     $09
        cmp     $D20D
        lda     $0A
        sbc     $D20E
        bcc     LBA42
        dec     $08
        lda     $08
        cmp     #$01
        bne     LBA10
        dec     path_buf2
        jmp     LBB05
.endproc

LBA42:  lda     $08
        cmp     path_buf2
        bcc     LBA4F
        dec     path_buf2
        jmp     LBCC9

LBA4F:  ldx     #$02
        ldy     path_buf1
        iny
LBA55:  lda     path_buf2,x
        sta     path_buf1,y
        cpx     $08
        beq     LBA64
        iny
        inx
        jmp     LBA55

LBA64:  sty     path_buf1
        ldy     #$02
        ldx     $08
        inx
LBA6C:  lda     path_buf2,x
        sta     path_buf2,y
        cpx     path_buf2
        beq     LBA7C
        iny
        inx
        jmp     LBA6C

LBA7C:  dey
        sty     path_buf2
        jmp     LBB05


.proc LBA83
        params := $6
        textptr := $6
        textlen := $8
        result  := $9

        copy16  #path_buf1, textptr
        lda     path_buf1
        sta     textlen
:       MGTK_RELAY_CALL MGTK::TextWidth, params
        add16 result, point6::xcoord, result
        lda     result
        cmp     $D20D
        lda     result+1
        sbc     $D20E
        bcc     LBABF
        dec     textlen
        lda     textlen
        cmp     #1
        bcs     :-
        jmp     LBC5E
.endproc

LBABF:  inc     $08
        ldy     #$00
        ldx     $08
LBAC5:  cpx     path_buf1
        beq     LBAD5
        inx
        iny
        lda     path_buf1,x
        sta     $D3C2,y
        jmp     LBAC5

LBAD5:  iny
        sty     $D3C1
        ldx     #$01
        ldy     $D3C1
LBADE:  cpx     path_buf2
        beq     LBAEE
        inx
        iny
        lda     path_buf2,x
        sta     $D3C1,y
        jmp     LBADE

LBAEE:  sty     $D3C1
        lda     LD8EF
        sta     $D3C2
LBAF7:  lda     $D3C1,y
        sta     path_buf2,y
        dey
        bpl     LBAF7
        lda     $08
        sta     path_buf1
LBB05:  jsr     LB961
        rts

LBB09:  .word   0

LBB0B:  sta     LBB62
        lda     path_buf1
        clc
        adc     path_buf2
        cmp     #$10
        bcc     LBB1A
        rts

.proc LBB1A
        point := $6
        xcoord := $6
        ycoord := $8

        lda     LBB62
        ldx     path_buf1
        inx
        sta     path_buf1,x
        sta     str_1_char+1
        jsr     LBD3B
        inc     path_buf1
        stax    xcoord
        copy16  point6::ycoord, ycoord
        MGTK_RELAY_CALL MGTK::MoveTo, point
        MGTK_RELAY_CALL MGTK::SetPortBits, setportbits_params3
        addr_call draw_text1, str_1_char
        addr_call draw_text1, path_buf2
        lda     winfoF
        jsr     set_port_from_window_id
        rts
.endproc

LBB62:  .byte   0
LBB63:  lda     path_buf1
        bne     LBB69
        rts

.proc LBB69
        point := $6
        xcoord := $6
        ycoord := $8

        dec     path_buf1
        jsr     LBD3B
        stax    xcoord
        copy16  point6::ycoord, ycoord
        MGTK_RELAY_CALL MGTK::MoveTo, point
        MGTK_RELAY_CALL MGTK::SetPortBits, setportbits_params3
        addr_call draw_text1, path_buf2
        addr_call draw_text1, str_2_spaces
        lda     winfoF
        jsr     set_port_from_window_id
        rts
.endproc

LBBA4:  lda     path_buf1
        bne     LBBAA
        rts

.proc LBBAA
        point := $6
        xcoord := $6
        ycoord := $8

        ldx     path_buf2
        cpx     #1
        beq     LBBBC
LBBB1:  lda     path_buf2,x
        sta     $D485,x
        dex
        cpx     #1
        bne     LBBB1
LBBBC:  ldx     path_buf1
        lda     path_buf1,x
        sta     $D486
        dec     path_buf1
        inc     path_buf2
        jsr     LBD3B
        stax    xcoord
        copy16  point6::ycoord, ycoord
        MGTK_RELAY_CALL MGTK::MoveTo, point
        MGTK_RELAY_CALL MGTK::SetPortBits, setportbits_params3
        addr_call draw_text1, path_buf2
        addr_call draw_text1, str_2_spaces
        lda     winfoF
        jsr     set_port_from_window_id
        rts
.endproc

LBC03:  lda     path_buf2
        cmp     #$02
        bcs     LBC0B
        rts

LBC0B:  ldx     path_buf1
        inx
        lda     $D486
        sta     path_buf1,x
        inc     path_buf1
        ldx     path_buf2
        cpx     #$03
        bcc     LBC2D
        ldx     #$02
LBC21:  lda     $D485,x
        sta     path_buf2,x
        inx
        cpx     path_buf2
        bne     LBC21
LBC2D:  dec     path_buf2
        MGTK_RELAY_CALL MGTK::MoveTo, point6
        MGTK_RELAY_CALL MGTK::SetPortBits, setportbits_params3
        addr_call draw_text1, path_buf1
        addr_call draw_text1, path_buf2
        addr_call draw_text1, str_2_spaces
        lda     winfoF
        jsr     set_port_from_window_id
        rts

LBC5E:  lda     path_buf1
        bne     LBC64
        rts

LBC64:  ldx     path_buf2
        cpx     #$01
        beq     LBC79
LBC6B:  lda     path_buf2,x
        sta     $D3C0,x
        dex
        cpx     #$01
        bne     LBC6B
        ldx     path_buf2
LBC79:  dex
        stx     $D3C1
        ldx     path_buf1
LBC80:  lda     path_buf1,x
        sta     $D485,x
        dex
        bne     LBC80
        lda     LD8EF
        sta     $D485
        inc     path_buf1
        lda     path_buf1
        sta     path_buf2
        lda     path_buf1
        clc
        adc     $D3C1
        tay
        pha
        ldx     $D3C1
        beq     LBCB3
LBCA6:  lda     $D3C1,x
        sta     path_buf2,y
        dex
        dey
        cpy     path_buf2
        bne     LBCA6
LBCB3:  pla
        sta     path_buf2
        lda     #$00
        sta     path_buf1
        MGTK_RELAY_CALL MGTK::MoveTo, point6
        jsr     LB961
        rts

LBCC9:  lda     path_buf2
        cmp     #$02
        bcs     LBCD1
        rts

LBCD1:  ldx     path_buf2
        dex
        txa
        clc
        adc     path_buf1
        pha
        tay
        ldx     path_buf2
LBCDF:  lda     path_buf2,x
        sta     path_buf1,y
        dex
        dey
        cpy     path_buf1
        bne     LBCDF
        pla
        sta     path_buf1
        lda     #$01
        sta     path_buf2
        MGTK_RELAY_CALL MGTK::MoveTo, point6
        jsr     LB961
        rts

        stax    $06
        ldy     #$00
        lda     ($06),y
        tay
        clc
        adc     path_buf1
        pha
        tax
LBD11:  lda     ($06),y
        sta     path_buf1,x
        dey
        dex
        cpx     path_buf1
        bne     LBD11
        pla
        sta     path_buf1
        rts

LBD22:  ldx     path_buf1
        cpx     #$00
        beq     LBD33
        dec     path_buf1
        lda     path_buf1,x
        cmp     #$2F
        bne     LBD22
LBD33:  rts

        jsr     LBD22
        jsr     LB961
        rts

.proc LBD3B
        params := $6
        textptr := $6
        textlen := $8
        result := $9

        copy16  #$D444, textptr
        lda     path_buf1
        sta     textlen
        bne     :+
        ldax    point6::xcoord
        rts
:       MGTK_RELAY_CALL MGTK::TextWidth, params
        lda     result
        clc
        adc     point6::xcoord
        tay
        lda     result+1
        adc     point6::xcoord+1
        tax
        tya
        rts
.endproc

LBD69:  lda     #$01
        sta     path_buf2
        lda     LD8EF
        sta     $D485
        rts

LBD75:  lda     #$00
        sta     path_buf1
        rts

        ;; Compute length of some text???
.proc LBD7B
        ldx     #$11
LBD7D:  lda     L0020,x
        sta     LBDB0,x
        dex
        bpl     LBD7D
        ldx     #$11
LBD87:  lda     LBD9F,x
        sta     L0020,x
        dex
        bpl     LBD87
        jsr     L0020
        pha
        ldx     #$11
LBD95:  lda     LBDB0,x
        sta     L0020,x
        dex
        bpl     LBD95
        pla
        rts
.endproc

LBD9F:  sta     RAMRDON
        sta     RAMWRTON
        ldy     #$00
        lda     ($06),y
        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts

LBDB0:  .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
LBDC4:  ldx     str_files
        lda     LD90A
        bne     LBDD9
        lda     LD909
        cmp     #$02
        bcs     LBDD9
        lda     #' '
        sta     str_files,x
        rts

LBDD9:  lda     #$73
        sta     str_files,x
        rts

LBDDF:  lda     LD909
        sta     LBE5F
        lda     LD90A
        sta     LBE5F+1

        ldx     #7              ; does this ever get overwritten???
        lda     #' '
:       sta     str_7_spaces,x
        dex
        bne     :-

        lda     #$00
        sta     LBE62
        ldy     #$00
        ldx     #$00
LBDFE:  lda     #$00
        sta     LBE61
LBE03:  lda     LBE5F
        cmp     LBE57,x
        lda     LBE5F+1
        sbc     LBE57+1,x
        bpl     LBE35
        lda     LBE61
        bne     LBE1F
        bit     LBE62
        bmi     LBE1F
        lda     #$20
        bne     LBE28
LBE1F:  ora     #$30
        pha
        lda     #$80
        sta     LBE62
        pla
LBE28:  sta     str_7_spaces+2,y
        iny
        inx
        inx
        cpx     #$08
        beq     LBE4E
        jmp     LBDFE

LBE35:  inc     LBE61
        lda     LBE5F
        sec
        sbc     LBE57,x
        sta     LBE5F
        lda     LBE5F+1
        sbc     LBE57+1,x
        sta     LBE5F+1
        jmp     LBE03

LBE4E:  lda     LBE5F
        ora     #'0'
        sta     str_7_spaces+2,y
        rts

LBE57:  .word   10000,1000,100,10
LBE5F:  .addr   0
LBE61:  .byte   0
LBE62:  .byte   0
LBE63:  ldy     #$00
        lda     ($06),y
        tay
LBE68:  lda     ($06),y
        sta     path_buf0,y
        dey
        bpl     LBE68
        addr_call LB781, path_buf0
        rts

LBE78:  ldy     #$00
        lda     ($06),y
        tay
LBE7D:  lda     ($06),y
        sta     path_buf1,y
        dey
        bpl     LBE7D
        addr_call LB781, path_buf1
        rts

LBE8D:  jsr     set_fill_white
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::LAE86
        rts

LBE9A:  jsr     set_fill_white
        MGTK_RELAY_CALL MGTK::PaintRect, desktop_aux::LAE8E
        rts

set_fill_white:
        MGTK_RELAY_CALL MGTK::SetPenMode, pencopy
        rts

reset_state:
        MGTK_RELAY_CALL MGTK::InitPort, grafport3
        MGTK_RELAY_CALL MGTK::SetPort, grafport3
        rts

        .assert * = $BEC4, error, "Segment length mismatch"
        PAD_TO $BF00

.endproc ; desktop_main
        desktop_main_pop_zp_addrs := desktop_main::pop_zp_addrs
        desktop_main_push_zp_addrs := desktop_main::push_zp_addrs

;;; ==================================================
;;; Segment loaded into MAIN $800-$FFF
;;; ==================================================

;;; Appears to be init sequence - machine identification, etc

.proc desktop_800

DESKTOP_DEVICELIST := $E196

        .org $800

start:
        ;; Detect machine type
        ;; See Apple II Miscellaneous #7: Apple II Family Identification
        lda     #0
        sta     iigs_flag
        lda     ID_BYTE_FBC0    ; 0 = IIc or IIc+
        beq     :+
        sec                     ; Follow detection protocol
        jsr     ID_BYTE_FE1F    ; RTS on pre-IIgs
        bcs     :+              ; carry clear = IIgs
        lda     #$80
        sta     iigs_flag

:       ldx     ID_BYTE_FBB3
        ldy     ID_BYTE_FBC0
        cpx     #$06            ; Ensure a IIe or later
        beq     :+
        brk                     ; Otherwise (][, ][+, ///), just crash

:       sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        sta     SET80COL
        stx     id_byte_1       ; Stash so DeskTop can check machine bytes
        sty     id_byte_2       ; when ROM is banked out.
        cpy     #0
        beq     is_iic          ; Now identify/store specific machine type.
        bit     iigs_flag       ; (number is used in double-click timer)
        bpl     is_iie
        lda     #$FD            ; IIgs
        sta     machine_type
        jmp     done_machine_id

is_iie: lda     #$96            ; IIe
        sta     machine_type
        jmp     done_machine_id

is_iic: lda     #$FA            ; IIc
        sta     machine_type
        jmp     done_machine_id

iigs_flag:                      ; High bit set if IIgs detected.
        .byte   0

done_machine_id:
        sta     CLR80VID
        sta     DHIRESON
        sta     DHIRESOFF
        sta     DHIRESON        ; For good measure???
        sta     DHIRESOFF
        sta     SET80VID
        sta     DHIRESON        ; Also AN3_OFF
        sta     HR2_ON          ; For Le Chat Mauve: 560 B&W mode
        sta     HR3_ON
        bit     iigs_flag
        bpl     :+

        ;; Force B&W mode on the IIgs
        lda     NEWVIDEO
        ora     #(1<<5)         ; B&W
        sta     NEWVIDEO

        ;; Look for /RAM
:       ldx     DEVCNT
        inx
:       lda     DEVLST-1,x
        sta     DESKTOP_DEVICELIST,x
        dex
        bpl     :-
        ldx     DEVCNT
:       lda     DEVLST,x
        ;; BUG: ProDOS Tech Note #21 says $B3,$B7,$BB or $BF could be /RAM
        cmp     #(1<<7 | 3<<4 | DT_RAM) ; unit_num for /RAM is Slot 3, Drive 2
        beq     found_ram
        dex
        bpl     :-
        bmi     :+
found_ram:
        jsr     remove_device

:       MGTK_RELAY_CALL MGTK::StartDeskTop, id_byte_1
        MGTK_RELAY_CALL MGTK::SetMenu, splash_menu
        MGTK_RELAY_CALL MGTK::SetZP1, zp_use_flag0
        MGTK_RELAY_CALL MGTK::SetCursor, watch_cursor
        MGTK_RELAY_CALL MGTK::ShowCursor
        jsr     desktop_main::push_zp_addrs
        copy16  #$EC63, $06
        ldx     #$01
L08D5:  cpx     #$7F
        bne     L08DF
        jsr     desktop_main::pop_zp_addrs
        jmp     L0909

L08DF:  txa
        pha
        asl     a
        tax
        copy16  $06, file_address_table,x
        pla
        pha
        ldy     #$00
        sta     ($06),y
        iny
        lda     #$00
        sta     ($06),y
        lda     $06
        clc
        adc     #$1B
        sta     $06
        bcc     L0903
        inc     $06+1
L0903:  pla
        tax
        inx
        jmp     L08D5

L0909:  sta     RAMWRTON
        lda     #$00
        tax
L090F:  sta     $1F00,x
        sta     $1E00,x
        sta     $1D00,x
        sta     $1C00,x
        sta     $1B00,x
        inx
        bne     L090F
        sta     RAMWRTOFF
        jmp     L092F

L0927:  PASCAL_STRING " Trash "
L092F:  lda     #0
        sta     bufnum
        lda     #1
        sta     buf3len
        sta     LDD9E
        jsr     DESKTOP_FIND_SPACE
        sta     $EBFB
        sta     buf3
        jsr     desktop_main::file_address_lookup
        stax    $06
        ldy     #$02
        lda     #$70
        sta     ($06),y
        ldy     #$07
        lda     #<desktop_aux::trash_icon
        sta     ($06),y
        iny
        lda     #>desktop_aux::trash_icon
        sta     ($06),y
        iny
        ldx     #$00
L0960:  lda     L0927,x
        sta     ($06),y
        iny
        inx
        cpx     L0927
        bne     L0960
        lda     L0927,x
        sta     ($06),y
        lda     DEVCNT
        sta     L0A01
        inc     L0A01
        ldx     #$00
L097C:  lda     DEVLST,x
        and     #$8F
        cmp     #$8B
        beq     L098E
        inx
        cpx     L0A01
        bne     L097C
        jmp     L09F5

L098E:  lda     DEVLST,x
        stx     L09F8
        sta     L0A02
        ldx     #$11
        lda     L0A02
        and     #$80
        beq     L09A2
        ldx     #$21
L09A2:  stx     L09B5
        lda     L0A02
        and     #$70
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     L09B5
        sta     L09B5
        L09B5 := *+1
        lda     $BF00           ; self-modified
        sta     $06+1
        lda     #$00
        sta     $06
        ldy     #$07
        lda     ($06),y
        bne     L09F5
        ldy     #$FB
        lda     ($06),y
        and     #$7F
        bne     L09F5
        ldy     #$FF
        lda     ($06),y
        clc
        adc     #$03
        sta     $06
        jsr     L09F9
        .byte   0
        .addr   L09FC
        bcs     L09F5
        lda     $1F00
        cmp     #$02
        bcs     L09F5
        ldx     L09F8
L09E6:  lda     DEVLST+1,x
        sta     DEVLST,x
        inx
        cpx     L0A01
        bne     L09E6
        dec     DEVCNT
L09F5:  jmp     L0A03

L09F8:  .byte   0
L09F9:  jmp     ($06)

L09FC:  .byte   $03
        .byte   0
        .byte   0
        .byte   $1F
        .byte   0
L0A01:  .byte   0
L0A02:  .byte   0

L0A03:  MGTK_RELAY_CALL MGTK::CheckEvents
        MLI_RELAY_CALL GET_PREFIX, desktop_main::get_prefix_params
        MGTK_RELAY_CALL MGTK::CheckEvents
        lda     #$00
        sta     L0A92
        jsr     L0AE7
        lda     $1400
        clc
        adc     $1401
        sta     LD343
        lda     #$00
        sta     LD343+1
        lda     $1400
        sta     L0A93
L0A3B:  lda     L0A92
        cmp     L0A93
        beq     L0A8F
        jsr     L0A95
        stax    $06
        lda     L0A92
        jsr     L0AA2
        stax    $08
        ldy     #$00
        lda     ($06),y
        tay
L0A59:  lda     ($06),y
        sta     ($08),y
        dey
        bpl     L0A59
        ldy     #$0F
        lda     ($06),y
        sta     ($08),y
        lda     L0A92
        jsr     L0ABC
        stax    $06
        lda     L0A92
        jsr     L0AAF
        stax    $08
        ldy     #$00
        lda     ($06),y
        tay
L0A7F:  lda     ($06),y
        sta     ($08),y
        dey
        bpl     L0A7F
        inc     L0A92
        inc     selector_menu
        jmp     L0A3B

L0A8F:  jmp     L0B09

L0A92:  .byte   0
L0A93:  .byte   0
        .byte   0

L0A95:  jsr     desktop_main::a_times_4
        clc
        adc     #$02
        tay
        txa
        adc     #$14
        tax
        tya
        rts

L0AA2:  jsr     desktop_main::a_times_4
        clc
        adc     #$1E
        tay
        txa
        adc     #$DB
        tax
        tya
        rts

L0AAF:  jsr     desktop_main::a_times_6
        clc
        adc     #$9E
        tay
        txa
        adc     #$DB
        tax
        tya
        rts

L0ABC:  jsr     desktop_main::a_times_6
        clc
        adc     #$82
        tay
        txa
        adc     #$15
        tax
        tya
        rts

.proc open_params
param_count:    .byte   3
pathname:       .addr   str_selector_list
io_buffer:      .addr   $1000
ref_num:        .byte   0
.endproc

str_selector_list:
        PASCAL_STRING "Selector.List"

.proc read_params
param_count:    .byte   4
ref_num:        .byte   0
read_buffer:    .addr   $1400
request_count:  .word   $400
trans_count:    .word   0
.endproc

.proc close_params
param_count:    .byte   1
ref_num:        .byte   0
.endproc

L0AE7:  MLI_RELAY_CALL OPEN, open_params
        lda     open_params::ref_num
        sta     read_params::ref_num
        MLI_RELAY_CALL READ, read_params
        MLI_RELAY_CALL CLOSE, close_params
        rts

L0B09:  addr_call desktop_main::measure_text1, str_6_spaces
        sta     L0BA0
        stx     L0BA1
        addr_call desktop_main::measure_text1, str_items
        clc
        adc     L0BA0
        sta     $EBF3
        txa
        adc     L0BA1
        sta     $EBF4
        addr_call desktop_main::measure_text1, str_k_in_disk
        clc
        adc     L0BA0
        sta     $EBF5
        txa
        adc     L0BA1
        sta     $EBF6
        addr_call desktop_main::measure_text1, str_k_available
        clc
        adc     L0BA0
        sta     $EBF7
        txa
        adc     L0BA1
        sta     $EBF8
        add16 $EBF5, $EBF7, $EBF9
        add16 $EBF3, #$05, LEBE3
        add16 LEBE3, $EBF5, $EBE7
        add16 $EBE7, #$03, $EBE7
        jmp     L0BA2

L0BA0:  .byte   0
L0BA1:  .byte   0

L0BA2:  MGTK_RELAY_CALL MGTK::CheckEvents
        MLI_RELAY_CALL GET_FILE_INFO, get_file_info_params
        beq     L0BB9
        jmp     L0D0A

L0BB9:  lda     get_file_info_params_type
        cmp     #$0F
        beq     L0BC3
        jmp     L0D0A

L0BC3:  MLI_RELAY_CALL OPEN, open_params2
        lda     open_params2_ref_num
        sta     read_params2_ref_num
        sta     close_params2_ref_num
        MLI_RELAY_CALL READ, read_params2
        lda     #$00
        sta     L0D04
        sta     L0D05
        lda     #$01
        sta     L0D08
        lda     $1425
        and     #$7F
        sta     L0D03
        lda     #$02
        sta     apple_menu
        lda     $1424
        sta     L0D07
        lda     $1423
        sta     L0D06
        lda     #$2B
        sta     $06
        lda     #$14
        sta     $06+1
L0C0C:  ldy     #$00
        lda     ($06),y
        and     #$0F
        bne     L0C17
        jmp     L0C81

L0C17:  inc     L0D04
        ldy     #$10
        lda     ($06),y
        cmp     #$F1
        beq     L0C25
        jmp     L0C81

L0C25:  inc     L0D05
        copy16  #buf, $08
        lda     #$00
        sta     L0D09
        lda     apple_menu
        sec
        sbc     #$02
        asl     a
        rol     L0D09
        asl     a
        rol     L0D09
        asl     a
        rol     L0D09
        asl     a
        rol     L0D09
        clc
        adc     $08
        sta     $08
        lda     L0D09
        adc     $08+1
        sta     $08+1
        ldy     #$00
        lda     ($06),y
        and     #$0F
        sta     ($08),y
        tay
L0C60:  lda     ($06),y
        sta     ($08),y
        dey
        bne     L0C60
        ldax    $08
        jsr     desktop_main::L87BA
        lda     ($08),y
        tay
L0C71:  lda     ($08),y
        cmp     #$2E
        bne     L0C7B
        lda     #$20
        sta     ($08),y
L0C7B:  dey
        bne     L0C71
        inc     apple_menu
L0C81:  lda     L0D05
        cmp     #$08
        bcc     L0C8B
        jmp     L0CCB

L0C8B:  lda     L0D04
        cmp     L0D03
        bne     L0C96
        jmp     L0CCB

L0C96:  inc     L0D08
        lda     L0D08
        cmp     L0D07
        bne     L0CBA
        MLI_RELAY_CALL READ, read_params2
        copy16  #$1404, $06
        lda     #$00
        sta     L0D08
        jmp     L0C0C

L0CBA:  add16_8 $06, L0D06, $06
        jmp     L0C0C

L0CCB:  MLI_RELAY_CALL CLOSE, close_params2
        jmp     L0D0A

.proc open_params2
param_count:    .byte   3
pathname:       .addr   str_desk_acc
io_buffer:      .addr   $1000
ref_num:        .byte   0
.endproc
        open_params2_ref_num := open_params2::ref_num

.proc read_params2
param_count:    .byte   4
ref_num:        .byte   0
data_buffer:    .addr   $1400
request_count:  .word   $200
trans_count:    .word   0
.endproc
        read_params2_ref_num := read_params2::ref_num

.proc get_file_info_params
param_count:    .byte   $A
pathname:       .addr   str_desk_acc
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc
        get_file_info_params_type := get_file_info_params::file_type

        .byte   0

.proc close_params2
param_count:    .byte   1
ref_num:        .byte   0
.endproc
        close_params2_ref_num := close_params2::ref_num

str_desk_acc:
        PASCAL_STRING "Desk.acc"

L0D03:  .byte   0
L0D04:  .byte   0
L0D05:  .byte   0
L0D06:  .byte   0
L0D07:  .byte   0
L0D08:  .byte   0
L0D09:  .byte   0

L0D0A:  ldy     #$00
        sty     desktop_main::L599F
        sty     L0E33
L0D12:  lda     L0E33
        asl     a
        tay
        copy16  $DB00,y, $08
        ldy     L0E33
        lda     DEVLST,y
        pha
        txa
        pha
        tya
        pha
        inc     buf3len
        inc     LDD9E
        lda     DEVLST,y
        jsr     desktop_main::get_device_info
        sta     L0E34
        MGTK_RELAY_CALL MGTK::CheckEvents
        pla
        tay
        pla
        tax
        pla
        pha
        lda     L0E34
        cmp     #$28
        bne     L0D64
        ldy     L0E33
        lda     DEVLST,y
        and     #$0F
        beq     L0D6D
        ldx     L0E33
        jsr     remove_device
        jmp     L0E25

L0D64:  cmp     #$57
        bne     L0D6D
        lda     #$F9
        sta     desktop_main::L599F
L0D6D:  pla
        pha
        and     #$0F
        sta     L0E32
        cmp     #$00
        bne     L0D7F
        addr_jump L0DAD, str_slot_drive

L0D7F:  cmp     #$0B
        beq     L0DA9
        cmp     #$04
        bne     L0DC2
        pla
        pha
        and     #$70            ; Compute $CnFB
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        ora     #$C0
        sta     L0D96
        L0D96 := *+2
        lda     $C7FB           ; self-modified
        and     #$01
        bne     L0DA2
        addr_jump L0DAD, str_profile_slot_x

L0DA2:  addr_jump L0DAD, str_ramcard_slot_x

L0DA9:  ldax    #str_unidisk_xy
L0DAD:  stax    $06
        ldy     #$00
        lda     ($06),y
        sta     L0DBE
L0DB8:  iny
        lda     ($06),y
        sta     ($08),y
        L0DBE := *+1
        cpy     #0
        bne     L0DB8
        tay
L0DC2:  pla
        pha
        and     #$70
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        ora     #$30
        tax
        lda     L0E32
        cmp     #$04
        bne     L0DF0
        pla
        pha
        and     #$70            ; compute $CnFB
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        ora     #$C0
        sta     L0DE3
        L0DE3 := *+2
        lda     $C7FB           ; self-modified
        and     #$01
        bne     L0DEC
        ldy     #$0E
        bne     L0DFA
L0DEC:  ldy     #$0E
        bne     L0DFA
L0DF0:  cmp     #$0B
        bne     L0DF8
        ldy     #$0F
        bne     L0DFA
L0DF8:  ldy     #$06
L0DFA:  txa
        sta     ($08),y
        lda     L0E32
        and     #$0F
        cmp     #$04
        beq     L0E21
        pla
        pha
        rol     a
        lda     #$00
        adc     #$01
        ora     #$30
        pha
        lda     L0E32
        and     #$0F
        bne     L0E1C
        ldy     #$10
        pla
        bne     L0E1F
L0E1C:  ldy     #$11
        pla
L0E1F:  sta     ($08),y
L0E21:  pla
        inc     L0E33
L0E25:  lda     L0E33
        cmp     DEVCNT
        beq     L0E2F
        bcs     L0E4C
L0E2F:  jmp     L0D12

L0E32:  .byte   0
L0E33:  .byte   0
L0E34:  .byte   0

        ;; Remove device num in X from devices list
.proc remove_device
        dex
L0E36:  inx
        lda     DEVLST+1,x
        sta     DEVLST,x
        lda     $E1A0+1,x
        sta     $E1A0,x
        cpx     DEVCNT
        bne     L0E36
        dec     DEVCNT
        rts
.endproc

L0E4C:  lda     DEVCNT
        clc
        adc     #$03
        sta     $E270
        lda     #$00
        sta     L0EAF
        tay
        tax
L0E5C:  lda     DEVLST,y
        and     #$70
        beq     L0EA8
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        cmp     L0EAF
        beq     L0E70
        cmp     #$02
        bne     L0E79
L0E70:  cpy     DEVCNT
        beq     L0EA8
        iny
        jmp     L0E5C

L0E79:  sta     L0EAF
        clc
        adc     #$30
        sta     L0EAE
        txa
        pha
        asl     a
        tax
        copy16  L0EB0,x, sta_addr
        ldx     s00
        dex
        lda     L0EAE
        sta_addr := *+1
        sta     dummy1234,x
        pla
        tax
        inx
        cpy     DEVCNT
        beq     L0EA8
        iny
        jmp     L0E5C

L0EA8:  stx     startup_menu
        jmp     L0EE1

L0EAE:  .byte   0
L0EAF:  .byte   0
L0EB0:  .addr   s00,s01,s02,s03,s04,s05,s06


.proc get_file_info_params2
param_count:    .byte   $A
pathname:       .addr   desktop_main::L4862
access: .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc
        .byte   0

.proc get_prefix_params
param_count:    .byte   1
buffer: .addr   desktop_main::L4862
.endproc

L0ED4:  PASCAL_STRING "System/Start"

L0EE1:  lda     #$00
        sta     desktop_main::L4861
        jsr     desktop_main::L4AFD
        cmp     #$80
        beq     L0EFE
        MLI_RELAY_CALL GET_PREFIX, get_prefix_params
        bne     L0F34
        dec     desktop_main::L4862
        jmp     L0F05

L0EFE:  addr_call desktop_main::L4B3A, desktop_main::L4862
L0F05:  ldx     desktop_main::L4862
L0F08:  lda     desktop_main::L4862,x
        cmp     #'/'
        beq     L0F12
        dex
        bne     L0F08
L0F12:  ldy     #$00
L0F14:  inx
        iny
        lda     L0ED4,y
        sta     desktop_main::L4862,x
        cpy     L0ED4
        bne     L0F14
        stx     desktop_main::L4862
        MLI_RELAY_CALL GET_FILE_INFO, get_file_info_params2
        bne     L0F34
        lda     #$80
        sta     desktop_main::L4861
L0F34:  MGTK_RELAY_CALL MGTK::CheckEvents
        MGTK_RELAY_CALL MGTK::SetMenu, desktop_aux::desktop_menu
        MGTK_RELAY_CALL MGTK::SetCursor, pointer_cursor
        lda     #$00
        sta     $EC25
        jsr     desktop_main::L66A2
        jsr     desktop_main::L678A
        jsr     desktop_main::L670C
        jmp     MGTK::MLI

        .assert * = $0F60, error, "Segment length mismatch"
        PAD_TO $1000

.endproc ; desktop_800
