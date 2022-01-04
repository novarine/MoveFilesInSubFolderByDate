# Get the files in this folder which should be moved. Without sub folders!
$sourcePath = 'E:\nova\OneDrive\FamNova'
# Target Folder where files should be sorted. The script will automatically create a folder for the year and month.
$targetPath = 'E:\nova\OneDrive\FamNovaSorted'
$fileexists = 0
$files = Get-ChildItem $sourcePath | where {!$_.PsIsContainer}

Write-Host "" $files.Count "Items`r`n" -ForegroundColor Green

# List Files which will be moved
#$files
 


foreach ($file in $files)
{
    # Get year and Month of the file
    # I used LastWriteTime since this are synced files and the creation day will be the date when it was synced
    $year = $file.LastWriteTime.Year.ToString()
    $month = $file.LastWriteTime.Month.ToString()
 
    # Out FileName, year and month
    #$file.Name
    #$year
    #$month
 
    # Set Directory Path
    $Directory = $targetPath + "\" + $year + "\" + $month
    # Create directory if it doesn't exsist
    if (!(Test-Path $Directory))
    {
        New-Item $directory -type directory
        
    }

    $fileexistsOnTargetPath = $Directory + "\" + $file
    If (Test-Path -Path $fileexistsOnTargetPath )
    {
        write-host ("File exist already :" + $fileexistsOnTargetPath) -ForegroundColor Red
        $fileexists = $fileexists +1
        $fileA = $sourcePath + "\" + $file
        $fileB = $fileexistsOnTargetPath
        #$fileC = "C:\fso\changedMyFile.txt"
        
        if((Get-FileHash $fileA).hash -ne (Get-FileHash $fileB).hash)
        #if(Compare-Object -ReferenceObject $(Get-Content $fileA) -DifferenceObject $(Get-Content $fileB))
        {
            Write-Host "But the files are different. Rename the file in source and move it again. Filename: $file" -ForegroundColor Red
            If (Test-Path $fileA)
            {
                # add predix to file
                Rename-Item -Path "$fileA" -NewName "Prefix_$file"
                # Move File to new location
                $error.Clear(); Try {$sourcePath + "\" + "Prefix_$file" | Move-Item -Destination $Directory } Catch {}
                Write-Host "file moved!" -ForegroundColor Green
            }            
        }
        Else 
        {
            Write-Host "The files are the same. It´s already moved and can be removed from source. Filename: $file" -ForegroundColor Green
            If (Test-Path $fileA)
            {
                Remove-Item $fileA
                Write-Host "The file removed from source. Filename: $file" -ForegroundColor White
            }    
        }

    }
    else
    {
        write-host ("File does not exist on target path :" + $fileexistsOnTargetPath) -ForegroundColor Green
        
        # Move File to new location
        $error.Clear(); Try {$file | Move-Item -Destination $Directory } Catch {}
        
        Write-Host "file moved!" -ForegroundColor Green
    }  
}


write-host ("Count of files found in this run which exist already on target :" + $fileexists) -ForegroundColor Yellow