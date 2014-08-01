### H-ART development provisioning

1. installare [Vagrant][1] se non già installato (Versione di riferimento Vagrant 1.6.3 )

2. eseguire:

        $ vagrant box list

3.  Se la box [hashicorp/precise64][2] non è già installata, eseguire:

        $ vagrant box add hashicorp/precise64

4. scaricare lo zip del repository in una cartella a scelta.
5. Dalla cartella scelta eseguire:

        $ vagrant up

La cartella scelta sarà condivisa con la VM tramite [NSF][3], quindi il progetto deve essere inserito all'interno della cartella stessa.

L'indirizzo ip di default per accedere alla nuova macchina virtuale è:

    192.168.33.10

I sorgenti del progetto devono essere inclusi nella stessa cartella di vagrant.

Per personalizzare il virtualhost dell'ambiente, modificare il file

    [DIRECTORY_DEV_MACHINE]/modules/apache2/default.erb

### Devify

Utile script per gestire i progetti con la Dev Machine, va scaricato ed installato in un qualsiasi path di sistema che sia nella variabile di ambiente `$PATH`, ad esempio `/usr/local/bin` su sistemi MacOS X

    https://gist.github.com/mrosati84/2f1aecf0961260fe37ec

#### Utilizzo

    $ devify

inizializza un nuovo progetto. In caso di progetto preesistente richiede il consenso da parte dell'utente per la sovrascrittura delle directory

    $ devify git@github.com:h-art/Toolbox.git

inizializza un nuovo progetto, clonando nella directory il progetto specificato come primo argomento.

## Collegamento a MySQL

La macchina virtuale è configurata in modo da permettere il collegamento remoto dell'utente `root` di MySQL. Per connettersi è sufficiente usare come host l'indirizzo IP specificato nel `Vagrantfile`, e usare l'utenza `root` con password `root`.

Per l'amministrazione del database è consigliato l'uso su sistemi MacOS di [Sequel Pro][4]

## Configurazione presente
* composer
* php 5.4.30 ( http://192.168.33.10/info.php )
* phpmyadmin ( http://192.168.33.10/phpmyadmin ) user: root, pass: root
* php5-intl
* php5-curl
* php5-mcrypt
* php5-imagick
* php5-apc


  [1]: http://www.vagrantup.com/
  [2]: https://vagrantcloud.com/hashicorp/precise64
  [3]: http://docs.vagrantup.com/v2/synced-folders/nfs.html
  [4]: http://www.sequelpro.com/