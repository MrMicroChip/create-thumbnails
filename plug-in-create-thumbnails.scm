#!/usr/bin/env gimp-script-fu-interpreter-3.0
;!# Close comment started on first line. Needed by gettext.
;    File:         plug-in-create-thumbnails.scm
;    Application:  GIMP
;    Language:     Script-Fu
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;;;  Procedure:    plug-in-create-thumbnails
;;;
;;;  *) Creates thumbnails in the target directory, of all JPGs
;;;     found in the source directory.
;;;  *) Filename is case insensitive (converts xyz.jpg or XYZ.JPG).
;;;  *) Interactive program to be run WITHOUT AN IMAGE LOADED.
;;;  *) Program prompts for a source JPG directory and a target
;;;     thumbnail directory.
;;;
;;;  Dec-2016  John Appleyard  Created under GIMP v2.8.18
;;;  Apr-2026  John Appleyard  Heavily updated to run under GIMP v3.2.2
;;;
;;;  Copyright 2016, 2026 John Appleyard
;;;
;;;  This program is free software: you can redistribute it and/or modify it
;;;  under the terms of the GNU General Public License as published by the
;;;  Free Software Foundation, either version 3 of the License, or (at your
;;;  option) any later version.
;;;
;;;  This program is distributed in the hope that it will be useful, but
;;;  WITHOUT ANY WARRANTY; without even the implied warranty of
;;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;;;  General Public License for more details.
;;;
;;;  You should have received a copy of the GNU General Public License along
;;;  with this program. If not, see <https://www.gnu.org/licenses/>. 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

(define (plug-in-create-thumbnails sourceDirectory targetDirectory appendOption)
   (script-fu-use-v3)             ;;; Use the v3 Script-Fu interpreter.
   (let*
      (
         ;;; Declare and Init Local variables.
         (appendToFileName "")    ;;; Default is to append nothing to the thumbnail file name.
         (carryingOn #t)          ;;; Flag which determines whether execution continues.
         (debugging #f)           ;;; Toggle, as required (#t or #f).  Debug messages are written to StdOut.
         (newWidth 200)           ;;; Width of all new thumbnails.
         ;;; Form path/file patternSource.
         (patternSource (string-append sourceDirectory DIR-SEPARATOR "*.[jJ][pP][gG]"))
         (patternTarget (string-append targetDirectory DIR-SEPARATOR "*.[jJ][pP][gG]"))
         ;;; List of files to be converted.
         (filelistSource (file-glob #:pattern patternSource #:filename-encoding #t))
         (filelistTarget (file-glob #:pattern patternTarget #:filename-encoding #t))
         ;;; Place holders for image variables - updated per image.
         (baseName "")
         (currentFile "")
         (myImage 0)
         (newHeight 0)            ;;; Height of thumbnail.
         (oldHeight 0)            ;;; Height of image.
         (oldWidth 0)             ;;; Width of image
         (outFilename "")
         (ratio 0.0)              ;;; Ratio of size, image -> thumbnail.
      ) ;;; End-of declaration of Local Variables ...

      ;;; The third procedure parameter, 'appendOption', will equate to 0, 1, or 2.  Not
      ;;; to be confused with the filename suffix, jpg, which will be added automatically.
      ;;; 0 = "", 1 = "-tmb", 2 = "tmb".
      ;;; appendToFileName defaults to "" in init (above), so 0 doesn't need to be handled here.
      (if (= appendOption 1) (set! appendToFileName "-tmb"))
      (if (= appendOption 2) (set! appendToFileName "tmb"))

      ;;; Make sure there are no open images, otherwise set flag and display message.
      (if (> (vector-length (gimp-get-images)) 0)
         (begin
            (set! carryingOn #f)
            ;;; This message will display in the 'Windows > Dockable Dialogs > Error Console'.
            (gimp-message "Close any open Images before running this script." )
         )
      )

      ;;; Make sure there are no JPG files in the target directory, otherwise set flag and display message.
      (if (not (null? filelistTarget))
         (begin
            (set! carryingOn #f)
            ;;; This message will display in the 'Windows > Dockable Dialogs > Error Console'.
            (gimp-message "There are already JPG files in the target directory.")
         )
      )

      ;;; If we're clear to continue execution.
      (if carryingOn
         (begin
            ;;; 'baseName' is filename WITHOUT .jpg extension.
            ;;; 'outFilename' is filename WITH .jpg extension.
            ;;; Step through each file in list with while loop.
            (while (not (null? filelistSource))
               (set! currentFile (car filelistSource))
               ;;; Load the Image.
               (set! myImage (gimp-file-load RUN-NONINTERACTIVE currentFile))
               ;;; Form the thumbnail file name.
               (set! baseName (car (reverse (strbreakup currentFile DIR-SEPARATOR))))
               (set! baseName (car (strbreakup baseName ".")))
               (set! outFilename (string-append targetDirectory DIR-SEPARATOR baseName appendToFileName ".jpg"))
               (if debugging (display (string-append outFilename "\n")))  ; Debug message.
               ;;; --- Start:  Resize image ---
               (set! oldWidth (gimp-image-get-width myImage))
               (set! ratio (/ oldWidth newWidth))
               (set! oldHeight (gimp-image-get-height myImage))
               (set! newHeight (truncate (/ oldHeight ratio)))
               (gimp-image-scale myImage newWidth newHeight)
               ;;; --- End:  Resize image ---
               ;;; Save the thumbnail.
               (file-jpeg-export #:run-mode RUN-NONINTERACTIVE
                                 #:image myImage
                                 #:file outFilename
                                 #:options -1
                                 #:quality 0.9
                                 #:smoothing 0
                                 #:optimize #t
                                 #:progressive #t
                                 #:cmyk #f
                                 #:sub-sampling "sub-sampling-1x1"
                                 #:baseline #t
                                 #:restart 0
                                 #:dct "integer"
                                 #:include-exif #f
                                 #:include-iptc #f
                                 #:include-xmp #f
                                 #:include-color-profile #f
                                 #:include-thumbnail #f
                                 #:include-comment #f)
               ;;; Delete the in-memory image.
               (gimp-image-delete myImage)
               ;;; Update while loop iterator.
               (set! filelistSource (cdr filelistSource))
            ) ;;; End while.
         ) ;;; End-of if carryingOn begin.

      ) ;;; End-of if carryingOn.

      ;;; If we've created the thumbnails, let the User know.
      ;;; This message will display in the 'Windows > Dockable Dialogs > Error Console'.
      (if carryingOn (gimp-message "Finished."))

   ) ;;; End-of let*.

) ;;; End-of define.

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

; For details, see:- https://developer.gimp.org/resource/script-fu/programmers-reference/#script-fu-special-functions
(script-fu-register-procedure "plug-in-create-thumbnails"        ;;; Procedure Name.
   "Create Thumbnails..."                                        ;;; Menu Item Label.
   "This is an interactive plug-in that creates thumbnails in
    the target directory, of all JPGs found in the source
    directory. The plug-in is designed to be run WITHOUT ANY
    IMAGE LOADED."                                               ;;; Description.
   "John Appleyard"                                              ;;; Author.
   "2016-2026"                                                   ;;; Date.
   SF-DIRNAME "Source _JPG Directory" ""
   SF-DIRNAME "_Target thumbnails Directory" ""
   SF-OPTION "_Append to thumbnail name" '("" "-tmb" "tmb")      ;;; Do NOT alter the order, without adjusting the logic elsewhere.
) ;;; End script-fu-register-procedure.

; Add a Menu.
(script-fu-menu-register "plug-in-create-thumbnails" "<Image>/MyPlugIns")

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
