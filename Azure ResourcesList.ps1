connect-azAccount
$date = Get-Date -UFormat("%m-%d-%y")
$currentDir = $(Get-Location).Path
$oFile = "$($currentDir)\List_Of_All_Azure_Resources_$($date).csv"
 
if(Test-Path $oFile){
    Remove-Item $oFile -Force
}
 
"SUBSCRIPTION_NAME,SUBSCRIPTION_ID, RESOURCE_GROUP_NAME,RESOURCE_NAME,RESOURCE_TYPE,TAGS" | Out-File $oFile -Append -Encoding ascii
 
Get-AzSubscription | ForEach-Object{
    $subscriptionId = $_.Id
    $subscriptionName = $_.Name
     
    Set-AzContext -SubscriptionId $subscriptionId
    Get-AzResourceGroup | ForEach-Object{
        $resourceGroupName = $_.ResourceGroupName
        Get-AzResource -ResourceGroupName $resourceGroupName | ForEach-Object{
            $resourceName = $_.Name
              
            $resourceType = $_.ResourceType
             
            if(!([string]::IsNullOrEmpty($_.Tags))){
                $tags = @()
                $_.Tags.GetEnumerator() | ForEach-Object {
                    [string]$tags += $_.key+ "=" + $_.value+ ";"
                }
            }
            else{
                $tags = ""
            }
             
            "$subscriptionName,$subscriptionId,$resourceGroupName,$resourceName,$resourceType,$tags" | Out-File $oFile -Append -Encoding ascii
        }
    }
}