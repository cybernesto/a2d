;;; ============================================================
;;; Run a Program File Picker Dialog - Overlay #1
;;;
;;; Compiled as part of selector.s
;;; ============================================================

.scope file_dialog
        .org ::OVERLAY_ADDR

        BTKEntry := app::BTKEntry

;;; ============================================================

ep_init:
        jmp     Start

ep_loop:
        jmp     EventLoop

;;; ============================================================

.params getwinport_params
window_id:     .byte   0
a_grafport:    .addr   window_grafport
.endparams

window_grafport:
        .tag    MGTK::GrafPort

buf_path:
        .res    ::kPathBufferSize, 0

;;; ============================================================
;;; File Picker Dialog

        .define FD_EXTENDED 0
        .include "../lib/file_dialog_res.s"

;;; ============================================================

;;; Called back from file dialog's `Start`
start:  jsr     OpenWindow
        param_call DrawTitleCentered, app::str_run_a_program
        jsr     DeviceOnLine
        jsr     UpdateListFromPath
        jmp     EventLoop

;;; ============================================================

.proc HandleOk
        param_call GetPath, buf_path

        ldx     saved_stack
        txs
        ldy     #<buf_path
        ldx     #>buf_path
        return  #$00
.endproc

;;; ============================================================

.proc HandleCancel
        jsr     CloseWindow
        ldx     saved_stack
        txs
        return  #$FF
.endproc

;;; ============================================================

;;; Required proc definitions:
YieldLoop               := app::YieldLoop
DetectDoubleClick       := app::DetectDoubleClick
ModifierDown            := app::ModifierDown
ShiftDown               := app::ShiftDown

;;; Required macro definitions:
        .include "../lib/file_dialog.s"

;;; ============================================================
;;; Determine if mouse moved
;;; Output: C=1 if mouse moved

.proc CheckMouseMoved
        ldx     #.sizeof(MGTK::Point)-1
:       lda     event_coords,x
        cmp     coords,x
        bne     diff
        dex
        bpl     :-
        clc
        rts

diff:   COPY_STRUCT MGTK::Point, event_coords, coords
        sec
        rts

        DEFINE_POINT coords, 0, 0
.endproc

;;; ============================================================

         ADJUSTCASE_VOLPATH := $810
         ADJUSTCASE_VOLBUF  := $820
         ADJUSTCASE_IO_BUFFER := $1C00
        .include "../lib/adjustfilecase.s"
        .include "../lib/muldiv.s"

        .include "../toolkits/letk.s"
        LETKEntry := letk::LETKEntry

;;; ============================================================

.endscope

file_dialog_init   := file_dialog::ep_init
file_dialog_loop   := file_dialog::ep_loop

        PAD_TO OVERLAY_ADDR + kOverlayFileDialogLength
        .assert * <= $BF00, error, "Overwrites ProDOS Global Page"
