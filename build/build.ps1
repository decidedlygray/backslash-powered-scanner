
# CONFIGURATION
# If burp is installed somewhere else, you'll have to adjust this
$BurpProLocation = "C:\Program Files\BurpSuitePro\burpsuite_pro.jar"
# END CONFIGURATION

Write-Output "[+] (Unofficial) Build script for backslash-powered-scanner Burp Extension"
# Download commons-lang dependency
Write-Output "[+] Downloading Apache commons-lang dependency"
Invoke-WebRequest -Uri http://apache.osuosl.org//commons/lang/binaries/commons-lang3-3.5-bin.zip -OutFile $PSScriptRoot\commons-lang3-3.5-bin.zip

# Decompress commons-lang
Add-Type -assembly “system.io.compression.filesystem”
$CommonsZip = @($PSScriptRoot, "\commons-lang3-3.5-bin.zip")
$CommonsExtractLocation = $PSScriptRoot + "\commons-lang3-3.5\"
if (-not (Test-Path @($CommonsExtractLocation))) {
    [io.compression.zipfile]::ExtractToDirectory($CommonsZip, $PSScriptRoot)
} else {
    Write-Output "[+] WARNING: Commons-lang extract directory already exists, skipping decompression"
}

# Make a landing spot for the build
$LocationToJar = $PSScriptRoot + "\built_classes"
#Write-Output $LocationToJar
if (-not (Test-Path $LocationToJar)) {
    Write-Output "[+] Creating JAR directory build\built_classes\"
    New-Item -ItemType directory -Path $LocationToJar | Out-Null
} else {
    Write-Output "[+] WARNING: JAR build location already exists, skipping mkdir"
}

# Compile source
$JavacClasspath = "`"" + $BurpProLocation + ";" + $CommonsExtractLocation + 'commons-lang3-3.5.jar' + "`""
Write-Output $("[+] Using Javac CLASSPATH: " + $JavacClasspath)
$JavacToCompile = Split-Path -Path $PSScriptRoot -Parent
$JavacToCompile = $JavacToCompile + "\*.java"
Write-Output $("[+] Running Javac on: " + $JavacToCompile)
Write-Output "[+] Executing javac, you'll probably see a warning about deprecated API in use:"
& javac -classpath $JavacClasspath -d $LocationToJar $JavacToCompile

# Jar up the results
Write-Output "[+] Compile complete. Building JAR"
$FunctionsLocation = Split-Path -Path $PSScriptRoot -Parent
$FunctionsLocation = $FunctionsLocation + "\functions"
Copy-Item -Path $FunctionsLocation -Destination $LocationToJar

$FinalJARLocation = $PSScriptRoot + "\backslash_powered_scanner_localmod.jar"
& jar cvf $FinalJARLocation -C $LocationToJar .

if (Test-Path $FinalJARLocation) {
    # Print completion message and final steps to take
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Write-Output "JAR build complete! TWO FINAL THINGS! In order to satisfy the current"
    Write-Output "commons-lang dependency, add the folder where commons-lang3-3.5.jar"
    Write-Output "is saved to in Burps Java Environment extender option"
    Write-Output "-Instructions to add commons-lang location:"
    Write-Output " 1. Open Burp Pro, go to Extender tab, then Options sub tab"
    Write-Output " 2. Under the Java Environment header click `"Select folder`""
    Write-Output $(" 3. Select this folder: " + $CommonsExtractLocation)
    Write-Output "-Instructions to load JAR to Burp:"
    Write-Output " 1. Open Burp Pro, go to the Extender tab, then Extensions sub tab"
    Write-Output " 2. Click the Add button"
    Write-Output " 3. Make sure Extension type is set to Java"
    Write-Output "    then select the JAR that was just built. It is located here:"
    Write-Output $($PSScriptRoot + "\backslash_powered_scanner_localmod.jar")
    Write-Output " 4. Leave the rest of the defaults as-is, and click Next to close the window"
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}
else
{
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Write-Output "Not seeing the final JAR :( something must have gone wrong. Look above for"
    Write-Output "errors. Unfortunately this script is currently unsupported, so Google is your friend"
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}