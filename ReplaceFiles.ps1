#Requires -RunAsAdministrator
$host.ui.RawUI.WindowTitle = "Roblox File Replacer By CollinScripter"
$folder = "$env:TEMP\Roblox\sounds"
$filter = 'RBX*'
$ver = 4

#MD5 Hash of Flee Music, Replacing Music Path, Empty String
$replace = @(
	("9FE7860948395890F9BC6F664F7B29B5", "DontThink.mp3", ""), #Lobby
	("68FEBD3162DF6FDEF35D035EBCB4F18A", "DontThink.mp3", ""), #Halloween Lobby
	("E9D4CDA4ADC7F3506D1CF8F09B9B1C79", "UhOhStinky.mp3", ""), #Heartbeat
	("240207ACB12307E3DEB5B2E1E6F05130", "Megalovania.mp3", "") #Beast Lobby
)

Write-Host "Roblox File Replacer v$ver" -fore Blue
Write-Host "By CollinScripter" -fore Blue
Write-Host "Discord: Collin#5932" -fore Blue
Write-Host "Press Esc to quit" -fore Blue
Write-Host "Press Enter to scan" -fore Blue

$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'LastWrite'}

Register-ObjectEvent $fsw Changed -SourceIdentifier SoundChanged -Action {
	$name = $Event.SourceEventArgs.Name
	$hash = (Get-FileHash -Path "$env:TEMP\Roblox\sounds\$name" -Algorithm MD5).Hash 
	if (!($replace -like @("*", "*", $hash))) { #Exclude our modifications
		Write-Host "Sound: '$name' was changed. Hash: $hash" -fore Yellow
		Scan-File -name $name -hash $hash
	}
} | Out-Null

function Kill-Roblox {
	if ((Get-Process -ea SilentlyContinue "RobloxPlayerBeta").count -gt 1) {
		Write-Host "Killing old ROBLOX processes" -fore DarkYellow
		Get-Process "RobloxPlayerBeta" |
		Sort-Object StartTime -Descending |
		Select-Object -Skip 1 |
		Stop-Process
	}
}
function Scan-File {
	param($name, $hash)
	
	Kill-Roblox
	
	if ($replace -like @($hash, "*", "*")) {
		$song = ($replace -like @($hash, "*", "*")).split(" ")[1]
		Write-Host "Copying $song over $name..." -fore Green -NoNewLine
		#Start-Sleep -s 1 #Uncomment if ROBLOX often crashes. Idk if it helps or not
		$code = {
			param($name, $song, $hash)
			$out = .\handle64.exe -accepteula -p RobloxPlayerBeta "$env:TEMP\Roblox\sounds"
			if ($out[5] -ne "No matching handles found.") {
				for ($i = 5; $i -le $out.length - 2; $i += 2) {
					if ((($out[$i] -split ":")[4].split("\"))[(($out[$i] -split ":")[4].split("\")).length - 1] -eq $name) {
						$handle = (($out[$i] -split ":")[2].split(" "))[(($out[$i] -split ":")[2].split(" ")).length - 1]
						.\handle64 -accepteula -c $handle -y -p (Get-Process RobloxPlayerBeta).Id  | Out-Null
					}
				}
			}
			Copy-Item "$song" "$env:TEMP\Roblox\sounds\$name" | Out-Null 
			while ((Get-FileHash -Path "$env:TEMP\Roblox\sounds\$name" -Algorithm MD5).Hash -eq $hash) {}
			Write-Host "Success" -fore Green
		}
		$attempt = Start-Job -Init ([ScriptBlock]::Create("Set-Location '$pwd'")) -ScriptBlock $code -ArgumentList $name, $song, $hash
		for ($i = 0; $i -le 4; $i++) {
			if (Wait-Job $attempt -Timeout 5) {Receive-Job $attempt}
			if ($attempt.State -eq "Running") {
				Write-Host "Failed. Retrying..." -NoNewLine -fore DarkYellow
				if ($i -ge 4) {Write-Host "Gave up..." -fore Red}
			} else {
				$i = 5;
			}
		}
		Remove-Job -force $attempt
	}
}

$replace | ForEach-Object -Process {
	$_[2] = (Get-FileHash -Path $_[1] -Algorithm MD5).Hash
}

Write-Host "-------------------------" -fore Blue

if ((Get-ChildItem $folder -Filter "RBX*") -and !((Get-Process RobloxPlayerBeta)) 2>$null) {
	Remove-Item "$folder\*" -Filter "RBX*" | Out-Null
	Write-Host "Old Sounds Deleted" -fore DarkYellow
}

$running = $true

Kill-Roblox

if ((Get-Process -ea SilentlyContinue "RobloxPlayerBeta").count -ge 1) {
	Write-Host "ROBLOX open, scanning files..." -fore DarkYellow
	Get-ChildItem $folder -Filter "RBX*" |  ForEach-Object -Process {
		$name = $_
		$hash = (Get-FileHash -Path "$env:TEMP\Roblox\sounds\$name" -Algorithm MD5).Hash 
		Write-Host "Sound: '$name' was scanned. Hash: $hash" -fore Yellow
		Scan-File -name $name -hash $hash
	}
}

try {
	do {
		Wait-Event -Timeout 1

		while ($host.UI.RawUI.KeyAvailable) {
			$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
			if ($key.Character -eq 27) {
				$running = $false
			}
			if ($key.Character -eq 13) {
				Get-ChildItem $folder -Filter "RBX*" |  ForEach-Object -Process {
					$name = $_
					$hash = (Get-FileHash -Path "$env:TEMP\Roblox\sounds\$name" -Algorithm MD5).Hash 
					Write-Host "Sound: '$name' was scanned. Hash: $hash" -fore Yellow
					Scan-File -name $name -hash $hash
				}
			}
		}
	} while ($running)
} finally {
	Unregister-Event SoundChanged
}
