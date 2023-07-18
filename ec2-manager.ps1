#installa moduli necessari

if (Get-Module -ListAvailable -Name PSWriteColor) {
    #Write-Host "Module PSWriteColor exists"
} 
else {
    Write-Host "Module PSWriteColor does not exist"
    Install-Module -Force -Scope CurrentUser PSWriteColor
    Write-Host "Module PSWriteColor installed"
}

if (Get-Module -ListAvailable -Name PsIni) {
    #Write-Host "Module PsIni exists"
} 
else {
    Write-Host "Module PsIni does not exist"
    Install-Module -Force -Scope CurrentUser PsIni
    Write-Host "Module PsIni installed"
}

if (Get-Module -ListAvailable -Name AWSPowerShell) {
    #Write-Host "Module AWSPowerShell exists"
} 
else {
    Write-Host "Module AWSPowerShell does not exist"
    Install-Module -Force -Scope CurrentUser AWSPowerShell
    Write-Host "Module AWSPowerShell installed"
}

#Importo i moduli necessari
Import-Module -Name AWSPowerShell
Import-Module -Name PsIni
Import-Module -Name PSWriteColor

#leggo le informazioni dal file config.ini
$config = Get-IniContent .\config.ini
$version = $config["GLOBAL"]["version"]
$account = $config["DEFAULT"]["account"]
$access_key_id = $config[$account]["AWS_ACCESS_KEY_ID"]
$secret_access_key = $config[$account]["AWS_SECRET_ACCESS_KEY"]
$region =  $config[$account]["AWS_DEFAULT_REGION"]

#carico le informazioni dal file instances.ini
$instances = Get-IniContent .\instances.ini
#$instance_id = $instances[$account]["cameo-dev"]


# Imposta le credenziali come variabili d'ambiente
$env:AWS_ACCESS_KEY_ID = $access_key_id
$env:AWS_SECRET_ACCESS_KEY = $secret_access_key
$env:AWS_DEFAULT_REGION = $region

