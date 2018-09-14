param (
	[string]$SourceDir = "",
	[string]$DestinationDir = ""
)
# Specify source and destination directories if not passed via parameter
if ($SourceDir -eq "") { $SourceDir = read-Host "Enter source directory" }
if ($DestinationDir -eq "") { $DestinationDir = read-Host "Enter destination directory" }
# Trim trailing \ if present
$SourceDir = $SourceDir.TrimEnd('\')
$DestinationDir = $DestinationDir.TrimEnd('\')
# make sure directories are there
if (!(test-path -path $SourceDir)) {
	write-Host -backgroundcolor Red "Source path incorrect!"
	exit
}
if (!(test-path -path $DestinationDir)) {
	write-Host -backgroundcolor Red "Destination path incorrect!"
	exit
}
# Pull a list of all folders in the source directory and recurse through them
$FolderList = get-childitem -path $SourceDir -recurse | where-object {$_.Psiscontainer}
foreach ($Folder in $FolderList) {
	# Set the full source and destination path
	$FolderSourcePath = $Folder.FullName
	$FolderDestPath = $DestinationDir + $Folder.FullName.Replace($SourceDir, "")
	write-Host -foregroundcolor Yellow $FolderSourcePath
	# verify destination exists for each folder
	if (!(test-path -path $FolderDestPath)) {
		write-Host -backgroundcolor Red "Path not found in destination"
	} else {
		#if the path is there, grab the ACL from the source folder and apply to the destination folder
		write-Host -foregroundcolor Green $FolderDestPath
		try {
			$ACL = get-Acl -path $FolderSourcePath -ErrorAction stop
		} catch {
			write-Host -backgroundcolor Red "Couldn't read ACL on source."
			write-Host -backgroundcolor Red $_.Exception.Message
			# skip to next item in loop so we don't try to write corrupted data to destination ACL
			continue
		}
		try {
			set-Acl -path $FolderDestPath -AclObject $ACL -ErrorAction stop
		} catch {
			write-Host -backgroundcolor Red "Couldn't write ACL to destination."
			write-Host -backgroundcolor Red $_.Exception.Message
		}
	}
}