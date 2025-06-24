# OpenSSL-Self-Signed-Certificates

**Obiettivo**: Realizzare un sistema che:
- Generi certificati Self-Signed con parametri standard SACMI
- Permetta di esportarli in un formato .pfx (per Kestrel) e .crt/.key (per altri usi)
- Fornisca istruzioni o script per l'integrazione nei sistemi del cliente
- Sia riutilizzabile per generare altri certificati in futuro anche per altri clienti

## 1. Generare i certificati 
### Versione base con password hardcoded
Per prima cosa rendere eseguibile lo script generate_cert.sh

``` bash
chmod +x generate_cert.sh
```

Poi eseguirlo con il comando
``` bash
./generate_cert.sh
```

Questo script:

- **sacmi.csr** → Crea la richiesta di certificato, è un file temporaneo che viene eliminato a fine script
- **sacmi.key** → chiave privata
- **sacmi.crt** → certificato pubblico
- **sacmi.pfx** → certificato + chiave per Kestrel (con password changeit)
- Usa il file **sacmi.conf** per applicare le policy SACMI

## Versione avanzata con password parametrizzata
Questa versione consente di personalizzare il nome del cliente e la password del file .pfx tramite parametri da linea di comando
``` bash
chmod +x generate_cert_v2.sh
./generate_cert_v2.sh <nome> <password>
```
Esempio:
``` bash
./generate_cert_v2.sh sacmi changeit
```

## 2. Integrazione nel sistema del cliente
Per Kestrel, nel file appsettings.json del cliente:
``` json
"HttpsInlineCertFile": {
  "Url": "https://localhost:5001",
  "Certificate": {
    "Path": "certs/sacmi.pfx",
    "Password": "changeit"
  }
}
```
Necessario assicurarsi che:
- il file `sacmi.pfx` si trovi nella cartella certs/ all'interno della root del progetto ASP.NET Core del cliente. Se il file si trova in un'altra posizione, è 
necessario aggiornare il percorso nel file `appsettings.json` di conseguenza
- La password indicata nel file `appsettings.json` deve corrispondere alla stessa password dello script `generate_cert.sh`

## 3. Domain Name System (DNS) e Fully Qualified Domain Name (FQDN)
Il cliente deve scegliere un FQDN (Come definito nel file `sacmi.conf` → DNS.1 = *.sacmi.com, permette l'uso di qualsiasi sottodominio di sacmi.com, es. demo.sacmi.com)
Poi deve configurare il DNS per farlo puntare all'IP del server dove già gira l'applicazione
Quindi usare quel FQDN per accedere al sito, così il certificato sarà considerato valido

## 4. Personalizzazione

Per riutilizzare la soluzione per altri clienti, modificare il file di configurazione: `sacmi.conf` (modificare i campi CN, O, etc.) ed eseguire nuovamente:
``` bash
./generate_cert.sh
```
per generare un nuovo certificato personalizzato

## 5. Testing su Github codespaces (facoltativo)
1. Rendere eseguibile lo script generate_cert.sh

``` bash
chmod +x generate_cert.sh
```

2. Eseguire lo script con il comando
``` bash
./generate_cert.sh
```

3. Per verificare che il certificato SSL funzioni correttamente, eseguire lo script Python, per avviare il server:
``` bash
python3 https_server.py
```
In output verrà visualizzato il messaggio: "Server HTTPS attivo su https://localhost:8443"

4. Apparirà un pop-up con il messaggio "L'applicazione in esecuzione sulla porta 8443 è disponibile.", premere su "Rendi pubblica"
5. Spostarsi nella sezione "Porte" nel menù di VScode, a destra di "Terminale", e seguire il link sotto la voce elenco "Indirizzo inoltrato". 
6. Il sito ha l'obiettivo di verificare che il certificato SSL funzioni correttamente, in particolare:
- Il server HTTPS usa il certificato sacmi.crt e la chiave sacmi.key
- Il browser stabilisce una connessione sicura (TLS) con quel certificato
- Se è possibile visualizzare la pagina (anche con un avviso di sicurezza), significa che:
  - Il certificato è valido
  - La chiave è corretta
  - Il certificato è utilizzabile in un'applicazione reale (come Kestrel)
