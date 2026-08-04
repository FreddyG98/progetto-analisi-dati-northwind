# Architettura Dati End-to-End & Advanced BI (Northwind & AdventureWorks)

## 📝 Descrizione del Progetto
Progettazione e implementazione di un'architettura dati *end-to-end self-hosted* per l'analisi aziendale avanzata, strutturata per simulare l'infrastruttura e le logiche di uno scenario enterprise reale. L'intero ecosistema è ospitato su un server dedicato (Raspberry Pi 5) e orchestrato in container tramite Docker e Portainer. 

Il core dell'architettura è costituito da un'istanza relazionale PostgreSQL ottimizzata per le fasi di ingestion, data auditing e modellazione di dataset complessi (Northwind e AdventureWorks). I dati estratti e trasformati alimentano, attraverso un canale sicuro On-Premises Data Gateway, un sistema di Business Intelligence evoluto su Power BI Desktop e Power BI Service, combinando metriche DAX avanzate, visual vettoriali custom (Figma/SVG) e dashboard interattive.

---

## 📈 Dashboard
<img width="1422" height="797" alt="Dashboard" src="https://github.com/user-attachments/assets/ed6b22be-c94f-4970-8ad3-d31d5c7911cc" />

---

## 🎯 Obiettivi
* Configurare, modellare e ottimizzare database enterprise (Northwind e AdventureWorks) in un ambiente self-hosted.
* Sviluppare un ecosistema di analisi end-to-end su Power BI a supporto delle decisioni aziendali.

---

## 🛠️ Strumenti Utilizzati
* **Infrastruttura:** Kit Raspberry Pi 5 (8 GB RAM), SSD Crucial (500 GB), Docker, Portainer
* **Database & GUI:** PostgreSQL, PgAdmin 4, DBeaver Desktop
* **Business Intelligence:** Power BI Desktop, Power BI Service, On-Premises Data Gateway
* **Design Custom:** Figma (Visual vettoriali SVG)

---

## 🚀 Fasi di Sviluppo (Passaggi Tecnici)

### 1. Ingestion e Popolamento del Database Northwind
* Creazione dell'istanza relazionale dedicata all'interno dell'ambiente PostgreSQL.
* Scelta strategica di utilizzare script strutturati `.SQL` per l'istanziazione e il popolamento automatico delle tabelle, evitando il caricamento manuale di file `.CSV` massivi potenzialmente instabili.
* Risoluzione del blocco di trasferimento locale-container tramite l'impiego dello Storage Manager di PgAdmin per l'importazione sicura degli script nel Query Tool.
* Esecuzione di query di controllo per la validazione dell'integrità dei dati e del corretto popolamento transazionale.

### 2. Stress Test Infrastruttura e Gestione Grandi Volumi (AdventureWorks)
* Ingestion del database AdventureWorks con l'obiettivo di testare la scalabilità del server Raspberry Pi 5 a fronte di dataset enterprise ad alta dimensionalità.
* Gestione della pipeline di caricamento vincolata all'ordine logico dei vincoli relazionali: esecuzione prioritaria dello script di "Schema" (architettura delle tabelle) e successivo caricamento del file "Data" (popolamento record).
* Identificazione e risoluzione del crash dell'editor di PgAdmin 4 causato dal superamento del limite predefinito di memoria (script di 81 MB contro i 50 MB massimi consentiti), incrementando la memoria dell'editor a 200 MB.

### 3. Ottimizzazione Workspace e Migrazione su DBeaver
* Valutazione tecnica e scelta architetturale di introdurre DBeaver Desktop per superare i limiti strutturali e di memoria delle interfacce web standard, centralizzando la gestione in un'unica GUI professionale.
* Risoluzione dell'errore di sistema *“OutOfMemoryError”* eseguendo il codice in background tramite il tool nativo "Esegui Script" di DBeaver, senza sovraccaricare il rendering grafico dello schermo.

### 4. Esplorazione del Database Northwind & Data Auditing
* Analisi preventiva della densità dei dati con esclusione mirata delle tabelle vuote (`customer_customer_demo`, `customer_demographics`) o non funzionali (`us_states`, `region`).
* Sviluppo di Viste SQL (SQL Views) per isolare esclusivamente le colonne necessarie, applicando Alias parlanti per standardizzare la nomenclatura.
* Approccio orientato alle performance: l'adozione di viste singole permette al motore colonnare di Power BI (VertiPaq) di elaborare in modo ottimale uno Schema a Stella (Star Schema) basato su tabelle verticalizzate.

