# Google Messages XML 2 Human Converter
# Terminal-based Windows PowerShell utility.
# Exports a specific conversation from an SMS Backup & Restore XML file
# into a readable HTML file, with optional media extraction.

$ErrorActionPreference = "Stop"

function Normalize-Phone([string]$Phone) {
    if ([string]::IsNullOrWhiteSpace($Phone)) { return "" }
    $digits = $Phone -replace '\D', ''
    if ($digits.Length -eq 11 -and $digits.StartsWith("1")) {
        $digits = $digits.Substring(1)
    }
    return $digits
}

function Html([string]$Text) {
    if ($null -eq $Text) { return "" }
    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Safe-FileName([string]$Text) {
    $safe = $Text -replace '[^\p{L}\p{Nd}\._-]+', '_'
    $safe = $safe.Trim('_')
    if ([string]::IsNullOrWhiteSpace($safe)) { return "file" }
    return $safe
}

function Extension-FromMime([string]$Mime) {
    switch -Regex ($Mime) {
        '^image/jpeg$'       { return '.jpg' }
        '^image/png$'        { return '.png' }
        '^image/gif$'        { return '.gif' }
        '^image/webp$'       { return '.webp' }
        '^image/heic$'       { return '.heic' }
        '^image/heif$'       { return '.heif' }
        '^video/mp4$'        { return '.mp4' }
        '^video/3gpp$'       { return '.3gp' }
        '^video/quicktime$'  { return '.mov' }
        '^video/webm$'       { return '.webm' }
        '^audio/mpeg$'       { return '.mp3' }
        '^audio/mp4$'        { return '.m4a' }
        '^audio/ogg$'        { return '.ogg' }
        '^audio/amr$'        { return '.amr' }
        default              { return '.bin' }
    }
}

Write-Host ""
Write-Host "Google Messages XML 2 Human Converter"
Write-Host "====================================="
Write-Host ""

$defaultXml = Join-Path $env:USERPROFILE "Downloads\messages_backup.xml"
$prompt = "Path to XML backup"
if (Test-Path -LiteralPath $defaultXml) { $prompt += " [$defaultXml]" }

$InputFile = Read-Host $prompt
if ([string]::IsNullOrWhiteSpace($InputFile)) {
    if (Test-Path -LiteralPath $defaultXml) { $InputFile = $defaultXml }
    else { throw "No XML file path was entered." }
}
$InputFile = $InputFile.Trim('"')

if (-not (Test-Path -LiteralPath $InputFile)) {
    throw "Input file not found: $InputFile"
}

Write-Host ""
Write-Host "Enter everyone in the conversation, INCLUDING the owner of the phone that created the backup."
Write-Host ""

do {
    $countText = Read-Host "How many people are in the conversation?"
    $participantCount = 0
    $validCount = [int]::TryParse($countText, [ref]$participantCount) -and $participantCount -ge 2
    if (-not $validCount) { Write-Host "Enter a whole number of 2 or greater." -ForegroundColor Yellow }
} until ($validCount)

$participants = [System.Collections.Generic.List[object]]::new()

Write-Host ""
Write-Host "First, enter the person whose phone created this backup."
Write-Host ""

do { $ownerName = Read-Host "Backup owner's display name" }
until (-not [string]::IsNullOrWhiteSpace($ownerName))

do {
    $ownerPhoneRaw = Read-Host "Backup owner's phone number"
    $ownerPhone = Normalize-Phone $ownerPhoneRaw
    if ($ownerPhone.Length -ne 10) { Write-Host "Enter a valid 10-digit U.S. phone number." -ForegroundColor Yellow }
} until ($ownerPhone.Length -eq 10)

$participants.Add([pscustomobject]@{
    Name = $ownerName.Trim()
    Phone = $ownerPhone
    IsOwner = $true
})

for ($i = 2; $i -le $participantCount; $i++) {
    Write-Host ""
    Write-Host "Participant $i of $participantCount"

    do { $name = Read-Host "Display name" }
    until (-not [string]::IsNullOrWhiteSpace($name))

    do {
        $phoneRaw = Read-Host "Phone number"
        $phone = Normalize-Phone $phoneRaw
        if ($phone.Length -ne 10) { Write-Host "Enter a valid 10-digit U.S. phone number." -ForegroundColor Yellow }
    } until ($phone.Length -eq 10)

    $participants.Add([pscustomobject]@{
        Name = $name.Trim()
        Phone = $phone
        IsOwner = $false
    })
}

$targetPhones = @($participants | ForEach-Object { $_.Phone } | Sort-Object -Unique)
if ($targetPhones.Count -ne $participants.Count) {
    throw "Two or more participants have the same normalized phone number."
}

$nameByPhone = @{}
foreach ($p in $participants) { $nameByPhone[$p.Phone] = $p.Name }

$otherPhones = @($participants | Where-Object { -not $_.IsOwner } | ForEach-Object { $_.Phone })

Write-Host ""
Write-Host "Conversation to export:"
foreach ($p in $participants) {
    $tag = if ($p.IsOwner) { "  [backup owner]" } else { "" }
    Write-Host ("  {0}: {1}{2}" -f $p.Name, $p.Phone, $tag)
}

$defaultFolder = Split-Path -Parent $InputFile
$defaultBaseName = Safe-FileName (($participants | ForEach-Object { $_.Name }) -join "_")
$defaultOutput = Join-Path $defaultFolder ($defaultBaseName + ".html")

Write-Host ""
$OutputFile = Read-Host "Output HTML path [$defaultOutput]"
if ([string]::IsNullOrWhiteSpace($OutputFile)) { $OutputFile = $defaultOutput }
$OutputFile = $OutputFile.Trim('"')

$mediaChoice = Read-Host "Extract photos, videos, and audio from this conversation? [Y/n]"
$ExtractMedia = [string]::IsNullOrWhiteSpace($mediaChoice) -or ($mediaChoice.Trim().ToLower() -eq "y")

$MediaFolder = $null
$MediaRelativeFolder = $null

if ($ExtractMedia) {
    $outputDir = Split-Path -Parent $OutputFile
    $outputBase = [System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
    $mediaDirName = (Safe-FileName $outputBase) + "_media"
    $MediaFolder = Join-Path $outputDir $mediaDirName
    $MediaRelativeFolder = $mediaDirName
    New-Item -ItemType Directory -Path $MediaFolder -Force | Out-Null
}

Write-Host ""
Write-Host "Scanning backup..."
if ($ExtractMedia) {
    Write-Host "Matching media will be extracted into: $MediaFolder"
} else {
    Write-Host "Media extraction disabled."
}
Write-Host ""

$messages = [System.Collections.Generic.List[object]]::new()
$mediaCounter = 0

$settings = [System.Xml.XmlReaderSettings]::new()
$settings.IgnoreWhitespace = $true
$settings.IgnoreComments = $true
$settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
$settings.CloseInput = $true

$stream = [System.IO.File]::Open(
    $InputFile,
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::Read,
    [System.IO.FileShare]::Read
)

$reader = [System.Xml.XmlReader]::Create($stream, $settings)

$fileLength = $stream.Length
$lastProgress = -1
$progressStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$currentMms = $null
$mmsText = [System.Collections.Generic.List[string]]::new()
$mmsParts = [System.Collections.Generic.List[object]]::new()
$mmsAddresses = [System.Collections.Generic.List[string]]::new()
$senderCandidates = [System.Collections.Generic.List[string]]::new()

try {
    while ($reader.Read()) {

        # Update the terminal progress bar at most about 4 times per second.
        if ($progressStopwatch.ElapsedMilliseconds -ge 250) {
            $progressStopwatch.Restart()

            if ($fileLength -gt 0) {
                $percent = [math]::Floor(($stream.Position / $fileLength) * 100)
                if ($percent -gt 100) { $percent = 100 }

                if ($percent -ne $lastProgress) {
                    $status = "{0}% complete, {1:N0} matching messages, {2:N0} media files" -f $percent, $messages.Count, $mediaCounter

                    Write-Progress `
                        -Activity "Exporting conversation" `
                        -Status $status `
                        -PercentComplete $percent

                    $lastProgress = $percent
                }
            }
        }

        if ($reader.NodeType -eq [System.Xml.XmlNodeType]::Element) {

            if ($reader.Name -eq "sms" -and $participantCount -eq 2) {
                $address = Normalize-Phone ($reader.GetAttribute("address"))

                if ($otherPhones -contains $address) {
                    $dateRaw = $reader.GetAttribute("date")
                    $type = $reader.GetAttribute("type")
                    $body = $reader.GetAttribute("body")
                    $readable = $reader.GetAttribute("readable_date")

                    $dateMs = 0L
                    [void][long]::TryParse($dateRaw, [ref]$dateMs)

                    $direction = if ($type -eq "1") { "received" } else { "sent" }
                    $senderPhone = if ($direction -eq "sent") { $ownerPhone } else { $address }

                    $messages.Add([pscustomobject]@{
                        DateMs = $dateMs
                        ReadableDate = $readable
                        Direction = $direction
                        SenderPhone = $senderPhone
                        Text = $body
                        Attachments = @()
                    })
                }
            }

            elseif ($reader.Name -eq "mms") {
                $dateRaw = $reader.GetAttribute("date")
                $msgBox = $reader.GetAttribute("msg_box")
                $addressRaw = $reader.GetAttribute("address")
                $readable = $reader.GetAttribute("readable_date")

                $dateMs = 0L
                [void][long]::TryParse($dateRaw, [ref]$dateMs)

                $currentMms = [pscustomobject]@{
                    DateMs = $dateMs
                    ReadableDate = $readable
                    Direction = $(if ($msgBox -eq "1") { "received" } else { "sent" })
                    MainAddress = Normalize-Phone $addressRaw
                }

                $mmsText.Clear()
                $mmsParts.Clear()
                $mmsAddresses.Clear()
                $senderCandidates.Clear()
            }

            elseif ($reader.Name -eq "part" -and $null -ne $currentMms) {
                $ct = $reader.GetAttribute("ct")
                $text = $reader.GetAttribute("text")

                if ($ct -eq "text/plain" -and $text -and $text -ne "null") {
                    $mmsText.Add($text)
                }
                elseif ($ct -and $ct -ne "application/smil" -and $ct -ne "text/plain") {
                    $name = $reader.GetAttribute("name")
                    if (-not $name -or $name -eq "null") { $name = $reader.GetAttribute("cl") }
                    if (-not $name -or $name -eq "null") { $name = "attachment" }

                    $data = $null
                    if ($ExtractMedia -and ($ct -match '^(image|video|audio)/')) {
                        $data = $reader.GetAttribute("data")
                    }

                    $mmsParts.Add([pscustomobject]@{
                        Mime = $ct
                        Name = $name
                        Data = $data
                    })
                }
            }

            elseif ($reader.Name -eq "addr" -and $null -ne $currentMms) {
                $a = Normalize-Phone ($reader.GetAttribute("address"))
                $type = $reader.GetAttribute("type")

                if ($a -match '^\d{10}$') {
                    $mmsAddresses.Add($a)
                    if ($type -eq "137") { $senderCandidates.Add($a) }
                }
            }
        }

        elseif ($reader.NodeType -eq [System.Xml.XmlNodeType]::EndElement -and
                $reader.Name -eq "mms" -and
                $null -ne $currentMms) {

            $participantSet = @($mmsAddresses | Where-Object { $_ -match '^\d{10}$' } | Sort-Object -Unique)

            if ($currentMms.MainAddress -match '^\d{10}$' -and
                $participantSet -notcontains $currentMms.MainAddress) {

                $participantSet += $currentMms.MainAddress
                $participantSet = @($participantSet | Sort-Object -Unique)
            }

            $isExactMatch =
                ($participantSet.Count -eq $targetPhones.Count) -and
                (@($targetPhones | Where-Object { $participantSet -notcontains $_ }).Count -eq 0)

            if ($isExactMatch) {
                $senderPhone = ""

                if ($currentMms.Direction -eq "sent") {
                    $senderPhone = $ownerPhone
                }
                else {
                    foreach ($candidate in $senderCandidates) {
                        if (($targetPhones -contains $candidate) -and ($candidate -ne $ownerPhone)) {
                            $senderPhone = $candidate
                            break
                        }
                    }

                    if (-not $senderPhone -and
                        ($targetPhones -contains $currentMms.MainAddress) -and
                        ($currentMms.MainAddress -ne $ownerPhone)) {

                        $senderPhone = $currentMms.MainAddress
                    }
                }

                $attachmentResults = [System.Collections.Generic.List[object]]::new()

                foreach ($part in $mmsParts) {
                    $savedRelative = $null
                    $savedName = $part.Name
                    $extracted = $false

                    if ($ExtractMedia -and
                        $part.Data -and
                        ($part.Mime -match '^(image|video|audio)/')) {

                        try {
                            $bytes = [Convert]::FromBase64String($part.Data)
                            $mediaCounter++

                            $ext = [System.IO.Path]::GetExtension($savedName)
                            if ([string]::IsNullOrWhiteSpace($ext)) {
                                $ext = Extension-FromMime $part.Mime
                            }

                            $base = [System.IO.Path]::GetFileNameWithoutExtension($savedName)
                            if ([string]::IsNullOrWhiteSpace($base)) { $base = "attachment" }

                            $fileName = ("{0:D5}_{1}{2}" -f $mediaCounter, (Safe-FileName $base), $ext)
                            $fullPath = Join-Path $MediaFolder $fileName
                            [System.IO.File]::WriteAllBytes($fullPath, $bytes)

                            $savedRelative = ($MediaRelativeFolder + "/" + $fileName).Replace("\","/")
                            $savedName = $fileName
                            $extracted = $true
                        }
                        catch {
                            $extracted = $false
                        }
                    }

                    $attachmentResults.Add([pscustomobject]@{
                        Mime = $part.Mime
                        Name = $savedName
                        RelativePath = $savedRelative
                        Extracted = $extracted
                    })
                }

                $messages.Add([pscustomobject]@{
                    DateMs = $currentMms.DateMs
                    ReadableDate = $currentMms.ReadableDate
                    Direction = $currentMms.Direction
                    SenderPhone = $senderPhone
                    Text = ($mmsText -join "`n")
                    Attachments = @($attachmentResults)
                })
            }

            $currentMms = $null
            $mmsText.Clear()
            $mmsParts.Clear()
            $mmsAddresses.Clear()
            $senderCandidates.Clear()
        }
    }
}
finally {
    $reader.Dispose()
    Write-Progress -Activity "Exporting conversation" -Completed
}

$conversation = @($messages | Sort-Object DateMs)

if ($conversation.Count -eq 0) {
    throw "No messages were found for that exact participant list."
}

$utf8 = [System.Text.UTF8Encoding]::new($false)
$writer = [System.IO.StreamWriter]::new($OutputFile, $false, $utf8)

try {
    $titleText = ($participants | ForEach-Object { $_.Name }) -join ", "
    $title = Html $titleText

    $writer.WriteLine('<!doctype html>')
    $writer.WriteLine('<html lang="en"><head>')
    $writer.WriteLine('<meta charset="utf-8">')
    $writer.WriteLine('<meta name="viewport" content="width=device-width, initial-scale=1">')
    $writer.WriteLine("<title>$title</title>")
    $writer.WriteLine(@'
<style>
:root{color-scheme:light dark;font-family:system-ui,-apple-system,"Segoe UI",sans-serif}
*{box-sizing:border-box}
body{margin:0;background:#f4f4f5;color:#18181b}
main{max-width:900px;margin:auto;padding:28px 18px 64px}
header{margin-bottom:30px}
h1{font-size:1.55rem;margin:0 0 6px}
.meta,.people{color:#71717a;font-size:.85rem}
.people{margin-top:8px}
.day{display:flex;align-items:center;gap:14px;margin:30px 0 18px;color:#71717a;font-size:.82rem;font-weight:600}
.day:before,.day:after{content:"";height:1px;background:#d4d4d8;flex:1}
.row{display:flex;margin:7px 0}
.row.sent{justify-content:flex-end}
.bubble{max-width:min(78%,700px);padding:9px 12px;border-radius:17px;background:#fff;box-shadow:0 1px 2px rgba(0,0,0,.07)}
.sent .bubble{background:#dbeafe}
.sender{font-size:.72rem;font-weight:700;margin-bottom:3px;color:#52525b}
.text{white-space:pre-wrap;overflow-wrap:anywhere;line-height:1.38}
.time{font-size:.68rem;color:#71717a;text-align:right;margin-top:4px}
.media{margin-top:8px}
.media img{display:block;max-width:100%;max-height:640px;border-radius:10px}
.media video,.media audio{display:block;max-width:100%;width:100%;margin-top:6px}
.attachment{margin-top:7px;padding-top:6px;border-top:1px solid rgba(127,127,127,.25);font-size:.75rem;color:#71717a}
.media-link{font-size:.78rem;overflow-wrap:anywhere}
@media (prefers-color-scheme:dark){
 body{background:#18181b;color:#f4f4f5}
 .meta,.people,.day,.time,.attachment{color:#a1a1aa}
 .day:before,.day:after{background:#3f3f46}
 .bubble{background:#27272a}
 .sent .bubble{background:#1e3a5f}
 .sender{color:#d4d4d8}
}
</style>
'@)
    $writer.WriteLine('</head><body><main>')
    $writer.WriteLine("<header><h1>$title</h1>")
    $writer.WriteLine("<div class=`"meta`">$($conversation.Count.ToString('N0')) messages</div>")

    $peopleText = @($participants | ForEach-Object { "$(Html $_.Name): $(Html $_.Phone)" }) -join " &nbsp;•&nbsp; "
    $writer.WriteLine("<div class=`"people`">$peopleText</div></header>")

    $lastDay = ""

    foreach ($msg in $conversation) {
        try {
            $dt = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$msg.DateMs).ToLocalTime()
            $day = $dt.ToString("MMMM d, yyyy")
            $time = $dt.ToString("h:mm tt")
        }
        catch {
            $day = "Unknown date"
            $time = $msg.ReadableDate
        }

        if ($day -ne $lastDay) {
            $writer.WriteLine("<div class=`"day`"><span>$(Html $day)</span></div>")
            $lastDay = $day
        }

        $sender = "Unknown sender"
        if ($msg.SenderPhone -and $nameByPhone.ContainsKey($msg.SenderPhone)) {
            $sender = $nameByPhone[$msg.SenderPhone]
        }
        elseif ($msg.Direction -eq "sent") {
            $sender = $ownerName
        }

        $writer.WriteLine("<div class=`"row $($msg.Direction)`"><div class=`"bubble`">")
        $writer.WriteLine("<div class=`"sender`">$(Html $sender)</div>")

        if (-not [string]::IsNullOrWhiteSpace($msg.Text)) {
            $writer.WriteLine("<div class=`"text`">$(Html $msg.Text)</div>")
        }

        foreach ($att in $msg.Attachments) {
            if ($att.Extracted -and $att.RelativePath) {
                $path = Html $att.RelativePath
                $name = Html $att.Name
                $mime = $att.Mime

                if ($mime -match '^image/') {
                    $writer.WriteLine("<div class=`"media`"><a href=`"$path`"><img src=`"$path`" alt=`"$name`"></a></div>")
                }
                elseif ($mime -match '^video/') {
                    $writer.WriteLine("<div class=`"media`"><video controls preload=`"metadata`" src=`"$path`"></video><div class=`"media-link`"><a href=`"$path`">$name</a></div></div>")
                }
                elseif ($mime -match '^audio/') {
                    $writer.WriteLine("<div class=`"media`"><audio controls preload=`"metadata`" src=`"$path`"></audio><div class=`"media-link`"><a href=`"$path`">$name</a></div></div>")
                }
            }
            else {
                $writer.WriteLine("<div class=`"attachment`">Attachment not embedded in export: $(Html $att.Name) ($(Html $att.Mime))</div>")
            }
        }

        $writer.WriteLine("<div class=`"time`">$(Html $time)</div></div></div>")
    }

    $writer.WriteLine('</main></body></html>')
}
finally {
    $writer.Dispose()
}

Write-Host ""
Write-Host ("Done. Exported {0:N0} messages." -f $conversation.Count)

if ($ExtractMedia) {
    Write-Host ("Extracted {0:N0} media files." -f $mediaCounter)
}

Write-Host "Created:"
Write-Host $OutputFile

if ($ExtractMedia) {
    Write-Host "Media folder:"
    Write-Host $MediaFolder
}

Write-Host ""
$openNow = Read-Host "Open the HTML now? [Y/n]"
if ([string]::IsNullOrWhiteSpace($openNow) -or $openNow.Trim().ToLower() -eq "y") {
    Start-Process $OutputFile
}
