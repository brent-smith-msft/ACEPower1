function exportMe($tmpItems) {
    
    try {
        $output = Read-Host “Enter a location for the output file (For Example: c:\logs\)”

        #validate path is good#
        if((Test-Path -Path $output) -eq $false)
        {
                Write-Host "Path cannot be found, please re-run script and choose a valid path"
                return 2    
        }

        $filename = Read-Host “Enter a filename”
        $name = $output + “\” + $filename + “.csv”
        $tmpItems | Export-Csv $name -NoTypeInformation
        Write-Host “Your information was exported to CSV” -ForegroundColor Green
        Write-Host “Log File Created: ” $name
        return 1
    }

    catch {
        Write-Host "unhandled error occurred"
        Write-Host $_.Exception
        return 2
    }
}


function getItems($tmpList) {
    $items = get-pnplistitem -list $tmpList

    #loop thru items and print out the values
    $ctr = 1
    
    foreach ($item in $items) {
        Write-Host "I'm in $ctr iteration of the loop"
        write-host $item.FieldValues["Model", "Mileage", "Color", "Sold"]
        $ctr++
    }

    #print it out in one command
    if ($items)
    {
            $prefItems = $items.fieldvalues | select-object {$_."Title", $_."Model", $_."Color", $_."Sold"}
            #export results
            $res = exportMe($prefItems)            

            if ($res -eq 1)
            {Write-Host "Operation Complete, good job"}

            elseif($res -eq  2)
            {Write-Host "Something bad happened, so sorry"}
    }
}


function getList {
    $myList = get-pnplist | where-object {$_.Title -eq "data"}
    
    if ($myList.GetType().Name -eq "List")
    {
        #fetch items
        getItems($myList)
    }
}


#program starts here
try {
    connect-PnPOnline -Url "microsoft.sharepoint-df.com/teams/PowerACE" -useweblogin

    #call get list function 
    getList
}  


catch {
    Write-Host "unhandled error occurred"
    Write-Host $_.Exception
}
