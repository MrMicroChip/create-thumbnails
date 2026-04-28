# "Create Thumbnails"
## A Script-Fu example for GIMP
This Script-Fu procedure does a useful job - it processes all JPG files in a particular directory, 
and generates their corresponding thumbnail images (200 pixels wide) in another directory.  However,
the motivation for sharing is because I found it so hard to write!

Some years ago, I had originally written the procedure for use with GIMP v2.\*. I recently upgraded
to GIMP v3.\* and discovered that the Script-Fu implementation had significantly changed, and my
procedure no longer worked.

What followed was several days of frustration, trying to work out what worked and what needed
modifying.  It didn't help that GIMP provides no meaningful mechanism for debugging Script-Fu
procedures, so progress was slow.  Anyway, it now executes (within GIMP v3.2.2) *Warning* and *Error*
free, fully utilizing the updated Script-Fu interpreter in that version of GIMP.

## Installing the plug-in
According to GIMP, a Script-Fu procedure (a plain text file with an ".scm" suffix) is now a
*plug-in*.  It used to be a *script*.

### Plug-In Directory
You need to identify your GIMP plug-in directory, which will be dependent upon on your operating
system and the options you choose when installing GIMP itself.  One way to do this is via the
*Script-FU Console* which can be found via the following GIMP menu ...\
`Filters > Development > Script-Fu > Script-Fu Console`

In the *Script Console* dialog, type the following (including the parentheses) and hit the \<RETURN\> key ...\
`(display gimp-plug-in-directory)`\
You will see something like ...\
`C:\Program Files\GIMP 3\lib\gimp\3.0#t`\
In this example, you can ignore "#t" (which represents the boolean value TRUE in Script-Fu).  Look in 
**C:\Program Files\GIMP 3\lib\gimp\3.0** and you should see a **plug-ins** directory (amongst others).

### Create a new directory
In the GIMP plug-in directory (from our example above, that is **C:\Program Files\GIMP 3\lib\gimp\3.0\plug-ins**)
create a new directory.  The new directory must have the same name as your Script-Fu procedure file (excluding the
".scm" suffix).  So, my Script-Fu procedure is a plain text file named "plug-in-create-thumbnails.scm" and the
corresponding new directory must be named "**plug-in-create-thumbnails**".

### Copy procedure file
Place a copy of the Script-Fu procedure plain text file into the newly created directory.  The full path to
the newly installed procedure (using my example) will be ...\
`C:\Program Files\GIMP 3\lib\gimp\3.0\plug-ins\plug-in-create-thumbnails\plug-in-create-thumbnails.scm`

### Restart GIMP
In order for GIMP to be able to *see* the new plug-in, shutdown and restart GIMP.  During startup, GIMP
registers the plug-ins it finds and adds any menu items that these plug-ins define.  You should now see
a top-level GIMP menu, **MyPlugIns**, and a menu item within it, **Create Thumbnails...**.  This completes
the installation of the *Create Thumbnails* procedure (plug-in).

## Executing the plug-in
Before starting the plug-in, I recommend that you ensure that the GIMP *Error Console* and
*Status Bar* are visible.

### Error Console
Under GIMP v2.\*, the Script-Fu function (gimp-message \<text to display\>) used to display a Message
Box dialog, which contained any information text for the User.  I couldn't replicate this behaviour
under GIMP v3.\*.  So, any User messages will now appear in the GIMP *Error Console*.  If the *Error
Console* is not visible to you, you can make it visible via the following GIMP menu ...\
`Windows > Dockable Dialogs > Error Console`

### Status Bar
During execution, GIMP will update the GIMP *Status Bar* with various messages, to indicate what the
plug-in is doing at that moment in time.  The *Status Bar* is a strip that runs along the bottom of
the main GIMP window. If the *Status Bar* is not visible to you, you can make it visible via the
following GIMP menu ...\
`View > Show Statusbar`

### Off We Go
To start execution, click on the following GIMP menu ...\
`MyPlugIns > Create Thumbnails...`

## During plug-in Execution
A few observations in respect of actions whilst the plug-in is running.

### Initial Dialog
Once you start the plug-in, a Dialog Box will be displayed, which will enable you to
provide the information required, as follows:-
`Source JPG Directory`\
You should select the directory that contains one or more JPG files.  The plug-in will create a
thumbnail of each of these files.\
`Target thumbnails Directory`\
You should select the directory where you want the thumbnails to be saved.\
`Append to thumbnail name`\
You have the option to modify the filename of the thumbnail.  Three options exist ...
| Option          | Original Name        | Thumbnail Name        |
| --------------- | -------------------- | --------------------- |
| \<leave empty\> | MyImage.jpg          | MyImage.jpg           |
| -tmb            | MyImage.jpg          | MyImage-tmb.jpg       |
| tmb             | MyImage.jpg          | MyImagetmb.jpg        |

Once you have provided this information, you can click the **OK** button to proceed, or the **Cancel**
button to stop.

### A Couple of Checks
Two checks are now made by the plug-in, before it starts creating thumbnails.  Firstly, it verifies that you do
not have any open images in the main GIMP interface and, secondly, it verifies that there are no JPG files in
the directory that you have specified as the thumbnail directory.  If either of these situations are found, it
will display a message in the GIMP *Error Console* and stop.

### Processing starts
Once the above checks have been successfully completed, the plug-in will process each JPG file that it finds
in the *Source JPG Directory*.  In the GIMP *Status Bar*, you will see each source image file being loaded,
scaled, and exported to the *Target thumbnails Directory*. Once all files have been processed, the message
"Finished." will be displayed in the GIMP *Error Console*.




