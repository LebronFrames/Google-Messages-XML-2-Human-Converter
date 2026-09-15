# Google Messages XML 2 Human Converter

**Version 2 Alpha**  
Created by [Lebron Frames](https://github.com/LebronFrames?tab=repositories)

## What this app does

Google Messages XML 2 Human Converter turns one conversation from an SMS Backup & Restore XML file into a readable HTML conversation.

It supports direct conversations and group chats, can include photos, video, and audio from MMS messages, and saves the finished conversation as a ZIP file.

## Privacy

Your messages stay on your computer.

The converter runs locally on `127.0.0.1`. It does not upload your backup, messages, attachments, or exported conversation to an external service. No account is required, and the app does not include analytics.

Temporary working files are removed when the converter closes.

## What you need

- A Windows computer
- An XML backup created by SMS Backup & Restore
- The converter EXE and its included launcher

## Important alpha notes

- This is an alpha release and is not code-signed.
- Phone-number matching currently expects 10-digit U.S. numbers.
- The app exports one selected conversation at a time.
- Closing the app removes its temporary workspace.
- Your original XML file and any ZIP already downloaded through the browser are not deleted.

## Starting the app

1. Double-click **Google Messages XML 2 Human Converter V2.exe**.
2. A terminal window will appear briefly and minimize automatically.
3. The converter will open in your default web browser.

> [!NOTE]
> Windows may display a security warning because this alpha build is not code-signed. Confirm that the file came from a source you trust before choosing to run it.

## Exporting a conversation

1. Choose or drag in your SMS Backup & Restore XML file.
2. Enter the name and phone number of the backup owner. The backup owner is the person whose phone created the XML backup.
3. Select **Find conversations**. The converter will read contact names and participant lists from the backup. This discovery scan may take some time for a very large XML file.
4. Search for and select a direct conversation or group chat. The list shows the detected contact name, phone number, message count, and most recent message date.
5. Review the detected participants. Contact names can be edited before opening the conversation. Phone numbers and complete participant sets are used for exact matching.
6. If a conversation cannot be detected, choose **Enter participants manually** and add everyone in the conversation.
7. Leave **Prepare photos, video, and audio** selected if you want media included in the finished export.
8. Select **Open conversation**.
9. Keep the browser page open while the backup is being searched. Large backups may take some time, but the app processes them as a stream instead of loading the entire file into memory.
10. Review the conversation preview.
11. Select **Create ZIP**.
12. Your browser will download the finished ZIP. The Done button at the bottom of the page will turn green when the ZIP is ready and the download has started.
13. Select **Done** to close the converter and its terminal window.

## Opening the finished export

1. Locate the downloaded ZIP file, usually in your Downloads folder.
2. Right-click the ZIP and choose **Extract All**.
3. Open `ConversationName.html` from the extracted folder.

If media was included, keep `conversation.html` and the `media` folder together. Moving the HTML file away from the media folder will break the photo, video, and audio links.

## The Done button

Done is available at the bottom center of the page at all times.

Selecting Done closes the local converter, removes temporary working files, and closes the dedicated terminal. The app also attempts to close its browser tab. If the browser prevents that, the page will confirm that the converter has closed and that the tab is safe to close manually.

> [!WARNING]
> Selecting Done during an upload, search, or export will stop that operation.

## Troubleshooting

### No messages were found

- Return to the conversation list and confirm that the correct conversation was selected.
- Confirm that every phone number is correct.
- Confirm that the correct person is marked as the backup owner.
- For group chats, include every participant in the group.
- U.S. numbers may include spaces, parentheses, hyphens, or a leading `+1`.

### Media is missing

- Enable **Prepare photos, video, and audio** before opening the conversation.
- Some backup records may name an attachment without containing its data.
- Browser support varies for older audio and video formats.

### The browser did not open

- Restore the minimized terminal window.
- Copy the local `http://127.0.0.1` address shown there into your browser.

### The terminal remained open after Done

- Start the app with the included BAT launcher.
- A PowerShell window that was opened manually belongs to PowerShell and will remain open after the converter exits.

### The HTML opens but media does not appear

- Extract the ZIP before opening `conversation.html`.
- Keep the `media` folder beside `conversation.html`.