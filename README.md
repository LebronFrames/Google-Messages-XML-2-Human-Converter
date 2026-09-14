# Google Messages XML 2 Human Converter

A terminal-based Windows PowerShell tool for exporting a specific conversation from a large SMS Backup & Restore XML file into a readable HTML file.

It supports two-person conversations and group chats, can optionally extract photos, videos, and audio, and shows a live progress bar while scanning large backups.

The converter streams the XML instead of loading the entire file into memory, which makes it practical for very large message backups.

**NOTE: Processing is all done locally, so this does NOT require an internet connection. All information stays on your machine.**

---

## Features

- Terminal-based setup and prompts
- Supports two-person or group conversations
- Exact participant matching for group conversations
- Streams large XML backups instead of loading them entirely into memory
- Live PowerShell progress bar during export
- Shows matching message and extracted media counts while scanning
- (Optional) Photo, video, GIF, and audio extraction
- Displays extracted media directly in the HTML
- Adds browser playback controls for extracted video and audio
- Preserves message text, sender names, dates, and times
- Creates a lightweight, readable chat-style HTML export
- Leaves the original XML backup unchanged

---

## Requirements

- Microsoft Windows
- Windows PowerShell
- An XML backup created by [SMS Backup & Restore](https://play.google.com/store/apps/details?id=all.backup.restore&hl=en-US&pli=1) 
- `Google Messages XML 2 Human Converter.ps1`

Script filename:

```text
Google Messages XML 2 Human Converter.ps1
```

Example XML filename:

```text
messages_backup.xml
```

---

## Setup

Save the script somewhere convenient, such as your Downloads folder.

Example:

```text
C:\Users\username\Downloads\Google Messages XML 2 Human Converter.ps1
```

The XML backup can be stored anywhere. For this example walkthrough, it will be stored in the Downloads folder. The script will ask you for its full file path when it starts. This can either be typed out or drag n' dropped into the PowerShell window.

---

## Running the script

Open PowerShell.

The terminal prompt should look similar to:

```text
PS C:\Users\username>
```

If PowerShell prevents scripts from running, enter:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```
![Step 1](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step1.png)

If prompted to confirm, enter:

```text
Y
```

This only changes the execution policy for the **current** PowerShell window.

Then run:

```powershell
& "C:\Users\username\Downloads\Google Messages XML 2 Human Converter.ps1"
```
![Step 2](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step2.png)

---

## Step 1: Enter the XML backup path

The script will ask:

```text
Path to XML backup:
```

Enter the full path to the XML file or drag the XML file into the window.

Example:

```text
C:\Users\username\Downloads\messages_backup.xml
```

If the path contains spaces, it will still work; you can paste it normally.

![Step 3A](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step3A.png)

OR

![Step 3B](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step3B.png)

---

## Step 2: Enter the number of people in the conversation

The script will ask:

```text
How many people are in the conversation?:
```

Count everyone in the conversation, including the owner of the phone that created the backup.

For a direct conversation:

```text
2
```

For a five-person group chat:

```text
5
```

---

## Step 3: Enter the backup owner

The backup owner is the person whose phone created the XML backup.

The script will ask:

```text
Backup owner's display name:
Backup owner's phone number:
```

Example:

```text
Backup owner's display name: Jane
Backup owner's phone number: (202) 555-0100
```

The backup owner should always be entered first.

![Step 4](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step4.png)

---

## Step 4: Enter the other participants

The script will ask for each additional participant one at a time.

Example:

```text
Participant 2 of 2
Display name: John
Phone number: (202) 555-0111
```

For group chats, continue entering every member until all participants have been added.

Example:

```text
Jane
(202) 555-0100

John
(202) 555-0111

Taylor
(202) 555-0122

Morgan
(202) 555-0133
```

U.S. phone numbers may be entered with or without:

- `+1`
- spaces
- parentheses
- hyphens

The script will normalize them automatically.

![Step 5](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step5.png)

---

## Group chat matching

For group conversations, enter every participant in the group.

The converter compares the participant list stored in the XML against the participant list you entered.

This helps prevent messages from a different group chat with overlapping members from being mixed into the export.

If no messages are found, double-check that every participant number is correct and that no member of the group was omitted.

---

## Step 5: Choose the output HTML path

The script suggests an output filename based on the participant names.

Example:

```text
C:\Users\username\Downloads\Jane_John.html
```

For a group chat:

```text
C:\Users\username\Downloads\Jane_John_Taylor_Morgan.html
```

The script will ask:

```text
Output HTML path [C:\Users\username\Downloads\Jane_John.html]:
```

Press Enter to use the `[suggested path]`, or type a different full path.

![Step 6](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step6.png)

---

## Step 6: Choose whether to extract media

The script will ask:

```text
Extract photos, videos, and audio from this conversation? [Y/n]
```

Press Enter or type:

```text
Y
```

to extract media.

Type:

```text
n
```

to create the HTML without extracting media.

![Step 7](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step7.png)

---

## Media extraction

If media extraction is enabled, the converter creates a companion media folder next to the HTML file.

Example:

```text
Jane_John.html
Jane_John_media\
    00001_photo.jpg
    00002_image.jpg
    00003_video.mp4
    00004_audio.m4a
```

The generated HTML links to these files using relative paths.

### Photos

Supported image attachments are displayed directly in the conversation.

Clicking an image opens the extracted original file.

### Video

Extracted video files are displayed with normal browser playback controls.

### Audio

Extracted audio files are displayed with browser audio controls.

### Unsupported or unavailable attachments

If an attachment cannot be extracted, the HTML displays a note rather than removing it.

---

## Progress bar

While the XML is being scanned, PowerShell shows a live progress bar.

Example:

```text
Exporting conversation
42% complete, 1,284 matching messages, 37 media files
```

The percentage is based on how far the script has read through the XML file.

For very large backups, the scan may still take some time, but the progress bar provides an estimate of how much of the file has been processed.

![Step 8](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step8.png)

---

## When the export finishes

The script reports the number of matching messages exported.

Example:

```text
Done. Exported 1,284 messages.
Extracted 37 media files.
Created:
C:\Users\username\Downloads\Jane_John.html
Media folder:
C:\Users\username\Downloads\Jane_John_media
```

It then asks:

```text
Open the HTML now? [Y/n]
```
![Step 9](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/Step9.png)

Press Enter or type:

```text
Y
```

to open the conversation immediately.

Type:

```text
n
```

to finish without opening it.

---

## What the HTML includes

![Step 10](https://github.com/LebronFrames/Google-Messages-XML-2-Human-Converter/blob/V1/Images/StepFINAL.png)

The generated HTML includes:

- message text
- sender names
- readable dates
- readable times
- sent and received message alignment
- date separators
- extracted photos when available
- extracted video playback when available
- extracted audio playback when available
- attachment notes when a file could not be embedded
- dark mode support

The HTML can be opened directly in a normal web browser.

No web server is required.

---

## Sharing an export

### Without media

If media extraction was disabled, the `.html` file can usually be shared by itself.

Example:

```text
Jane_John.html
```

### With media

If media extraction was enabled, the HTML depends on its companion `_media` folder.

Both must stay together.

Example:

```text
Jane_John.html
Jane_John_media\
```

The easiest way to share the complete export is to place both into a ZIP file.

For example:

```text
Jane_John_Conversation.zip
    Jane_John.html
    Jane_John_media\
```

Do not rename or move the media folder separately from the HTML unless you also update the paths inside the HTML.

---

## Troubleshooting

### PowerShell says scripts are disabled

Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Then run the converter again.

---

### The script cannot find the XML file

Check that the full path was entered correctly.

Example:

```text
C:\Users\username\Downloads\messages_backup.xml
```

You can also drag the XML file into the PowerShell window to paste its path, then remove quotation marks if necessary.

---

### No messages were found

Check that:

- the backup owner's phone number is correct
- the backup owner was entered first
- the other participant numbers are correct
- every group chat participant was included
- the selected conversation actually exists in the XML backup

For group chats, the participant list must match the group stored in the backup.

---

### The export is missing photos or videos

Not every attachment is necessarily stored directly inside the XML.

The converter can extract media when the backup contains the attachment data in the XML.

If the backup only contains a reference to an attachment rather than the attachment data itself, that file cannot be reconstructed from the XML alone.

---

### The HTML opens but images or videos are missing

If media extraction was enabled, make sure the HTML file and its `_media` folder are still stored next to each other.

For example:

```text
Jane_John.html
Jane_John_media\
```

Moving only the HTML file will break the media links.

---

### The XML file is very large

That is expected.

The converter uses streaming XML parsing, so it does not need to load the entire backup into RAM.

Very large backups may still take time to scan because the entire XML file must be examined to find the requested conversation.

---

### The exported files are much smaller than the original XML

This is normal.

The original backup may contain:

- messages from many conversations
- MMS metadata
- embedded images
- embedded video or audio
- application-specific metadata

The converter only exports the selected conversation.

---

## Privacy

Message backups and exported conversations can contain private information, including:

- message content
- names
- phone numbers
- dates and times
- photos
- videos
- audio
- personal conversation history

Only store or share these files with people who you want to be able to see them. If you are unsure, ask. Consent is key.

---

## Quick reference

Allow scripts in the current PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Run the converter:

```powershell
& "C:\Users\username\Downloads\Google Messages XML 2 Human Converter.ps1"
```

The converter will then ask you to:

1. enter the XML backup path
2. enter the number of participants
3. enter the backup owner
4. enter the other participants
5. choose the HTML output path
6. choose whether to extract media
7. wait for the progress bar to complete
8. optionally open the finished HTML
