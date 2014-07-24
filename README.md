### H-ART development provisioning

1. installare vagrant se non già installato (Versione di riferimento Vagrant 1.6.3 )

2. eseguire 

  *vagrant box list*

  2a.  Se la box "hashicorp/precise64" non è già installata , eseguire
  
    *vagrant box add hashicorp/precise64*
    
  
3. eseguire

  *vagrant up*
  
L'indirizzo ip di default per accedere alla nuova macchina virtuale è 

**192.168.33.10**

I sorgenti del progetto devono essere inclusi nella stessa cartella di vagrant.

Per personalizzare il virtualhost dell'ambiente, modificare il file

*[DIRECTORY_DEV_MACHINE]/modules/apache2/default.erb*
