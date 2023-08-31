# NSEC2-manager for PowerShell

"Non Solo EC2 Manager" è un semplice script PowerShell, un po' meno semplice di prima in effetti, nato con l'intenzione di fornire ad un utente non amministratore la possibilità di avviare e/o spegnere istanze EC2. 

Di recente pare sia anche in grado di gestire gli Amazon Workspaces. 

 

Set-ExecutionPolicy -ExecutionPolicy Bypass

### Dipendenze

Utilizza due moduli PowerShell:

* PsIni
* AWSPowerShell
* PSWriteColor

Tali moduli se non presenti vengono automaticamente installati a livello utente.

### Struttura

Il tool di gestione per le istanze EC2 si compone di tre file:

* **ec2-manager.ps1 :** Lo script PowerShell contenente tutta la logica e le funzioni necessarie alla gestione delle istanze
* **config.ini :** File di configurazione che contiene informazioni relative ai vari account AWS censiti, quali access key id e secret access key che permettono all'utente di connettersi ai vari account AWS.
* **intances.ini :** File di configurazione che contiene un archivio delle istanze che possono/devono essere gestite con questo script. Le istanze sono divise per account, gli stessi account presenti nel file config.ini

### Setup

Non è necessaria un'installazione vera e propria, essendo uno script PowerShell.

E' sufficiente clonare (o scaricare) il repository aprire una PowerShell ed andare ad eseguire lo script ec2-manager.ps1 , prestando attenzione alla presenza nello stesso path dello script dei due file .ini

Potrebbe essere necessario abilitarne l'esecuzione andando ad impostare le ExecityonPolicy:

```PowerShell
Set-ExecutionPolicy -ExecutionPolicy Bypass
```

### Come funziona

ec2-manager è fornito di un solido help che spiega abbastanza dettagliatamente il funzionamento e le operazioni che è in grado di compiere.

#### - help:

Mostra a schermo l'help.

```
.\ec2-manager.ps1 help
```

#### - Start-EC2:

