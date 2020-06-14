Param(
    [switch]$Domain
)

function Audit-SexySix {
    $Auditpol = 'C:\Windows\System32\auditpol.exe'
    if ($Auditpol) {
        $Events = '/subcategory:"Process Creation","File Share","File System","Registry","Filtering Platform Connection"'

        $Settings = '/set', $Events, '/success:enable'
        Start-Process -FilePath $Auditpol -ArgumentList $Settings -NoNewWindow

        $Settings = '/set', '/subcategory:"Logon"', '/success:disable', '/failure:disable'
        Start-Process -FilePath $Auditpol -ArgumentList $Settings -NoNewWindow
    }
}

function Audit-CliUsage {
    $Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit'
    $ValueName = 'ProcessCreationIncludeCmdLine_Enabled'
    $Value = 1
    $Type = 'Dword'

    if (-not (Test-Path $Key)) {
        New-Item –Path $Key –Name $ValueName
        New-ItemProperty -Path $Key -Name $ValueName -Value $Value  -PropertyType $Type
    }
}

<# CONTINUE HERE

# 

<?xml version="1.0" encoding="UTF-8"?>
<Subscription xmlns="http://schemas.microsoft.com/2006/03/windows/events/subscription">
        <SubscriptionId>SexySix</SubscriptionId>
        <SubscriptionType>SourceInitiated</SubscriptionType>
        <Description></Description>
        <Enabled>true</Enabled>
        <Uri>http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog</Uri>
        <ConfigurationMode>Normal</ConfigurationMode>
        <Delivery Mode="Push">
                <Batching>
                        <MaxLatencyTime>900000</MaxLatencyTime>
                </Batching>
                <PushSettings>
                        <Heartbeat Interval="900000"/>
                </PushSettings>
        </Delivery>
        <Query>
                <![CDATA[
<QueryList><Query Id="0"><Select Path="Application">*[System[(EventID=4688 or EventID=4624 or EventID=5140 or EventID=4663 or EventID=4657 or EventID=5156)]]</Select><Select Path="Security">*[System[(EventID=4688 or EventID=4624 or EventID=5140 or EventID=4663 or EventID=4657 or EventID=5156)]]</Select><Select Path="Setup">*[System[(EventID=4688 or EventID=4624 or EventID=5140 or EventID=4663 or EventID=4657 or EventID=5156)]]</Select><Select Path="System">*[System[(EventID=4688 or EventID=4624 or EventID=5140 or EventID=4663 or EventID=4657 or EventID=5156)]]</Select><Select Path="Microsoft-Windows-PowerShell/Operational">*[System[(EventID=4688 or EventID=4624 or EventID=5140 or EventID=4663 or EventID=4657 or EventID=5156)]]</Select></Query></QueryList>
                ]]>
        </Query>
        <ReadExistingEvents>false</ReadExistingEvents>
        <TransportName>HTTP</TransportName>
        <ContentFormat>RenderedText</ContentFormat>
        <Locale Language="en-US"/>
        <LogFile>ForwardedEvents</LogFile>
        <PublisherName>Microsoft-Windows-EventCollector</PublisherName>
        <AllowedSourceNonDomainComputers>
                <AllowedIssuerCAList>
                </AllowedIssuerCAList>
        </AllowedSourceNonDomainComputers>
        <AllowedSourceDomainComputers>O:NSG:BAD:P(A;;GA;;;DC)S:</AllowedSourceDomainComputers>
</Subscription>
#>

if ($Domain) {
    # domain stuff
} else {
    Audit-SexySix
    Audit-CliUsage
}
