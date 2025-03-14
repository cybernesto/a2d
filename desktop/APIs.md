
# DeskTop APIs

There are two distinct API classes that are used within DeskTop and
Desk Accessories:

* Toolkits with MLI-style interfaces, including:
  * [MouseGraphics ToolKit](../mgtk/MGTK.md)
  * [Icon ToolKit](../toolkits/IconTK.md)
  * [LineEdit ToolKit](../toolkits/LETK.md)
  * [Button TookKit](../toolkits/BTK.md)
* DeskTop Jump Table - simple JSR calls starting at $4003 MAIN, no arguments

<!-- ============================================================ -->

## DeskTop Jump Table

Call from MAIN (RAMRDOFF/RAMWRTOFF); AUX language card RAM must be banked in. Call style:
```
   jsr $xxxx
```
Some calls take MLI-style parameters, or in registers.

> Routines marked with * are used by Desk Accessories.

#### `JUMP_TABLE_MGTK_CALL` *

MouseGraphics ToolKit call (main>aux).

Input: Follow `JSR` by call (`.byte`) and params (`.addr`), MLI-style.
Output: A=result

(Param data must reside in aux memory, lower 48k or LC banks.)

Use the `JUMP_TABLE_MGTK_CALL` macro (yes, same name) for convenience.

#### `JUMP_TABLE_MLI_CALL` *

ProDOS MLI call.

Input: Follow `JSR` by call (`.byte`) and params (`.addr`), MLI-style.
Output: C set on error, A = error code.

(Param data must reside in main memory, lower 48k.)

Use the `JUMP_TABLE_MLI_CALL` macro (yes, same name) for convenience.

#### `JUMP_TABLE_CLEAR_UPDATES` *

Clear update events - i.e. redraw windows as needed after move/resize/close.

#### `JUMP_TABLE_YIELD_LOOP` *

Yield during an event loop for DeskTop to run tasks. This allows the menu bar clock to be updated and similar infrequent operations.

Desk Accessories should call this (from main!) from their event loop unless they need to have total control of the system (e.g. screen savers). A good place to do this is just before a call to `MGTK::GetEvent`. Note that the current grafport may be modified during this call.

Yielding during further nested loops (e.g. button tracking, etc) can be done but is not worth the effort.

#### `JUMP_TABLE_SELECT_WINDOW` *

Select and refresh the specified window (A = window id)

#### `JUMP_TABLE_SHOW_ALERT` *

Show alert, with default button options for error number

Error number is in A - either a ProDOS error number, or a DeskTop `kErrXXX` error as defined in `desktop/desktop.inc`.

NOTE: This will use Aux $800...$1AFF to save the alert background; be careful when calling from a Desk Accessory, which may run from the same area.

#### `JUMP_TABLE_SHOW_ALERT_OPTIONS`

Show alert, with custom button options.

Error number is in A - either a ProDOS error number, or a DeskTop `kErrXXX` error as defined in `desktop/desktop.inc`.

Button options are in X per `desktop/desktop.inc`.

NOTE: This will use Aux $800...$1AFF to save the alert background; be careful when calling from a Desk Accessory, which may run from the same area.

#### `JUMP_TABLE_LAUNCH_FILE`

Launch file. Equivalent of **File > Open** command.

#### `JUMP_TABLE_RESTORE_OVL` *

Restore from overlay routine

Routines are defined in `desktop/desktop.inc`.

#### `JUMP_TABLE_COLOR_MODE` *
#### `JUMP_TABLE_MONO_MODE` *

Set DHR color or monochrome mode, respectively. DHR monochrome mode is supported natively on the Apple IIgs, and via the AppleColor card and Le Chat Mauve, and is used by default by DeskTop. Desk Accessories that display images or exit DeskTop can can toggle the mode.

#### `JUMP_TABLE_RGB_MODE` *

Set DHR color or monochrome mode, based on control panel setting.

#### `JUMP_TABLE_RESTORE_SYS` *

Used when exiting DeskTop; exit DHR mode, restores DHR mode to color, restores detached devices and reformats /RAM if needed, and banks in ROM and main ZP.

#### `JUMP_TABLE_GET_SEL_COUNT` *

Get number of selected icons.

Output: A = count.

#### `JUMP_TABLE_GET_SEL_ICON` *

Get selected IconEntry address.

Input: A = index within selection.
Output: A,X = address of IconEntry.

#### `JUMP_TABLE_GET_SEL_WIN` *

Get window containing selection (if any).

Output: A = window_id, or 0 for desktop.

#### `JUMP_TABLE_GET_WIN_PATH` *

Get path to window.

Input: A = window_id.
Output: A,X = address of path (length-prefixed).

#### `JUMP_TABLE_HILITE_MENU` *

Toggle hilite on last clicked menu. This should be used by a desk accessory that repaints the entire screen including the menu bar, since when the desk accessory exits the menu used to invoke it (Apple or File) will toggle.

#### `JUMP_TABLE_ADJUST_FILEENTRY` *

Adjust case in FileEntry structure. If GS/OS filename bits are set, those are used. If the file type is an AppleWorks file, the auxtype bits are used. Otherwise, case is inferred.

Input: A,X = FileEntry structure.

#### `JUMP_TABLE_GET_RAMCARD_FLAG` *

Returns Z=1/N=0 if DeskTop is running from its original location, and Z=0/N=1 if DeskTop was copied to RAMCard.

#### `JUMP_TABLE_GET_ORIG_PREFIX` *

If DeskTop was copied to RAMCard, this populates the passed buffer with the original prefix path (with trailing `/`). Do not call unless DeskTop was copied to RAMCard.

Input: A,X = Path buffer.

#### `JUMP_TABLE_BELL` *

Play the alert sound, as specified in settings.