Avvia un'istanza EC2 su AWS nell'account di "default".
L'istanza viene identificata mediante l'utilizzo di un nome univoco, definito nel file instances.ini. 
Tale nome è accettato come parametro (mandatorio) dallo script.
Ad ogni nome, definito dall'utente è associato l'instance id di una istanza EC2. 
(per conoscere le istanze censite nell'instances.ini, vedere [instanceList](#instancelist)).

##### Parametri:

- **nome istanza :** il nome dell'istanza registrato nel file instances.ini

##### Esempio:

```
.\ec2-manager.ps1 Start-EC2 istanzaTest2023
```

#### - Stop-EC2:

Ferma un'istanza EC2 su AWS nell'account di "default".
L'istanza viene identificata mediante l'utilizzo di un nome univoco, definito nel file instances.ini. 
Tale nome è accettato come parametro (mandatorio) dallo script.
Ad ogni nome, definito dall'utente è associato l'instance id di una istanza EC2. 
(per conoscere le istanze censite nell'instances.ini, vedere [instanceList](#instancelist)).

##### Parametri:

- **nome istanza :** il nome dell'istanza registrato nel file instances.ini

##### Esempio:

```
.\ec2-manager.ps1 Stop-EC2 istanzaTest2023
```

#### - Get-InstanceInfo:

Restituisce alcune informazioni su un'istanza EC2 su AWS nell'account di "default".
L'istanza viene identificata mediante l'utilizzo di un nome univoco, definito nel file instances.ini. 

##### Parametri:

- **nome istanza :** il nome dell'istanza registrato nel file instances.ini

##### Esempio:

```
.\ec2-manager.ps1 Get-InstanceInfo istanzaTest2023
```

##### - Get-InstanceList

Ritorna la lista delle istanze disponibili (censite) nell'account attualmente impostato come default.

##### Esempio:

```
.\ec2-manager.ps1 Get-InstanceList
```

#### - Add-Instance:

Aggiunge un'istanza EC2 nell'account di "default", aggiungendo nome ed id nel file instances.ini.

##### Parametri:

- **nome istanza :** il nome univoco dell'istanza da aggiungere nel file instances.ini
- **id istanza :** l'instance id da aggiungere nel file instances.ini

##### Esempio:

```
.\ec2-manager.ps1 Add-Instance istanzaTest2023 id-123434567890
```

#### - Delete-Instance:

Rimuove un'istanza EC2 nell'account di "default", rimuovendo nome ed id dal file instances.ini.

##### Parametri:

- **nome istanza :** il nome univoco dell'istanza da aggiungere nel file instances.ini

##### Esempio:

```
.\ec2-manager.ps1 Delete-Instance istanzaTest2023
```

#### - Start-Workspace:

Avvia un Workspace su AWS nell'account di "default".
Il Workspace viene identificato mediante l'utilizzo di un nome univoco, definito nel file workspace.ini. 
Tale nome è accettato come parametro (mandatorio) dallo script.
Ad ogni nome, definito dall'utente è associato l'id di un Workspace AWS. 
(per conoscere i workspace censiti nell'workspaces.ini, vedere  [Get-WorkspacesList](#get-workspacelist)).

##### Parametri:

- **nome workspace:** il nome del workspace registrato nel file workspaces.ini

##### Esempio:

```
.\ec2-manager.ps1 Start-Workspace workspaceTest202
```

#### - Stop-Workspace:

Ferma un Workspace su AWS nell'account di "default".
Il Workspace viene identificato mediante l'utilizzo di un nome univoco, definito nel file workspace.ini. 
Tale nome è accettato come parametro (mandatorio) dallo script.
Ad ogni nome, definito dall'utente è associato l'id di un Workspace AWS. 
(per conoscere i workspace censiti nell'workspaces.ini, vedere [Get-WorkspacesList](#get-workspacelist)).

##### Parametri:

- **nome workspace:** il nome del workspace registrato nel file workspaces.ini

##### Esempio:

```
.\ec2-manager.ps1 Stop-Workspace workspaceTest2023
```

#### - Reboot-Workspace:

Riavvia un Workspace su AWS nell'account di "default".
Il Workspace viene identificato mediante l'utilizzo di un nome univoco, definito nel file workspace.ini. 
Tale nome è accettato come parametro (mandatorio) dallo script.
Ad ogni nome, definito dall'utente è associato l'id di un Workspace AWS. 
(per conoscere i workspace censiti nell'workspaces.ini, vedere Get-WorkspacesList).

##### Parametri:

- **nome workspace:** il nome del workspace registrato nel file workspaces.ini

##### Esempio:

```
.\ec2-manager.ps1 Reboot-Workspace workspaceTest2023
```

#### - Get-WorkspaceList

Ritorna la lista dei Workspaces disponibili (censite) nell'account impostato come default.

##### Esempio:

```
.\ec2-manager.ps1 Get-WorkspaceList
```

#### - Get-WorkspaceInfo

Restituisce alcune informazioni relative ad un Workspace nell'account impostato come default.

##### Parametri:

- **nome workspace:** il nome del workspace registrato nel file workspaces.ini

##### Esempio:

```
.\ec2-manager.ps1 Get-WorkspaceInfo workspaceTest2023
```

#### - Get-WorkspaceState

Restituisce lo stato si un Workspace (AVAILABLE, STOPPED...) nell'account impostato come default.

##### Parametri:

- **nome workspace:** il nome del workspace registrato nel file workspaces.ini

##### Esempio:

```
.\ec2-manager.ps1 Get-WorkspaceState workspaceTest2023
```

#### - Add-Workspace:

Aggiunge un Workspace nel file workspaces.ini nella sezione relativa all'account attualmente impostato come default.

##### Parametri:

- **nome workspace:** il nome univoco che identifica il workspace nel file workspaces.ini
- **id workspace:** il Workspace Id utilizzato dallo script per gestire i workspaces su AWS

##### Esempio:

```
.\ec2-manager.ps1 Add-workspace workspaceTest2023 ws-123434567890
```

#### - Delete-Workspace:

Rimuove un Workspace nel file workspaces.ini nella sezione relativa all'account attualmente impostato come default.

##### Parametri:

- **nome workspace:** il nome univoco che identifica il workspace nel file workspaces.ini

##### Esempio:

```
.\ec2-manager.ps1 Delete-Workspace workspaceTest2023
```

#### - Get-AccountsList:

Ritorna la lista degli account AWS disponibili, ossia quelli "censiti" nel file config.ini e di conseguenza anche nel file instances.ini.
Comando utile per evitare di impostare come default un account inesistente sminchiando il funzionamento dello script PowerShell.

##### Esempio:

```
.\ec2-manager.ps1 Get-AccountsList
```

#### - Get-DefaultAccount:

Ritorna l'account AWS attualmente impostato come default.
Comando utile per sapere in quale account si sta lavorando.

##### Esempio:

```
.\ec2-manager.ps1 Get-DefaultAccount
```

#### - Set-DefaultAccount:

Imposta l'account di "default".

##### Parametri:

- **nome account :** il nome univoco dell'account AWS da impostare come default.

##### Esempio:

```
.\ec2-manager.ps1 Set-DefaultAccount SERVIZI
```

#### - Set-AccessKeyId:

Imposta l'AWS_ACCESS_KEY_ID relativo all'account attualmente impostato come default.

##### Parametri:

- **aws access key id :** Stringa univoca che identifica una chiave per un utente AWS bilitato.

##### Esempio:

```
.\ec2-manager.ps1 Set-AccessKeyId AABBCCDDEEFFGGHH1234
```

#### - Set-SecretAccessKey:

Imposta l'AWS_SECRET_ACCESS_KEY_ID relativo all'account attualmente impostato come default.

##### Parametri:

- **aws secret access key :** Stringa univoca che valida una chiave per un utente AWS bilitato.

##### Esempio:

```
.\ec2-manager.ps1 Set-SecretAccessKey qwertyuiop1234567890asdfghjkl1234567890
```

#### - Get-AWSRegionsList:

Restituisce tutte le Regioni AWS disponibili per l'account impostato come default.
Comando utile per sapere dove si sta lavorando.

##### Esempio:

```
.\ec2-manager.ps1 Get-AWSRegionsList
```

#### - Set-AWSRegion:

Imposta l'AWS_DEFAULT_REGION relativo all'account attualmente impostato come default.

##### Parametri:

- **aws region :** nome della regione.

##### Esempio:

```
.\ec2-manager.ps1 Set-AWSRegion eu-west-1
```

### TO DO

* Gestire anche un'istanza di default.
* Implementare la gestione dei secirity groups delle istanze