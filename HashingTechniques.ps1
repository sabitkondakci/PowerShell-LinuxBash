$file = 'C:\Users\fenko\Desktop\Signal.lnk'

Set-Content C:\Users\fenko\Desktop\MichaelHeberling.txt -Value "HASHING TECHNIQUES`nHashedFile:$file"

"-----------------SHA1---------------"
$Hash = (Get-FileHash $file -Algorithm SHA1).Hash
$Alg = (Get-FileHash $file -Algorithm SHA1).Algorithm
$Len = $Hash.Length
$print = "`nHash:$Hash`nLenght:$Len`nAlgorithm:$Alg"

Add-Content -Path C:\Users\fenko\Desktop\MichaelHeberling.txt -Value $print

"`n-----------------SHA256---------------"

$Hash = (Get-FileHash $file -Algorithm SHA256).Hash
$Alg = (Get-FileHash $file -Algorithm SHA256).Algorithm
$Len = $Hash.Length
$print = "`nHash:$Hash`nLenght:$Len`nAlgorithm:$Alg"

Add-Content -Path C:\Users\fenko\Desktop\MichaelHeberling.txt -Value $print

"`n-----------------SHA384---------------"

$Hash = (Get-FileHash $file -Algorithm SHA384).Hash
$Alg = (Get-FileHash $file -Algorithm SHA384).Algorithm
$Len = $Hash.Length
$print = "`nHash:$Hash`nLenght:$Len`nAlgorithm:$Alg"

Add-Content -Path C:\Users\fenko\Desktop\MichaelHeberling.txt -Value $print


"`n-----------------SHA512---------------"

$Hash = (Get-FileHash $file -Algorithm SHA512).Hash
$Alg = (Get-FileHash $file -Algorithm SHA512).Algorithm
$Len = $Hash.Length
$print = "`nHash:$Hash`nLenght:$Len`nAlgorithm:$Alg"

Add-Content -Path C:\Users\fenko\Desktop\MichaelHeberling.txt -Value $print

"`n-----------------MD5---------------"

$Hash = (Get-FileHash $file -Algorithm MD5).Hash
$Alg = (Get-FileHash $file -Algorithm MD5).Algorithm
$Len = $Hash.Length
$print = "`nHash:$Hash`nLenght:$Len`nAlgorithm:$Alg"

Add-Content -Path C:\Users\fenko\Desktop\MichaelHeberling.txt -Value $print

"`n-----------------MACTripleDES---------------"

$Hash = (Get-FileHash $file -Algorithm MACTripleDES).Hash
$Alg = (Get-FileHash $file -Algorithm MACTripleDES).Algorithm
$Len = $Hash.Length
$print = "`nHash:$Hash`nLenght:$Len`nAlgorithm:$Alg"

Add-Content -Path C:\Users\fenko\Desktop\MichaelHeberling.txt -Value $print


"`n-----------------RIPEMD160---------------"

$Hash = (Get-FileHash $file -Algorithm RIPEMD160).Hash
$Alg = (Get-FileHash $file -Algorithm RIPEMD160).Algorithm
$Len = $Hash.Length
$print = "`nHash:$Hash`nLenght:$Len`nAlgorithm:$Alg"

Add-Content -Path C:\Users\fenko\Desktop\MichaelHeberling.txt -Value $print
