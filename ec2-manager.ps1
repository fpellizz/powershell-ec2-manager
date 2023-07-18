#installa moduli necessari
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
    Write-Output "########################################################################################################################"
    Write-Output "  ec2-manager e' uno script PowerShell che dovrebbe permettere di gestire"
    Write-Output "  le istanze EC2 su AWS."
    Write-Output ""
    Write-Output "  Al momento supporta l'avvio e lo spegnimento di una istanza EC2"
    Write-Output "  E credo che anche in futuro, questa cosa non cambierà piu' di tanto."
    Write-Output ""
    Write-Output "  Utilizzo:"
    Write-Output ""
    Write-Output "  - help: "
    Write-Output "    Produce questo help "
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath help "
    Write-Output ""
    Write-Output "  - startEC2: "
    Write-Output "    Avvia un'istanza EC2 su AWS, nell'account impostato come default "
    Write-Output "    L'istanza viene identificata con un nome, passato come parametro. "
    Write-Output "    Il nome dell'stanza e' riportato nel file instances.ini. In questo file "
    Write-Output "    ad ogni nome (definito dall'utente), e' associato un instanceId."
    Write-Output "    Per conoscere le istanze censite, vedere instanceList"
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      nome_istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath startEC2 istanzaTest2023"
    Write-Output ""
    Write-Output "  - stopEC2: "
    Write-Output "    Ferma un'istanza EC2 su AWS, nell'account impostato come default "
    Write-Output "    L'istanza viene identificata con un nome, passato come parametro. "
    Write-Output "    Il nome dell'stanza e' riportato nel file instances.ini. In questo file "
    Write-Output "    ad ogni nome (definito dall'utente), e' associato un instanceId."
    Write-Output "    Per conoscere le istanze censite, vedere instanceList"
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      nome_istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath stopEC2 istanzaTest2023"
    Write-Output ""
    Write-Output "  - getAccountList: "
    Write-Output "    Restituisce la lista degli account AWS disponibili, tale comando e' utile nel"
    Write-Output "    caso si voglia cambiare account, in questo modo, si e' certi di non andare ad "
    Write-Output "    impostare come default un account inesistente."
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath getAccountList"
    Write-Output ""   
    Write-Output "  - getDefaultAccount: "
    Write-Output "    Restituisce l'attuale account impostato come default, dove lo script andra'"
    Write-Output "    ad eseguire tutti i comandi."
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath getDefaultAccount"
    Write-Output "" 
    Write-Output "  - setDefaultAccount: "
    Write-Output "    Imposta l'account di default, ovvero l'account dove lo script andra'"
    Write-Output "    ad eseguire tutti i comandi."
    Write-Output "    Gli account selezionabili sono quelli che restituisce getAccountList"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath setDefaultAccount SERVIZI"
    Write-Output "" 
    Write-Output "  - instanceList: "
    Write-Output "    Ritorna la lista delle istanze disponibili (censite) nell'account"
    Write-Output "    attualmente impostato come default."
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath instanceList"
    Write-Output ""
    Write-Output "  - instanceAdd: "
    Write-Output "    Aggiunge un'istanza nell'account attualmente impostato come default."
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      nome_istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Output "      id_istanza: utilizzato dallo script per gestire le istanze su AWS"    
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath instanceAdd istanza-da-aggiungere id-123434567890 "
    Write-Output ""  
    Write-Output "  - instanceDelete: "
    Write-Output "    Rimuove un'istanza nell'account attualmente impostato come default."
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      nome_istanza: univoco che identifica l'istanza nel file instances.ini"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath instanceDelete istanza-da-rimuovere"
    Write-Output ""
    Write-Output "  - setAccessKeyId: "
    Write-Output "    Modifica l'AWS_ACCESS_KEY_ID relativo all'account attualmente impostato come default."
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      aws_access_key_id: Stringa univoca che identifica una chiave per un utente AWS abilitato"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath setAccessKeyId AABBCCDDEEFFGGHH1234"
    Write-Output "" 
    Write-Output "  - setSecretAccessKey: "
    Write-Output "    Modifica l'AWS_SECRET_ACCESS_KEY_ID relativo all'account attualmente impostato come default."
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      aws_secret_access_key: Stringa univoca che valida una chiave di un utente AWS abilitato"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath setSecretAccessKey qwertyuiop1234567890asdfghjkl1234567890"
    Write-Output ""
    Write-Output "  - getAWSRegions: "
    Write-Output "    Restituisce tutte le Regioni AWS disponibili per l'account impostato come default"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath getAWSRegions"
    Write-Output ""
    Write-Output "  - setAWSRegion: "
    Write-Output "    Modifica l'AWS_DEFAULT_REGION relativo all'account attualmente impostato come default."
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      aws_region: nome della regione si cui ci si vuole spostare es: eu-west-1"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath setAWSRegion eu-west-1"
    Write-Output "" 
    Write-Output "  - getInstanceInfo: "
    Write-Output "    Restituisce alcune informazioni relative ad un'istanza EC2 nell'account impostato come default"
    Write-Output "    Come parametri devono essere forniti:"
    Write-Output "      nome_istanza: nome del'istanza di cui si vogliono le imformazioni"
    Write-Output "    esempio: "
    Write-Output "    $PSCommandPath getInstanceInfo istanza-che-voglio-conoscere"
    Write-Output "" 
    Write-Output "########################################################################################################################"
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
    startEC2 { 
        Write-Output "$azione"
        $instanceId = getInstanceID -account $account -instanceName $parametro
        Write-Output "AccendiIstanzaEC2 -InstanceId $instanceId"
        AccendiIstanzaEC2 -InstanceId $InstanceId
    }
    stopEC2 { 
        Write-Output "$azione"
        $instanceId = getInstanceID -account $account -instanceName $parametro
        Write-Output "SpegniIstanzaEC2 -InstanceId $instanceId"
        SpegniIstanzaEC2 -InstanceId $InstanceId
    }
    getAccountList { 
        Write-Output "$azione"
        getAccounts; 
        Break 
    }
    getDefaultAccount { 
        Write-Output "$azione"
        getDefaultAccount; 
        Break
    }
    setDefaultAccount { 
        Write-Output "$azione"
        Write-Output $parametro
        setDefaultAccount -newDefaultAccount $parametro
        Break
    }
    instanceList { 
        Write-Output "$azione"
        instanceList -account $account
    }
    instanceAdd { 
        Write-Output "$azione"
        Write-Output "$parametro"
        Write-Output "$altroparametro"
        instanceAdd -account $account -newInstanceName $parametro -newInstanceId $altroparametro

    }
    instanceDelete { 
        Write-Output "$azione"
        Write-Output "$parametro"
        Write-Output "$altroparametro"
        instanceDelete -account $account -instanceName $parametro
    }
    getInstanceInfo{ 
        Write-Output "$azione"
        Write-Output "$parametro"
        $instanceId = getInstanceID -account $account -instanceName $parametro
        Write-Output "$instanceId"
        getInstanceInfo -account $account -instanceId $instanceId
    }
    getAWSRegions{ 
        Write-Output "$azione" 
        getAWSRegions
        Break
    }
    setAWSRegion{ 
        Write-Output "$azione" 
        setAWSRegion -account $account -newRegion $parametro
        Break
    } 
    setAWSAccessKeyId{ 
        Write-Output "$azione" 
        setAWSAccessKeyId -account $account -newAccessKeyId $parametro
        Break
    } 
    setAWSSecretAccessKey{ 
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
        Write-Output "$azione"
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