        .include "../config.inc"

        .include "apple2.inc"
        .include "opcodes.inc"
        .include "../inc/macros.inc"
        .include "../inc/apple2.inc"
        .include "../inc/prodos.inc"
        .include "../mgtk/mgtk.inc"
        .include "../common.inc"

SAVE_AREA_BUFFER:= $0800
LOADER          := $2000
MGTKEntry       := $4000
FONT            := $8800
START           := $8E00

OVERLAY_ADDR    := MGTKEntry + kAppSegmentSize
SETTINGS        := OVERLAY_ADDR - .sizeof(DeskTopSettings)
BELLDATA        := SETTINGS - kBellProcLength

MLIEntry        := MLI

.enum AlertID
selector_unable_to_run  = $00
io_error                = $27
no_device               = $28
pathname_does_not_exist = $44
insert_source_disk      = $45
file_not_found          = $46
insert_system_disk      = $FE
basic_system_not_found  = $FF
.endenum

kAlertResultTryAgain    = 0
kAlertResultCancel      = 1
kAlertResultOK          = 0     ; NOTE: Different than DeskTop (=2)

;;; ============================================================
;;; SELECTOR file structure
;;; ============================================================

kInvokerOffset          = $600

_segoffset .set 0
.macro DEFSEG name, addr, len
        .ident(.sprintf("k%sAddress", .string(name))) = addr
        .ident(.sprintf("k%sSize", .string(name))) = len
        .ident(.sprintf("k%sOffset", .string(name))) = _segoffset
        _segoffset .set _segoffset + len
.endmacro

        _segoffset .set kInvokerOffset
        DEFSEG InvokerSegment, INVOKER, $160
        DEFSEG AppSegment, $4000, $6400
        DEFSEG AlertSegment, $D000, $800
        DEFSEG OverlayFileDialog, OVERLAY_ADDR, $1700
        DEFSEG OverlayCopyDialog, OVERLAY_ADDR, $D00

;;; ============================================================
;;; Selector application
;;; ============================================================

        .include "bootstrap.s"
        .include "quit_handler.s"

        ;; Ensure loader.starts at correct offset ($300) from start of file.
        .res 217

        .include "loader.s"
        .include "../lib/invoker.s"

        .include "app.s"
        .include "alert_dialog.s"
        .include "ovl_file_dialog.s"
        .include "ovl_file_copy.s"
