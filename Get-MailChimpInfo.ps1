<#
.Synopsis
    Sends a REST API request to MailChimp in order to gather info about subscribers.

.Parameter ApiKey
    MailChimp API key required for account authentication.

.Parameter ListId
    The specific list that will be targeted under the specified API key.

.Parameter Username
    The username under the specified API key.

.Parameter Url
    The URL that the request will be sent to.

.Parameter Email
    Later.

.Example
    Get-MailChimpInfo -ListId w55019df81

    Gets subscriber information from a specific MailChimp list.
#>

Param(
    [string]$ApiKey = '7cae54cf6b9ce900c74ef19c2498d6dd-us17',
    [string]$ListId = '337eb7d0e3',
    [string]$Username = 'SuckerPunched',
    [string]$Url = 'https://us17.api.mailchimp.com/3.0/',
    [string]$Email
)

$StandardAuthorization = @{Authorization = 'Basic' + [Convert]::ToBase64String([Text.Endcoding]::ASCII.GetBytes("${Username}:${ApiKey}"))}

function Get-SingleSubscriberInfo([string]$email)
{
    $result = Invoke-RestMethod -Method Get -Uri "$Url/lists/$ListId/members/$email" -Authorization $StandardAuthorization

    if(-not ([string]::IsNullOrEmpty($result.Status)))
    {
        Write-Output "Subscriber $email exists in the list."
    }
    else
    {
        Write-Output "Subscriber $email does not exist in the list."
    }
}

function Get-AllSubscribers()
{
    # Placeholder for future functionality
}

Get-SingleSubscriberInfo('sample.email@gmail.com')