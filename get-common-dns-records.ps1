<#
FILE: get_dns_records.ps1
AUTHOR: Al Zuniga
PURPOSE: Retrieve common DNS records for a domain.
USAGE: Enter the root domain [domain_name.tld] and press enter. The script
       retrieve common DNS records.
VERSIONS: 0.1
TODO: - Update A record search to search for common subdomains
      - Input validation
      - Retrieve DMARC record
      - Display SPF on its own
      - Retrieve common DKIM keys
#>


# Start script with clear terminal
Clear-Host


# CNAME and SRV subdomains
$cname_subdomains = @(
    'autodiscover','blog','email','enterpriseregistration',
    'exchange','enterpriseenrollment','ftp','imap','intranet',
    'lyncdiscover','m','mail','pop','pop3','sip','smtp','vpn',
    'webmail','www'
)

$srv_subdomains = @('_sip._tls','_sipfederationtls._tcp')


# Script Title
Write-Host "$("*" * 80)"
Write-Host "**$(" "*30) GET DNS RECORDS $(" "*29)**"
Write-Host "$("*" * 80)`r`n"


# Get Root Domain
Write-Host "Root Domain [EX: domain_name.tld]: " -ForegroundColor Green -NoNewline
$domain = Read-Host


# A Records
Write-Host "`r`n`r`n$("-" * 34)[ A RECORDS ]$("-" * 33)"  -ForegroundColor Yellow
Resolve-DnsName -Name "$domain" -Type A -DnsOnly -ErrorAction Ignore | Where-Object {$_.Type -ne "SOA"}


# CNAME Records
Write-Host "`r`n$("-" * 32)[ CNAME RECORDS ]$("-" * 31)"  -ForegroundColor Yellow

$cname_subdomains | ForEach-Object {
    Resolve-DnsName -Name "$_.$($domain)" -Type CNAME -DnsOnly -ErrorAction Ignore | Where-Object {$_.Type -ne "SOA"} | Format-Table
}


# MX Records
Write-Host "`r`n$("-" * 33)[ MX RECORDS ]$("-" * 33)"  -ForegroundColor Yellow
Resolve-DnsName -Name "$domain" -Type MX -DnsOnly -ErrorAction Ignore | Where-Object {$_.Type -ne "SOA" -and $_.Section -ne "Additional"} | Format-Table


# NS Records
Write-Host "`r`n$("-" * 33)[ NS RECORDS ]$("-" * 33)"  -ForegroundColor Yellow
Resolve-DnsName -Name "$domain" -Type NS -DnsOnly -ErrorAction Ignore | Where-Object {$_.Type -ne "SOA" -and $_.Section -ne "Additional"} | Format-Table


# SRV Records
Write-Host "`r`n$("-" * 32)[ SRV RECORDS ]$("-" * 32)"  -ForegroundColor Yellow

$srv_subdomains | ForEach-Object {
    Resolve-DnsName -Name "$_.$($domain)" -Type SRV -DnsOnly -ErrorAction Ignore | Where-Object {$_.Type -ne "SOA"} | Format-Table
}


# TXT Records
Write-Host "`r`n$("-" * 33)[ TXT RECORDS ]$("-" * 32)"  -ForegroundColor Yellow
Resolve-DnsName -Name "$domain" -Type TXT -DnsOnly -ErrorAction Ignore | Where-Object {$_.Type -ne "SOA"}