### 5. Data Transformation Avanzata in SQL
* Ottimizzazione della vista `vw_employees` tramite la funzione `CONCAT_WS` per l'unificazione nativa di nome e cognome.
* Implementazione di logiche condizionali avanzate tramite l'istruzione `CASE` all'interno della vista `vw_orders` per tracciare lo stato logistico, gestendo il data-type mismatch tramite casting esplicito (`::text`).
* Creazione di una vista globale basata su regole di `LEFT JOIN` con approccio "a valanga" per preservare i record NULL e consentire attività di data exploration rapida.
* Validazione sistematica dei dati tramite query di verifica per l'intercettazione dei record `NULL` e stesura della documentazione interna del codice tramite commenti strutturati.

### 6. Configurazione Rete Privata e Connettività End-to-End
* Implementazione dell'On-Premises Data Gateway (Standard) sul PC locale per abilitare il canale di comunicazione sicuro tra il server PostgreSQL (rete locale privata) e il cloud di Power BI Service.
* Sviluppo di script di automazione tramite file `.bat` (accensione/spegnimento programmato del servizio) per ottimizzare l'allocazione della RAM sul PC host.
* Connessione di Power BI Desktop al server PostgreSQL configurando l'estrazione delle viste in modalità *DirectQuery* per garantire il passaggio dei dati in tempo reale.

### 7. Data Profiling e Normalizzazione del Modello
* Configurazione delle relazioni logiche tra le tabelle, ridenominazione descrittiva di campi ed entità e impostazione delle categorie geografiche per i visual cartografici.
* Risoluzione di un bug del connettore in Power Query (che interpretava i numeri interi come decimali con lunghe code sul prezzo unitario): intervento alla sorgente su DBeaver modificando il tipo di dato da `float4` a `numeric(6,2)`.
* Normalizzazione dei campi logistici ibridi: scissione delle colonne originarie in due campi testuali (`stato_ordine` e `stato_scadenza`) e due campi numerici per il calcolo dei delta temporali.

### 8. Sviluppo del Report e Infrastruttura DAX
* Creazione di un layout grafico coerente con barra laterale di navigazione e pulsanti interattivi di pagina.
* Generazione della tabella dei tempi tramite funzione DAX `CALENDARAUTO`, formattata in *Short Date* e relazionata al modello.
* Sviluppo di metriche core focalizzate su ricavi ed efficienza operativa (es. `_QUANTITA_ORDINI`, `_ORDINI_DISTINTI`, `_FATTURATO_SCONTATO`) organizzate in cartelle dedicate.

### 9. Analisi di Pagina e Soluzioni Grafiche Custom
* **Homepage:** Inserimento di un grafico Tachimetro (Gauge) con target dinamici annuali scalabili (+10%) gestiti tramite la funzione DAX `SWITCH`, isolando i crash di scala grafica con espressioni condizionali `IF`.
* **Vendite & Prodotti:** Tool-Tip dinamici nascosti per il calcolo delle variazioni percentuali e switch logico tramite *Segnalibri (Bookmarks)* per alternare i grafici tra "Fatturato" e "Quantità Vendute" in un unico spazio.
* **Performance HR:** Matrici arricchite con *Sparkline* integrate e filtri dinamici.
* **Geomarketing & Logistica:** Grafici personalizzati per lo stato di evasione ordini e integrazione di una mappa a tutto schermo basata su un file cartografico personalizzato in formato **TopoJSON**, ottimizzato esternamente per superare i limiti di geolocalizzazione standard. Gestione dei record duplicati nel ranking dei Top Client tramite misura DAX avanzata con `COUNTROWS` e `FILTER`.
* **Magazzino:** Tabella di controllo inventario (delta riordine) con formattazione condizionale a barre (Blu/Rosso) ottimizzata tramite un correttivo di micro-scostamento (`+0.1`) combinato con `ISBLANK` per non perdere l'evidenziazione visiva dello zero.
* **UI/UX & SVG Custom:** Progettazione da zero su Figma di un visual *Gauge* minimalista, estrapolazione del codice vettoriale `SVG` e integrazione dinamica all'interno di una misura DAX categorizzata come *URL Immagine*, renderizzata nativamente in una tabella Power BI.

### 10. Debugging, Pubblicazione e Ottimizzazione Cloud
* Rilevamento dei colli di bottiglia tramite *Analizzatore di Prestazioni (Performance Analyzer)* e ottimizzazione delle query SQL tramite creazione di Indici specifici sulle Foreign Key (FK) e sulle colonne data della tabella dei fatti (`Orders`).
* **Conversione Architetturale:** Per consentire la condivisione pubblica tramite link web superando i blocchi di rete del Gateway locale, è stata creata una copia del report convertendo il modello dati da *DirectQuery* a *Modalità Import*, riducendo drasticamente i tempi di caricamento.
* Pubblicazione finale nell'Area di lavoro di Power BI Service e sviluppo della Dashboard direzionale.
