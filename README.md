# ec2-manager for PowerShell #

Semplice script PowerShell nato con l'intenzione di fornire ad un utente non amministratore la possibilità 
di avviare e/o spegnere istanze EC2.


Set-ExecutionPolicy -ExecutionPolicy Bypass

### Dipendenze ###

Utilizza due moduli PowerShell:

* PsIni
* AWSPowerShell

Tali moduli se non presenti vengono automaticamente installati a livello utente.

### Struttura ###

Il tool di gestione per le istanze EC2 si compone di tre file:

* **ec2-manager.ps1 :** Lo script PowerShell contenente tutta la logica e le funzioni necessarie alla gestione delle istanze
* **config.ini :** File di configurazione che contiene informazioni relative ai vari account AWS censiti, quali access key id e secret access key che permettono all'utente di connettersi ai vari account AWS.
* **intances.ini :** File di configurazione che contiene un archivio delle istanze che possono/devono essere gestite con questo script. Le istanze sono divise per account, gli stessi account presenti nel file config.ini


### Setup ###

Non è necessaria un'installazione vera e propria, essendo uno script PowerShell.

E' sufficiente clonare (o scaricare) il repository aprire una PowerShell ed andare ad eseguire lo script ec2-manager.ps1 , prestando attenzione alla presenza nello stesso path dello script dei due file .ini

Potrebbe essere necessario abilitarne l'esecuzione andando ad impostare le ExecityonPolicy:

```PowerShell
Set-ExecutionPolicy -ExecutionPolicy Bypass
```

### Come funziona ###

ec2-manager è fornito di un solido help che spiega abbastanza dettagliatamente il funzionamento e le operazioni che è in grado di compiere.

#### - help: 
Mostra a schermo l'help.

```
.\ec2-manager.ps1 help
```

#### - startEC2:
Avvia un'istanza EC2 su AWS nell'account di "default".
L'istanza viene identificata mediante l'utilizzo di un nome univoco, definito nel file instances.ini. 
Tale nome è accettato come parametro (mandatorio) dallo script.
Ad ogni nome, definito dall'utente è associato l'instance id di una istanza EC2. 
(per conoscere le istanze censite nell'instances.ini, vedere [instanceList](#instancelist)).

##### Parametri:
- **nome istanza :** il nome dell'istanza registrato nel file instances.ini

##### Esempio:
```
.\ec2-manager.ps1 startEC2 istanzaTest2023
```

#### - stopEC2:
Ferma un'istanza EC2 su AWS nell'account di "default".
L'istanza viene identificata mediante l'utilizzo di un nome univoco, definito nel file instances.ini. 
Tale nome è accettato come parametro (mandatorio) dallo script.
Ad ogni nome, definito dall'utente è associato l'instance id di una istanza EC2. 
(per conoscere le istanze censite nell'instances.ini, vedere [instanceList](#instancelist)).

##### Parametri:
- **nome istanza :** il nome dell'istanza registrato nel file instances.ini

##### Esempio:
```
.\ec2-manager.ps1 stopEC2 istanzaTest2023
```

#### - getInstanceInfo:
Restituisce alcune informazioni su un'istanza EC2 su AWS nell'account di "default".
L'istanza viene identificata mediante l'utilizzo di un nome univoco, definito nel file instances.ini. 

##### Parametri:
- **nome istanza :** il nome dell'istanza registrato nel file instances.ini

##### Esempio:
```
.\ec2-manager.ps1 getInstanceInfo istanzaTest2023
```


##### - instanceList
Ritorna la lista delle istanze disponibili (censite) nell'account attualmente impostato come default.

##### Esempio:
```
.\ec2-manager.ps1 instanceList
```

#### - instanceAdd:
Aggiunge un'istanza EC2 nell'account di "default", aggiungendo nome ed id nel file instances.ini.

##### Parametri:
- **nome istanza :** il nome univoco dell'istanza da aggiungere nel file instances.ini
- **id istanza :** l'instance id da aggiungere nel file instances.ini

##### Esempio:
```
.\ec2-manager.ps1 instanceAdd istanzaTest2023 id-123434567890
```

#### - instanceDelete:
Rimuove un'istanza EC2 nell'account di "default", rimuovendo nome ed id dal file instances.ini.

##### Parametri:
- **nome istanza :** il nome univoco dell'istanza da aggiungere nel file instances.ini

##### Esempio:
```
.\ec2-manager.ps1 instanceDelete istanzaTest2023
```

#### - getAccountList:
Ritorna la lista degli account AWS disponibili, ossia quelli "censiti" nel file config.ini e di conseguenza anche nel file instances.ini.
Comando utile per evitare di impostare come default un account inesistente sminchiando il funzionamento dello script PowerShell.

##### Esempio:
```
.\ec2-manager.ps1 getAccountList
```

#### - getDefaultAccount:
Ritorna l'account AWS attualmente impostato come default.
Comando utile per sapere in quale account si sta lavorando.

##### Esempio:
```
.\ec2-manager.ps1 getDefaultAccount
```

#### - setDefaultAccount:
Imposta l'account di "default".

##### Parametri:
- **nome account :** il nome univoco dell'account AWS da impostare come default.

##### Esempio:
```
.\ec2-manager.ps1 setDefaultAccount SERVIZI
```

#### - setAccessKeyId:
Imposta l'AWS_ACCESS_KEY_ID relativo all'account attualmente impostato come default.

##### Parametri:
- **aws access key id :** Stringa univoca che identifica una chiave per un utente AWS bilitato.

##### Esempio:
```
.\ec2-manager.ps1 setAccessKeyId AABBCCDDEEFFGGHH1234
```

#### - setSecretAccessKey:
Imposta l'AWS_SECRET_ACCESS_KEY_ID relativo all'account attualmente impostato come default.

##### Parametri:
- **aws secret access key :** Stringa univoca che valida una chiave per un utente AWS bilitato.

##### Esempio:
```
.\ec2-manager.ps1 setSecretAccessKey qwertyuiop1234567890asdfghjkl1234567890
```

#### - getAWSRegions:
Restituisce tutte le Regioni AWS disponibili per l'account impostato come default.
Comando utile per sapere dove si sta lavorando.

##### Esempio:
```
.\ec2-manager.ps1 getAWSRegions
```

#### - setAWSRegion:
Imposta l'AWS_DEFAULT_REGION relativo all'account attualmente impostato come default.

##### Parametri:
- **aws region :** nome della regione.

##### Esempio:
```
.\ec2-manager.ps1 setAWSRegion eu-west-1
```

### TO DO ###

* Gestire anche un'istanza di default.
* Implementare la gestione dei secirity groups delle istanze