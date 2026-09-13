# Google Messages XML 2 Human Converter

A lightweight Windows PowerShell tool for exporting a specific conversation from a large SMS Backup & Restore XML file into a readable, self-contained HTML file.

The tool is designed for large backups and streams the XML instead of loading the entire file into memory.

## What it does

The converter lets you:

- Choose an XML backup with a file picker
- Enter the backup owner's name and phone number
- Add one or more other conversation participants
- Export either:
  - a two-person conversation
  - a group chat
- Match group chats by their exact participant list
- Save the result as a single HTML file
- Preserve:
  - message text
  - dates and times
  - sender names
  - message direction
  - attachment placeholders
- Open the finished HTML immediately after export

To keep the output lightweight, image, video, audio, and other binary MMS media are not embedded in the HTML.

---

## Requirements

- Windows
- Windows PowerShell
- An XML backup created by SMS Backup & Restore
- `Google Messages XML 2 Human Converter.ps1`

Example XML filename:

```text
messages_backup.xml
```

Example script filename:

```text
Google Messages XML 2 Human Converter.ps1
```

---

## Setup

Put the PowerShell script somewhere convenient, such as your Downloads folder.

Example:

```text
C:\Users\username\Downloads\Google Messages XML 2 Human Converter.ps1
```

The XML backup can be stored anywhere because the script will ask you to select it.

---

## Running the script

Open PowerShell.

If PowerShell opens at something like:

```text
PS C:\Users\username>
```

that is fine.

If this is a new PowerShell window, run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

If prompted to confirm, enter:

```text
Y
```

This only changes the execution policy for the current PowerShell window.

Then run the converter:

```powershell
& "C:\Users\username\Downloads\Google Messages XML 2 Human Converter.ps1"
```

---

## Using the interactive converter

### 1. Select the XML backup

A file picker will open.

Choose the SMS Backup & Restore XML file you want to process.

Example:

```text
messages_backup.xml
```

---

### 2. Enter the backup owner

The next window asks for the person whose phone created the backup.

Example:

```text
Name: Jane
Phone number: (202) 555-0100
```

The backup owner should always be entered first.

---

### 3. Add the other participants

Add one row for each other person in the conversation.

Two-person example:

```text
Jane
(202) 555-0100

John
(202) 555-0111
```

Group chat example:

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

You may enter U.S. phone numbers with or without:

- `+1`
- spaces
- parentheses
- hyphens

The script normalizes them automatically.

---

## Group chat matching

For group conversations, enter every participant in the conversation.

The converter compares the participant list in the XML against the participant list you entered.

This helps prevent messages from a different group chat with overlapping members from being mixed into the export.

---

## Saving the HTML

After entering the participants, a Save As window will appear.

The script suggests a filename based on the participant names.

Example:

```text
Jane_John.html
```

or:

```text
Jane_John_Taylor_Morgan.html
```

Choose where you want to save it and click Save.

---

## While the XML is processing

A progress window will appear while the XML is scanned.

Large backups may take some time.

The converter reads the XML as a stream, so even very large files do not need to be loaded entirely into memory.

The progress window will show how many matching messages have been found.

---

## When the export finishes

A completion message will show:

- how many messages were exported
- the location of the HTML file

You will also be asked whether you want to open the HTML immediately.

The finished file can be opened in a normal web browser such as:

- Chrome
- Edge
- Firefox

No web server is required.

---

## What the HTML includes

The exported HTML includes:

- message text
- readable dates
- readable times
- sender names
- incoming and outgoing message alignment
- date separators
- dark mode support
- attachment placeholders

Example attachment placeholder:

```text
Attachment omitted from lightweight export: image/jpeg
```

---

## What the HTML does not include

To keep the file small and easy to share, the converter does not embed binary MMS media such as:

- photos
- videos
- audio
- other large attachments

The XML backup itself is not modified.

---

## Troubleshooting

### PowerShell says scripts are disabled

Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Then run the converter again.

---

### No messages were found

Check:

- the phone numbers were entered correctly
- the backup owner was entered first
- every group chat participant was included
- the conversation actually exists in the selected backup

For group chats, the participant list must match the group stored in the XML.

---

### The script will not start

Make sure the script path is correct.

Example:

```powershell
& "C:\Users\username\Downloads\Google Messages XML 2 Human Converter.ps1"
```

If the script is stored somewhere else, update the path accordingly.

---

### The XML file is very large

That is expected.

The converter was designed to process large SMS Backup & Restore XML files using streaming XML parsing.

A multi-gigabyte backup may still take time to scan, but it should not require equivalent RAM.

---

### The exported HTML is much smaller than the XML

This is expected.

SMS Backup & Restore XML files may contain large amounts of metadata and binary MMS data.

The converter keeps the readable message content and omits the embedded binary media.

---

## Privacy

Message backups and exported HTML files may contain private information, including:

- message content
- names
- phone numbers
- dates and times
- personal conversation history

Only store or share these files with people who are authorized to access them.

---

## Quick reference

Allow the script to run in the current PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Run the converter:

```powershell
& "C:\Users\username\Downloads\Google Messages XML 2 Human Converter.ps1"
```

Then use the interactive windows to:

1. select the XML backup
2. enter the backup owner
3. add the other participants
4. choose an output filename
5. wait for the export to complete
