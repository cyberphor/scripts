
"https://ifunny.co",
"https://ifunny.co/page2",
"https://ifunny.co/page3",
"https://ifunny.co/page4",
"https://ifunny.co/page5" |
ForEach-Object {
    $Page = $_
    (Invoke-WebRequest -Uri $Page -UseBasicParsing).Links.Href | 
    Select-String -Pattern "ifunny.co/picture" |
    ForEach-Object {
        $MemeURL = $_.ToString()
        (Invoke-WebRequest -Uri $MemeURL).Images |
        Select-Object -ExpandProperty src |
        Select-String -Pattern "img.ifunny.co" |
        ForEach-Object {
            $Meme = $_.ToString()
            Start-BitsTransfer -Source $Meme -Destination $PWD
        }
    }
}