function instanceList {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account
    )
    Clear-Host
    Write-Output "########################################################################################################################"
    Write-Output "Le istanze censite sono: "
    Write-Output ""
    Write-Output $instances[$account].Keys    
    #$instances[$account].Keys | ForEach-Object { $instances[$account][$_]}
    Write-Output ""
    Write-Output "Se nell'elenco non e' presente l'istanza che stai cercando inserisicla nel file `".\instances.ini`" nel gruppo [$account] "
    Write-Output "########################################################################################################################"
}


function getDefaultAccount {
    Clear-Host
    Write-Output "########################################################################################################################"
    Write-Output "L'account impostato come default e' : "
    Write-Output ""
    Write-Output $config["DEFAULT"]["account"]
    Write-Output ""
    Write-Output "Per modificare l'account di default utilizzare $PSCommandPath setDefaultAccount account_name"
    Write-Output ""
    Write-Output "########################################################################################################################"
}

function setDefaultAccount {
    param(
        [Parameter(Mandatory = $true)]
        [string]$newDefaultAccount
    )
    try {
        
        $config["DEFAULT"]["account"] = $newDefaultAccount
        $config | Out-IniFile -Force -FilePath .\config.ini
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}


function instanceAdd {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account,
        [string]$newInstanceName,
        [string]$newInstanceId
    )
    try {
        
        $instances[$account][$newInstanceName] = $newInstanceId
        $instances | Out-IniFile -Force -FilePath .\instances.ini
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}


function instanceDelete {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account,
        [string]$instanceName
    )
    try {
        
        $instances.$account.Remove($instanceName)
        $instances | Out-IniFile -Force -FilePath .\instances.ini
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}

function getAccounts {
    Clear-Host
    Write-Output "########################################################################################################################"
    Write-Output "Gli account censiti sono: "
    Write-Output ""
    Write-output $config["ACCOUNT_LIST"].Keys
    Write-Output ""
    Write-Output "Se l'account che cerchi non e' presente in lista, contatta l'amministratore"
    Write-Output "########################################################################################################################"
}

function getInstanceID {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account,
        [string]$instanceName
    )
    
    $instances[$account][$instanceName]
}

function info {
    Clear-Host
    Write-Output "########################################################################################################################"
    Write-Output "  ec2-manager e' uno script PowerShell che dovrebbe permettere di gestire"
    Write-Output "  le istanze EC2 su AWS."
    Write-Output ""
    Write-Output "  Per gestire intendo accendere e spegnere, al momento."
    Write-Output "  E credo anche per il futuro..."
    Write-Output ""
    Write-Output "  Realizzato e manutenuto da:"
    Write-Output ""
    Write-Output "     - Fabio Pellizzaro (mail: fabio.pellizzaro@decisyon.com)"
    Write-Output ""
    Write-Output "########################################################################################################################"

}

function help {
    Clear-Host
    Write-Host "  ec2-manager e' uno script PowerShell che dovrebbe permettere di gestire"
    Write-Host "  le istanze EC2 su AWS."
    Write-Host " "
    Write-Host "  Al momento supporta l'avvio e lo spegnimento di una istanza EC2"
    Write-Host "  E credo che anche in futuro, questa cosa non cambierà piu' di tanto."
    Write-Host " "
    Write-Host "  Utilizzo:"
    Write-Host " "
    Write-Host "  - help: " -ForegroundColor Yellow
    Write-Host "    Produce questo help "
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath help " -ForegroundColor DarkGray
    Write-Host " "
    Write-Host "  - Start-EC2: " -ForegroundColor Yellow
    Write-Host "    Avvia un'istanza EC2 su AWS, nell'account impostato come default "
    Write-Host "    L'istanza viene identificata con un nome, passato come parametro. "
    Write-Host "    Il nome dell'stanza e' riportato nel file instances.ini. In questo file "
    Write-Host "    ad ogni nome (definito dall'utente), e' associato un instanceId."
    Write-Host "    Per conoscere le istanze censite, vedere instanceList"
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      nome istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Start-EC2 istanzaTest2023" -ForegroundColor DarkGray
    Write-Host " "
    Write-Host "  - Stop-EC2: " -ForegroundColor Yellow
    Write-Host "    Ferma un'istanza EC2 su AWS, nell'account impostato come default "
    Write-Host "    L'istanza viene identificata con un nome, passato come parametro. "
    Write-Host "    Il nome dell'stanza e' riportato nel file instances.ini. In questo file "
    Write-Host "    ad ogni nome (definito dall'utente), e' associato un instanceId."
    Write-Host "    Per conoscere le istanze censite, vedere instanceList"
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      nome istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Stop-EC2 istanzaTest2023" -ForegroundColor DarkGray
    Write-Host " "
    Write-Host "  - Get-AccountsList: " -ForegroundColor Yellow
    Write-Host "    Restituisce la lista degli account AWS disponibili, tale comando e' utile nel"
    Write-Host "    caso si voglia cambiare account, in questo modo, si e' certi di non andare ad "
    Write-Host "    impostare come default un account inesistente."
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Get-AccountsList" -ForegroundColor DarkGray
    Write-Host " "   
    Write-Host "  - Get-DefaultAccount: " -ForegroundColor Yellow
    Write-Host "    Restituisce l'attuale account impostato come default, dove lo script andra'"
    Write-Host "    ad eseguire tutti i comandi."
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Get-DefaultAccount" -ForegroundColor DarkGray
    Write-Host " " 
    Write-Host "  - Set-DefaultAccount: " -ForegroundColor Yellow
    Write-Host "    Imposta l'account di default, ovvero l'account dove lo script andra'"
    Write-Host "    ad eseguire tutti i comandi."
    Write-Host "    Gli account selezionabili sono quelli che restituisce getAccountList"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Set-DefaultAccount SERVIZI" -ForegroundColor DarkGray
    Write-Host " " 
    Write-Host "  - Get-InstanceList: " -ForegroundColor Yellow
    Write-Host "    Ritorna la lista delle istanze disponibili (censite) nell'account"
    Write-Host "    attualmente impostato come default."
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Get-InstanceList" -ForegroundColor DarkGray
    Write-Host " "
    Write-Host "  - Get-InstanceInfo: " -ForegroundColor Yellow
    Write-Host "    Restituisce alcune informazioni relative ad un'istanza EC2 nell'account impostato come default"
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      nome istanza: nome del'istanza di cui si vogliono le imformazioni"
    Write-Host "    esempio: "  -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Get-InstanceInfo istanzaTest2023" -ForegroundColor DarkGray
    Write-Host " " 
    Write-Host "  - Add-Instance: " -ForegroundColor Yellow
    Write-Host "    Aggiunge un'istanza nell'account attualmente impostato come default."
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      nome istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Host "      id istanza: utilizzato dallo script per gestire le istanze su AWS"    
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Add-Instance istanzaTest2023 id-123434567890 " -ForegroundColor DarkGray
    Write-Host " "  
    Write-Host "  - Delete-Instance: " -ForegroundColor Yellow
    Write-Host "    Rimuove un'istanza nell'account attualmente impostato come default."
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      nome istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Delete-Instance istanzaTest2023" -ForegroundColor DarkGray
    Write-Host " "
    Write-Host "  - Set-AccessKeyId: " -ForegroundColor Yellow
    Write-Host "    Modifica l'AWS_ACCESS_KEY_ID relativo all'account attualmente impostato come default."
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      aws access key id: Stringa univoca che identifica una chiave per un utente AWS abilitato"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Set-AccessKeyId AABBCCDDEEFFGGHH1234" -ForegroundColor DarkGray
    Write-Host " " 
    Write-Host "  - Set-SecretAccessKey: " -ForegroundColor Yellow
    Write-Host "    Modifica l'AWS_SECRET_ACCESS_KEY_ID relativo all'account attualmente impostato come default."
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      aws secret access key: Stringa univoca che valida una chiave di un utente AWS abilitato"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Set-SecretAccessKey qwertyuiop1234567890asdfghjkl1234567890" -ForegroundColor DarkGray
    Write-Host " "
    Write-Host "  - Get-AWSRegionsList: " -ForegroundColor Yellow
    Write-Host "    Restituisce tutte le Regioni AWS disponibili per l'account impostato come default"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Get-AWSRegionsList" -ForegroundColor DarkGray
    Write-Host " "
    Write-Host "  - Set-AWSRegion: " -ForegroundColor Yellow
    Write-Host "    Modifica l'AWS_DEFAULT_REGION relativo all'account attualmente impostato come default."
    Write-Host "    Parametri:" -ForegroundColor Cyan
    Write-Host "      aws region: nome della regione si cui ci si vuole spostare es: eu-west-1"
    Write-Host "    esempio: " -ForegroundColor DarkGray
    Write-Host "    $PSCommandPath Set-AWSRegion eu-west-1" -ForegroundColor DarkGray
    Write-Host " " 
}

# Definisci la funzione per accendere l'istanza EC2
function AccendiIstanzaEC2 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InstanceId
    )
    
    Start-EC2Instance -Region $region -InstanceId $InstanceId
}

# Definisci la funzione per spegnere l'istanza EC2
function SpegniIstanzaEC2 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InstanceId
    )
    
    Stop-EC2Instance -Region $region -InstanceId $InstanceId
}

function getAWSRegions {
    try {
        Get-AWSRegion
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }

}


function setAWSRegion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account,
        [string]$newRegion
    )
    try {
        
        $config[$account]["AWS_DEFAULT_REGION"] = $newRegion
        $config | Out-IniFile -Force -FilePath .\config.ini
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}

function setAWSAccessKeyId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account,
        [string]$newAccessKeyId
    )
    try {
        
        $config[$account]["AWS_ACCESS_KEY_ID"] = $newAccessKeyId
        $config | Out-IniFile -Force -FilePath .\config.ini
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}

function setAWSSecretAccessKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account,
        [string]$newSecretAccessKey
    )
    try {
        
        $config[$account]["AWS_SECRET_ACCESS_KEY"] = $newSecretAccessKey
        $config | Out-IniFile -Force -FilePath .\config.ini
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}

function getInstanceInfo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$account,
        [string]$instanceId
    )
    Write-Output "AWS Account: $account"
    Write-Output "AWS Region: $region"
    try {
        (Get-EC2Instance -Region $region -instanceId $instanceId).Instances
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}

function testAWSConnection {
    try {
        Get-EC2Instance  -Region $region -InstanceId $instanceId
        #Get-AWSRegion
    }
    catch {
        $message = $_
        Write-Warning -Message "Opperbacco! $message"
    }
}

$azione = $args[0]
$parametro = $args[1]
$altroparametro = $args[2]

switch -Wildcard ($azione)
{
    Start-EC2 { 
        Write-Output "$azione"
        $instanceId = getInstanceID -account $account -instanceName $parametro
        Write-Output "AccendiIstanzaEC2 -InstanceId $instanceId"
        AccendiIstanzaEC2 -InstanceId $InstanceId
    }
    Stop-EC2 { 
        Write-Output "$azione"
        $instanceId = getInstanceID -account $account -instanceName $parametro
        Write-Output "SpegniIstanzaEC2 -InstanceId $instanceId"
        SpegniIstanzaEC2 -InstanceId $InstanceId
    }
    Get-AccountsList { 
        Write-Output "$azione"
        getAccounts; 
        Break 
    }
    Get-DefaultAccount { 
        Write-Output "$azione"
        getDefaultAccount; 
        Break
    }
    Set-DefaultAccount { 
        Write-Output "$azione"
        Write-Output $parametro
        setDefaultAccount -newDefaultAccount $parametro
        Break
    }
    Get-InstanceList { 
        Write-Output "$azione"
        instanceList -account $account
    }
    Add-instance { 
        Write-Output "$azione"
        Write-Output "$parametro"
        Write-Output "$altroparametro"
        instanceAdd -account $account -newInstanceName $parametro -newInstanceId $altroparametro

    }
    Delete-instance { 
        Write-Output "$azione"
        Write-Output "$parametro"
        Write-Output "$altroparametro"
        instanceDelete -account $account -instanceName $parametro
    }
    Get-InstanceInfo{ 
        Write-Output "$azione"
        Write-Output "$parametro"
        $instanceId = getInstanceID -account $account -instanceName $parametro
        Write-Output "$instanceId"
        getInstanceInfo -account $account -instanceId $instanceId
    }
    Get-AWSRegionsList{ 
        Write-Output "$azione" 
        getAWSRegions
        Break
    }
    Set-AWSRegion{ 
        Write-Output "$azione" 
        setAWSRegion -account $account -newRegion $parametro
        Break
    } 
    Set-AWSAccessKeyId{ 
        Write-Output "$azione" 
        setAWSAccessKeyId -account $account -newAccessKeyId $parametro
        Break
    } 
    Set-AWSSecretAccessKey{ 
        Write-Output "$azione" 
        setAWSSecretAccessKey -account $account -newSecretAccessKey $parametro
        Break
    }    
    help { 
        Write-Output "$azione"
        help 
    }
    info { 
        Write-Output "$azione"
        info
    }
    test { 
        Write-Output "$azione" -ForegroundColor Yellow
        testAWSConnection
    }
    Default {
        Write-Output ""
        Write-Output "Please give me some info about what the hell you want to do"
        Write-Output ""
        Write-Output "if you need help, please run $PSCommandPath help"
        Write-Output ""        
    }
}